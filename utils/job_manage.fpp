# include "define.inc"

module job_manage

  implicit none

  private

  public :: timer_local
  public :: time_message
  public :: job_fork
  public :: checkstop
  public :: checktime
  public :: init_checktime
  public :: checktime_initialized
  public :: njobs
  public :: trin_restart
  public :: trin_reset
  public :: trin_job

  integer :: njobs
  logical, parameter :: debug=.false.
  logical :: trin_restart=.false.
  logical :: trin_reset=.true.
  integer :: trin_job = 0

  real :: wall_clock_initial_time=0.
  logical :: checktime_initialized=.false.!THIS SHOULD BE MODULE LEVEL?

contains

!!! returns CPU time in second
  function timer_local()
# ifdef OPENMP
!$    use omp_lib, only: omp_get_wtime
# else
!THIS SHOULD BE PROVIDED BY THE MP MODULE INSTEAD
# ifdef MPI
# ifndef MPIINC
    use mpi, only: mpi_wtime
# else
    ! this may cause malfunction of timer if double precision is promoted to quad.
    include "mpif.h" ! CMR following Michele Weiland's advice
# endif
# endif
# endif
    real :: timer_local

    timer_local=0.

# ifdef OPENMP
    timer_local=omp_get_wtime()
# else
# if defined MPI && !defined MPIINC
    timer_local=mpi_wtime()
# else
    ! this routine is F95 standard
    call cpu_time(timer_local)
# endif
# endif
  end function timer_local
    
  subroutine time_message(lprint,targ,chmessage)
    !
    ! this routine counts elapse time between two calls
    !
    character (len=*), intent(in) :: chmessage
    logical, intent(in) :: lprint
    real, intent(in out) :: targ(2) ! tsum and told
    real :: tnew
    real, parameter :: small_number=1.e-10

    tnew=timer_local()

    if (targ(2) == 0.) then
       !>RN targ(2) must be non-zero at initialization.
       if (tnew == 0.) tnew=small_number
       targ(2) = tnew
    else
       targ(1)=targ(1)+tnew-targ(2)
       if (lprint) print *, chmessage,': ',tnew-targ(2),' seconds'
       targ(2)=0.
    end if

  end subroutine time_message

  subroutine job_fork (n_ensembles)
    use file_utils, only: get_unused_unit, list_name, run_name, init_job_name
! MAB> -- moved init_error_unit and init_input_unit calls here from file_utils
! because they were being called there on all procs when they should be called
! only on proc0
    use file_utils, only: init_error_unit, init_input_unit, list_name
    use file_utils, only: futils_initialized => initialized
    use constants, only: run_name_size
! <MAB
    use mp, only: job, scope
    use mp, only: proc0, nproc
    use mp, only: init_jobs, broadcast, finish_mp
    implicit none
    integer, intent (in), optional :: n_ensembles
    integer, dimension(:), allocatable :: group0
    integer :: i, l
    character (10) :: ext
    character(run_name_size), dimension(:), allocatable :: job_list
    integer :: list_unit, ierr
    logical :: err = .true., inp = .true.

    ! open file containing list of input files to run and read total
    ! number of input files from first line
    if (.not. present(n_ensembles)) then
       if (proc0) then
          call get_unused_unit(list_unit)
          open (unit=list_unit, file=trim(list_name))
          read (list_unit,*) njobs
       end if
    else
       njobs = n_ensembles
    end if
    call broadcast (njobs)

    if (nproc < njobs) then
       if (proc0) then
          write (*,*) 
          write (*,*) 'Number of jobs = ',njobs,' and number of processors = ',nproc
          write (*,*) 'Number of processors must not be less than the number of jobs'
          write (*,*) 'Stopping'
          write (*,*) 
       end if
       call finish_mp !Ok as all procs call this routine
       stop 
    end if
       
    if (mod(nproc, njobs) /= 0) then
       if (proc0) then
          write (*,*) 
          write (*,*) 'Number of jobs = ',njobs,' and number of processors = ',nproc
          write (*,*) 'Number of jobs must evenly divide the number of processors.'
          write (*,*) 'Stopping'
          write (*,*) 
       end if
       call finish_mp !Ok as all procs call this routine
       stop
    end if
       
    allocate (job_list(0:njobs-1))
       
    if (proc0) then
       if (.not. present(n_ensembles)) then
          do i=0,njobs-1
             read (list_unit, fmt="(a)") job_list(i)
          end do
          close (list_unit)
       else
          l = len_trim(list_name)
          do i=0,njobs-1
             write (ext,'(i9)') i+1
             ext = adjustl(ext)
             job_list(i) = trim(list_name(1:l-3))//"_"//trim(ext)
          end do
       end if
    end if
    
    do i=0,njobs-1
       call broadcast (job_list(i))
    end do
    
    allocate (group0(0:njobs-1))
    
    call init_jobs (njobs, group0, ierr)
    ! TT> brought up one line [call scope(subprocs)] from file_utils.fpp
    !     to init_jobs
    !    call init_job_name (njobs, group0, job_list)
    call init_job_name (job_list(job))
    ! <TT
    
    ! MAB> moved from file_utils because had to be within proc0, 
    ! which is undefined there
    if (proc0) then
       call init_error_unit (err)
       call init_input_unit (inp)
    end if
    ! <MAB

    if (nproc > 1 .and. proc0) &
         & write(*,*) 'Job ',job,' is called ',trim(run_name),&
         & ' and is running on ',nproc,' processors'
    if (nproc == 1) write(*,*) 'Job ',job,' is called ',trim(run_name),&
         & ' and is running on ',nproc,' processor'
    
    deallocate (group0, job_list) ! MAB

    !> We need to set this for the group proc0, as it is previously
    !! only set for the global proc0
    if (proc0) futils_initialized = .true.
       
  end subroutine job_fork

  subroutine checkstop(exit,list)
    use mp, only: proc0, broadcast
    use file_utils, only: run_name, list_name
    use constants, only: run_name_size
    implicit none
    logical, intent (in), optional :: list
    logical, intent (in out) :: exit
    character(run_name_size) :: filename
    logical :: exit_local

    ! If .stop file has appeared, set exit flag
    filename=trim(run_name)//".stop"
    if(present(list)) then
       if(list) filename=list_name(:len_trim(list_name)-5)//".stop"
    endif
    
    if (proc0) then
       inquire(file=filename,exist=exit_local)
       exit = exit .or. exit_local
    end if

    call broadcast (exit)

  end subroutine checkstop

  subroutine init_checktime
    wall_clock_initial_time=timer_local()  ! timer_local() returns #seconds from fixed time in past
    checktime_initialized=.true.
  end subroutine init_checktime

  subroutine checktime(avail_time,exit,margin_in)
    use mp, only: proc0, broadcast
    use file_utils, only: error_unit
    implicit none
    ! available time in second
    real, intent(in) :: avail_time
    ! margin
    real, intent(in), optional :: margin_in
    ! true if elapse time exceed available time
    logical, intent(in out) :: exit
    real :: elapse_time=0.
    real :: margin=300. ! 5 minutes

    if (present(margin_in)) then
       margin=margin_in
    endif

    if(.not.checktime_initialized) then
       wall_clock_initial_time=timer_local()  ! timer_local() returns #seconds from fixed time in past
       checktime_initialized=.true.
    else 

      elapse_time=timer_local()-wall_clock_initial_time

      if(proc0) then
         if(elapse_time >= avail_time-margin) then
            write(error_unit(),'(a,f12.4,a,f12.4)') &
                 & 'Elapse time ',elapse_time, &
                 & ' exceeds available time',avail_time-margin
            write(error_unit(),'(a,f12.4,a,f12.4,a)') &
                 & '  (Given CPU time: ',avail_time, &
                 & '  Margin: ',margin,')'
            exit=.true.
         endif
      endif
    end if

    call broadcast(exit)
  end subroutine checktime
end module job_manage
