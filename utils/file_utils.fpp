# include "define.inc"

module file_utils
  use constants, only: run_name_size

  implicit none

  private

  public :: init_file_utils
  ! subroutine init_file_utils (list, input, error, trin_run, name)
  ! logical, intent (out) :: list
  ! logical, intent (in), optional :: input, error, trin_run
  ! character(*), intent (in), optional :: name
  !   default: INPUT=.true., ERROR=.true., TRIN_RUN=.false., NAME="unknown"
  !   Set up run_name(s) and list_name for output files
  !   Open input file and strip comments, unless disabled with INPUT=.false.
  !   Open error output file, unless disabled with ERROR=.false.

  public :: init_job_name
  ! subroutine ...

  public :: initialized
  public :: finish_file_utils
  ! subroutine finish_file_utils
  !   Clean up files opened in init

  public :: run_name
  ! character(500) :: run_name
  !    Label for the run, taken from the command line

  !> This array replaces the cbuff array 
  !! in gs2_main. Having the target array in 
  !! the same scope as the pointer is much better
  !! practice in general.
  public :: run_name_target

  public :: list_name
  ! character(500) :: list_name
  !    Label for the list, taken from the command line

  public :: input_unit
  ! function input_unit (nml)
  ! character(*), intent (in) :: nml
  ! integer :: input_unit
  !    Rewind the input file to start of namelist NML,
  !    and return its unit number

  public :: input_unit_exist
  ! function input_unit_exist (nml,exist)
  ! character(*), intent (in) :: nml
  ! integer :: input_unit
  !    Rewind the input file to start of namelist NML,
  !    and return its unit number, setexist=.true.
  !    If the namelist NML isn't found, set exist=.false.

  public :: init_error_unit
  public :: init_input_unit

  public :: error_unit
  ! function error_unit ()
  ! integer :: error_unit
  !    Return the error unit number

  public :: get_input_unit

  public :: append_output_file

  public :: open_output_file
  ! subroutine open_output_file (unit, ext)
  ! integer, intent (out) :: unit
  ! character (*), intent (in) :: ext
  !    Open a file with name made from the run_name with the EXT appended
  !    and return its unit number in UNIT

  public :: close_output_file
  ! subroutine close_output_file (unit)
  ! integer, intent (in) :: unit
  !    Close the file associated with UNIT from open_output_file

  public :: flush_output_file
  ! subroutine flush_output_file (unit)
  ! integer, intent (in) :: unit
  !    Close/open-append the file associated with UNIT from open_output_file

  public :: get_unused_unit
  ! subroutine get_unused_unit (unit)
  ! integer, intent (out) :: unit
  !    Return a unit number not associated with any file

  public :: get_indexed_namelist_unit
  ! subroutine get_indexed_namelist_unit (unit, nml, index)
  ! integer, intent (out) :: unit
  ! character (*), intent (in) :: nml
  ! integer, intent (in) :: index
  !    Copy namelist, NML // '_' // INDEX, from the input file to
  !    namelist, NML, in a temporary file, UNIT

  public :: num_input_lines
  public :: stdout_unit

  character(run_name_size), pointer :: run_name
  character(run_name_size), target :: arun_name, job_name
  
  character(run_name_size), target :: run_name_target
  character(run_name_size) :: list_name
  integer, parameter :: stdout_unit=6
  integer :: input_unit_no, error_unit_no=stdout_unit
! TT>
  integer :: num_input_lines
! <TT

  logical :: initialized = .false.

contains
  !> Read the run_name from the command line (if not given), 
  !! and determine from the extension whether
  !! this is a list run (i.e. a list of runs has been given). If so
  !! or if this is a run with multiple ensembles, open the list description
  !! If not, open the error file and call init_input_unit </doc>
  subroutine init_file_utils (list, input, error, trin_run, name, n_ensembles)
    implicit none
    logical, intent (out) :: list
    logical, intent (in), optional :: input, error, trin_run
    character(*), intent (in), optional :: name
    integer, intent (in), optional :: n_ensembles
    logical :: inp, err

    if (present (input)) then
       inp = input
    else
       inp = .true.
    end if
    if (present (error)) then
       err = error
    else
       err = .true.
    end if
    if (present (name)) then
!# if FCOMPILER == _XL_
!       arun_name = name
!# else
       arun_name = trim(name)
!# endif
    else
       arun_name = "unknown"
    end if

! TT> changed for slice_g
!    call run_type (list)
    if (inp .and. .not. present(trin_run)) then
       ! get runname from command line and
       ! set list=T if input ends in ".list"
       call run_type (list)
    else
       list = .false.
    end if
! <TT

    if (list) then
       list_name = arun_name
    else if (present(n_ensembles)) then
       if (n_ensembles > 1) then
          list_name = arun_name
       else
          call init_run_name
          call init_error_unit (err)
          call init_input_unit (inp)
       end if
    else
       call init_run_name
       call init_error_unit (err)
       call init_input_unit (inp)
    end if

    initialized = .true.
  end subroutine init_file_utils

  !>  This determines the type of run, by reading the name of the input file
  !!  on the command line into arun_name, and then looking at the extension. If
  !! the extension is ''.list'', then list is set to ''.true.''). </doc>
  subroutine run_type (list)

    use command_line, only: cl_getarg, cl_iargc

    implicit none
    logical, intent (out) :: list
    integer :: l, ierr

    ! get argument from command line and put in arun_name
    if (cl_iargc() /= 0) then
       call cl_getarg (1, arun_name, l, ierr)
       if (ierr /= 0) then
          print *, "Error getting run name."
       end if
    end if

!!$# if FCOMPILER == _XL_
!    if arun_name ends in .list, set list = T
    if(l>5)then
       list = (arun_name(l-4:l) == ".list")
    else
       list=.false.
    endif
!!$# else
!!$    if (l>5) then
!!$       list = arun_name(l-4:l) == ".list"
!!$    else
!!$       list = .false.
!!$    end if
!!$# endif

  end subroutine run_type

  subroutine init_run_name
    ! <doc> This is called for a non [[Trinity]] or [[list]] run -
    ! it checks that the input file name ends in ''.in'', chops
    ! the extension off and stores it in [[arun_name]]. It
    ! also assigns the pointer [[run_name]] to [[arun_name]]. </doc>
    implicit none
    integer :: l

    l = len_trim (arun_name)
    if (l > 3)then
       if(arun_name(l-2:l) == ".in") then
          arun_name = arun_name(1:l-3)
       endif
    end if
    run_name => arun_name

  end subroutine init_run_name

! TT>
!  subroutine init_job_name (njobs, group0, job_list)
!    use command_line
!    use mp
!    use mp, only: scope, subprocs, job
  subroutine init_job_name (jobname)
! <TT
    implicit none
! TT>
!    integer, intent (in) :: njobs
!    integer, intent (in), dimension(0:) :: group0
!    character (len=500), dimension(0:) :: job_list
    character(run_name_size), intent (in) :: jobname
! <TT
!    logical :: err = .true., inp = .true.

! TT>
!    call scope (subprocs)
!    job_name = trim(job_list(job))
    job_name = trim(jobname)
! <TT
    run_name => job_name

! MAB>
! can't call these here because we're on all processors
! and only want to init on proc0.  instead called
! from within job_manage
!    call init_error_unit (err)
!    call init_input_unit (inp)
! <MAB

  end subroutine init_job_name

  subroutine get_unused_unit (unit)
    ! <doc> Get an unused ''unit number'' for I/O. </doc>
    implicit none
    integer, intent (out) :: unit
! TT>
!    character(20) :: read, write, readwrite
    logical :: od
! <TT
    unit = 50
    do
! TT>
!       inquire (unit=unit, read=read, write=write, readwrite=readwrite)
!       if (read == "UNKNOWN" .and. write == "UNKNOWN" &
!            .and. readwrite == "UNKNOWN") &
!       then
!          return
!       end if
       ! TT: Can we do the same thing like this?
       ! TT: The above fails in gfortran/g95.
       inquire (unit=unit, opened=od)
       if (.not.od) return
! <TT
       unit = unit + 1
    end do
  end subroutine get_unused_unit

  !> Open an output file to write (replacing any existing)
  !! whose name is [[run_name]] + [[ext]], and set [[unit]] to the
  !! ''unit number'' of that output file.
  subroutine open_output_file (unit, ext)
    implicit none
    integer, intent (out) :: unit
    character (*), intent (in) :: ext
    character(run_name_size) :: hack
    call get_unused_unit (unit)
    hack=trim(run_name)//ext
    open (unit=unit, file=trim(hack), status="replace", action="write")
  end subroutine open_output_file

  !> Open an output file to write (appending if existing)
  !! whose name is [[run_name]] + [[ext]], and set [[unit]] to the
  !! ''unit number'' of that output file.
  subroutine append_output_file (unit, ext)
    implicit none
    integer, intent (out) :: unit
    character (*), intent (in) :: ext
    character(run_name_size) :: hack
    logical :: exists

    call get_unused_unit (unit)
    hack=trim(run_name)//ext
    inquire(file=hack, exist=exists)
    if (exists) then
      open (unit=unit, file=trim(hack), status="old", position="append", action="write")
    else
      open (unit=unit, file=trim(hack), status="new", action="write")
    end if
  end subroutine append_output_file

  subroutine close_output_file (unit)
    implicit none
    integer, intent (in) :: unit
    close (unit=unit)
  end subroutine close_output_file

  subroutine flush_output_file (unit, ext)
    !The ext parameter is not needed for anything (presumably an old approach to flushing
    !used calls to close_output_file and open_output_file). Can't remove parameter until
    !all calls changed to remove ext.
    implicit none
    integer, intent (in) :: unit
    character (*), intent (in), optional :: ext
    character(run_name_size) :: fname
    inquire(unit,name=fname)
# if FCOMPILER == _XL_
!    call flush_(unit)
    !Fortran 2003 introduces the flush statement
    flush(unit)
# elif FCOMPILER == _NAG_
    close(unit=unit)
    open (unit=unit, file=trim(fname), status="old", action="write", position="append")
# else
!    call flush (unit)
    !Fortran 2003 introduces the flush statement
    flush(unit)
# endif
  end subroutine flush_output_file

  subroutine init_error_unit (open_it)
    implicit none
    logical, intent (in) :: open_it
! TT> changed for slice_g
!    error_unit_no = 6
    error_unit_no = 0
! <TT
    if (run_name /= "unknown" .and. open_it) then
       call open_output_file (error_unit_no, ".error")
       ! TT: error_unit_no is overwritten for .error file
    end if
  end subroutine init_error_unit

  subroutine strip_comments (line)
    implicit none
    character(*), intent (in out) :: line
    logical :: in_single_quotes, in_double_quotes
    integer :: i, length

    length = len_trim(line)
    i = 1
    in_single_quotes = .false.
    in_double_quotes = .false.
    loop: do
       if (in_single_quotes) then
          if (line(i:i) == "'") in_single_quotes = .false.
       else if (in_double_quotes) then
          if (line(i:i) == '"') in_double_quotes = .false.
       else
          select case (line(i:i))
          case ("'")
             in_single_quotes = .true.
          case ('"')
             in_double_quotes = .true.
          case ("!")
             i = i - 1
             exit loop
          end select
       end if
       if (i >= length) exit loop
       i = i + 1
    end do loop
    line = line(1:i)
  end subroutine strip_comments

  subroutine init_input_unit (open_it)
    ! <doc> open the input file, strip out any comments and
    !  write them into the file '''''.'''run_name.in''. Check
    ! for includes, read any lines from the includes, strip
    ! any comments from them and add them to the same file.
    ! </doc>
    implicit none
    logical, intent (in) :: open_it
    integer :: in_unit, out_unit, iostat
    character(500) :: line
    integer :: ind_slash    !To hold position of slash in run_name
    ! for includes
    integer, parameter :: stack_size = 10
    integer, dimension (stack_size) :: stack
    integer :: stack_ptr

    if (.not. open_it) then
       input_unit_no = -1
       return
    end if

    call get_unused_unit (in_unit)
    open (unit=in_unit, file=trim(run_name)//".in", status="old", &
         action="read", iostat=iostat)
    if (iostat /= 0) then
       print "(a)", "Couldn't open input file: "//trim(run_name)//".in"
    end if

    call get_unused_unit (out_unit)
!    open (unit=out_unit, status="scratch", action="readwrite")
    !Determine if '/' is in input name and if so what position
    !in the string is the last one (i.e. split run_name into path_to_file and file)
    ind_slash=index(run_name,"/",.True.)
    if (ind_slash.EQ.0) then !No slash in name
        !Original behaviour
        open (unit=out_unit, file="."//trim(run_name)//".in")
    else
        !General behaviour
        open (unit=out_unit, file=trim(run_name(1:ind_slash))//"."//trim(run_name(ind_slash+1:))//".in")
    endif

    iostat = 0
    stack_ptr = 0
    num_input_lines = 0
    do
       read (unit=in_unit, fmt="(a)", iostat=iostat) line
       if (iostat /= 0) then
          if (stack_ptr <= 0) exit
          close (unit=in_unit)
          iostat = 0
          in_unit = stack(stack_ptr)
          stack_ptr = stack_ptr - 1
          cycle
       end if
       if (line(1:9) == "!include ") then
          if (stack_ptr >= stack_size) then
             print "(a)", "!include ignored: nesting too deep: "//trim(line)
             cycle
          end if
          stack_ptr = stack_ptr + 1
          stack(stack_ptr) = in_unit
          call get_unused_unit (in_unit)
          open (unit=in_unit, file=trim(line(10:)), status="old", &
                action="read", iostat=iostat)
          if (iostat /= 0) then
             print "(a)", "!include ignored: file unreadable: "//trim(line)
             in_unit = stack(stack_ptr)
             stack_ptr = stack_ptr - 1
             cycle
          end if
          cycle
       end if
       call strip_comments (line)
       write (unit=out_unit, fmt="(a)") trim(line)
       num_input_lines = num_input_lines + 1
    end do
    close (unit=in_unit)

    input_unit_no = out_unit
  end subroutine init_input_unit

  subroutine finish_file_utils
    implicit none
    if (input_unit_no > 0) then
       close (unit=input_unit_no)
       input_unit_no = -1
    end if
    if (error_unit_no > 0 .and. error_unit_no /= 6) then
       close (unit=error_unit_no)
       error_unit_no = stdout_unit
    end if
    initialized = .false.
  end subroutine finish_file_utils

  function input_unit (nml)
    implicit none
    character(*), intent (in) :: nml
    integer :: input_unit, iostat
    character(500) :: line
    intrinsic adjustl, trim
    input_unit = input_unit_no
    if (input_unit_no > 0) then
       rewind (unit=input_unit_no)
       do
          read (unit=input_unit_no, fmt="(a)", iostat=iostat) line
          if (iostat /= 0) then
             rewind (unit=input_unit_no)
             exit
          end if
          if (trim(adjustl(line)) == "&"//nml) then
             backspace (unit=input_unit_no)
             return
          end if
       end do
    end if
    write (unit=error_unit_no, fmt="('Couldn''t find namelist: ',a)") nml
    write (unit=*, fmt="('Couldn''t find namelist: ',a)") nml
  end function input_unit

  function input_unit_exist (nml,exist)
    implicit none
    character(*), intent (in) :: nml
    logical, intent(out) :: exist
    integer :: input_unit_exist, iostat
    character(500) :: line
    intrinsic adjustl, trim
    input_unit_exist = input_unit_no
    exist = .true.
    if (input_unit_no > 0) then
       rewind (unit=input_unit_no)
       do
          read (unit=input_unit_no, fmt="(a)", iostat=iostat) line
          if (iostat /= 0) then
             rewind (unit=input_unit_no)
             exit
          end if
          if (trim(adjustl(line)) == "&"//nml) then
             backspace (unit=input_unit_no)
             return
          end if
       end do
    end if
    exist = .false.
  end function input_unit_exist

  function error_unit ()
    implicit none
    integer :: error_unit
    error_unit = error_unit_no
  end function error_unit

  subroutine get_input_unit (unit)
    implicit none
    integer, intent (out) :: unit

    unit = input_unit_no

  end subroutine get_input_unit

  subroutine get_indexed_namelist_unit (unit, nml, index_in)
    implicit none
    integer, intent (out) :: unit
    character (*), intent (in) :: nml
    integer, intent (in) :: index_in
    character(500) :: line
    integer :: iunit, iostat, in_file
    integer :: ind_slash
    logical :: exist

    call get_unused_unit (unit)
!    open (unit=unit, status="scratch", action="readwrite")

    !Determine if '/' is in input name and if so what position
    !in the string is the last one (i.e. split run_name into path_to_file and file)
    ind_slash=index(run_name,"/",.True.)
    if (ind_slash.EQ.0) then !No slash in name
        !Original behaviour
        open (unit=unit, file="."//trim(run_name)//".scratch")
    else
        !General behaviour
        open (unit=unit, file=trim(run_name(1:ind_slash))//"."//trim(run_name(ind_slash+1:))//".scratch")
    endif

    write (line, *) index_in
    line = nml//"_"//trim(adjustl(line))
    in_file = input_unit_exist(trim(line), exist)
    if (exist) then
       iunit = input_unit(trim(line))
    else
       write(6,*) "get_indexed_namelist: following namelist not found ",trim(line)
       return
    end if

    read (unit=iunit, fmt="(a)") line
    write (unit=unit, fmt="('&',a)") nml

    do
       read (unit=iunit, fmt="(a)", iostat=iostat) line
       if (iostat /= 0 .or. trim(adjustl(line)) == "/") exit
       write (unit=unit, fmt="(a)") trim(line)
    end do
    write (unit=unit, fmt="('/')")
    rewind (unit=unit)
  end subroutine get_indexed_namelist_unit
end module file_utils
