module fields_implicit
  implicit none

  private
 
  public :: init_fields_implicit
  public :: advance_implicit
  public :: remove_zonal_flows
  public :: init_allfields_implicit
  public :: reset_init
  public :: field_subgath, dump_response, read_response
  public :: dump_response_to_file_imp
  
  public :: timer_aminv_row ! NDCTESTtime
  public :: timer_aminv_tadv ! NDCTESTtime
  public :: timer_aminv_fieldeq ! NDCTESTtime
  public :: timer_interp_tdep ! NDCTESTtime
  public :: timer_interp_wdrift ! NDCTESTtime
  public :: timer_interp_abr ! NDCTESTtime
  public :: timer_interp_row ! NDCTESTtime
  public :: timer_interp_tadv ! NDCTESTtime
  public :: timer_interp_fieldeq ! NDCTESTtime
  public :: timer_interp_invert ! NDCTESTtime
  public :: timer_interp_alloc ! NDCTESTtime
  public :: timer_tadv_tdep ! NDCTESTtime
  public :: timer_tadv_wdrift ! NDCTESTtime
  public :: timer_tadv_abr ! NDCTESTtime

  !> Unit tests
  public :: fields_implicit_unit_test_init_fields_implicit

!///////////////////////////////////////////////////////
!// DERIVED TYPES FOR FIELD MATRIX REPRESENTATION
!///////////////////////////////////////////////////////

  !////////////////////////////////////////////////////////////////
  !// DCELL : 
  ! Within each supercell, there are are N_class primary cells.  Each 
  ! has (2*ntgrid+1)*nfield points.
  type dcell_type
     complex, dimension(:), pointer :: supercell => null()
  end type dcell_type
  !----------------------------------------------------------------

  ! Within each class, there may be multiple supercells.

  ! The number of supercells in each class is M_class.
  
  ! When aminv is laid out over PEs, the supercells of each class 
  ! are distributed -- thus, "dcells"
  
  !////////////////////////////////////////////////////////////////
  !// FIELD_MATRIX_TYPE : 
  type :: field_matrix_type
     type(dcell_type), dimension (:), pointer :: dcell => null()
  end type field_matrix_type
  !----------------------------------------------------------------

  !////////////////////////////////////////////////////////////////
  !// AMINV :
  ! There may be supercells of different sizes or "classes".  
  type (field_matrix_type), dimension (:), allocatable :: aminv
  !----------------------------------------------------------------
!-------------------------------------------------------

  type (field_matrix_type), dimension (:), allocatable :: aminv_left
  type (field_matrix_type), dimension (:), allocatable :: aminv_right

  !> A variable to help with running benchmarks... do not set true
  !! unless you know what you are doing. If true, the response matrix
  !! will not be initialised and set to zero. The results of any 
  !! simulation will be garbage
  logical, public :: skip_initialisation = .false.

  integer :: nfield, nidx
  logical :: initialized = .false.
  logical :: linked = .false.
  logical :: field_subgath
  logical :: dump_response=.false., read_response=.false.
  integer, dimension(:), allocatable :: recvcnts, displs
  
  real :: timer_aminv_row(2) = 0. ! NDCTESTtime
  real :: timer_aminv_tadv(2) = 0. ! NDCTESTtime
  real :: timer_aminv_fieldeq(2) = 0. ! NDCTESTtime
  real :: timer_interp_tdep(2) = 0. ! NDCTESTtime
  real :: timer_interp_wdrift(2) = 0. ! NDCTESTtime
  real :: timer_interp_abr(2) = 0. ! NDCTESTtime
  real :: timer_interp_row(2) = 0. ! NDCTESTtime
  real :: timer_interp_tadv(2) = 0. ! NDCTESTtime
  real :: timer_interp_fieldeq(2) = 0. ! NDCTESTtime
  real :: timer_interp_invert(2) = 0. ! NDCTESTtime
  real :: timer_interp_alloc(2) = 0. ! NDCTESTtime
  real :: timer_tadv_tdep(2) = 0. ! NDCTESTtime
  real :: timer_tadv_wdrift(2) = 0. ! NDCTESTtime
  real :: timer_tadv_abr(2) = 0. ! NDCTESTtime
  logical :: trigger_timer_aminv = .true. ! NDCTESTtime
  logical :: trigger_timer_interp = .false. ! NDCTESTtime

  ! NDCTESTinv
  type noninv_field_matrix_type
      complex, dimension(:,:), pointer :: am => null()
      complex, dimension(:,:), pointer :: am_left => null()
      complex, dimension(:,:), pointer :: am_right => null()
      complex, dimension(:,:), pointer :: am_interp => null()
  end type noninv_field_matrix_type
  type (noninv_field_matrix_type), dimension(:), allocatable :: amcollec

contains

  subroutine init_fields_implicit
    use antenna, only: init_antenna
    use theta_grid, only: init_theta_grid
    use kt_grids, only: init_kt_grids
    use gs2_layouts, only: init_gs2_layouts
    use run_parameters, only: fphi, fapar, fbpar
    use unit_tests, only: should_print
    use mp, only: mp_abort
!    use parameter_scan_arrays, only: run_scan
    implicit none

    logical :: debug=.false.
    logical :: remap_plot=.false. ! NDCTESTremap_plot

    if (initialized) return
    initialized = .true.

    debug = should_print(3)

    !Check we have at least one field. If not abort.
    !Note, we do this here rather than as soon as we read input file
    !as other field types may support operation with no fields (e.g. 'local' does)
    if((fphi.lt.epsilon(0.0)).and.(fapar.lt.epsilon(0.0)).and.(fbpar.lt.epsilon(0.0)))then
       call mp_abort("Field_option='implicit' requires at least one field is non-zero",.true.)
    endif

    if (debug) write(6,*) "init_fields_implicit: gs2_layouts"
    call init_gs2_layouts
    if (debug) write(6,*) "init_fields_implicit: theta_grid"
    call init_theta_grid
    if (debug) write(6,*) "init_fields_implicit: kt_grids"
    call init_kt_grids
 !   if (debug .and. run_scan) &
 !       write(6,*) "init_fields_implicit: set_scan_parameter"
        ! Must be done before resp. m.
        !if (run_scan) call set_scan_parameter(dummy)
    if (debug) write(6,*) "init_fields_implicit: response_matrix"
    ! NDCTESTremap_plot
    if(.not. remap_plot) then
        call init_response_matrix
    end if
    if (debug) write(6,*) "init_fields_implicit: antenna"
    call init_antenna
  end subroutine init_fields_implicit

  function fields_implicit_unit_test_init_fields_implicit()
    implicit none
    logical :: fields_implicit_unit_test_init_fields_implicit

    call init_fields_implicit
    fields_implicit_unit_test_init_fields_implicit = .true.
  end function fields_implicit_unit_test_init_fields_implicit

  subroutine init_allfields_implicit(gf_lo)
    use fields_arrays, only: phi, apar, bpar, phinew, aparnew, bparnew
    use dist_fn_arrays, only: g, gnew
    use dist_fn, only: get_init_field
    use init_g, only: new_field_init
    use mp, only: iproc
    ! NDCTESTremap_plot
    use kt_grids, only: akx, aky, naky, ntheta0
    use constants, only: pi
    use gs2_layouts, only: g_lo,ik_idx,it_idx
    ! endNDCTESTremap_plot

    implicit none

    logical, optional :: gf_lo
    logical :: local_gf_lo
    ! NDCTESTremap_plot
    logical :: remap_plot=.false.
    real :: dkx, dky, alpha_x, alpha_y
    integer :: ik, it,iglo
    ! endNDCTESTremap_plot

    if(present(gf_lo)) then
      local_gf_lo = gf_lo
    else
      local_gf_lo = .false.
    end if

    ! MAB> new field init option ported from agk
    if(local_gf_lo) then
       call get_init_field (phinew, aparnew, bparnew, .true.)
       !AJ Note, we do not initialise phi, apar, and bpar here 
       !AJ as this is now done in fields_gf_local along with a 
       !AJ fields redistribute.
       g = gnew
    else if (new_field_init) then
       ! NDCTESTremap_plot
       if(remap_plot) then
           write(*,*) 'Initializing phi to Gaussian'
           dkx = akx(2)-akx(1)
           dky = aky(2)-aky(1)
           alpha_x = 1./64. * (2.*pi/dkx)**2 ! -> exp(-x**2/sig_x**2) with sig_x = 2*sqrt(alpha_x) = Lx
           alpha_y = 1./256. * (2.*pi/dky)**2 ! -> exp(-y**2/sig_y**2) with sig_y = 2*sqrt(alpha_y) = Ly

           ! Gaussian in phi
           do ik = 1, naky
               do it = 1, ntheta0
                   phinew(:,it,ik) = 100*exp(-1.*alpha_x*(akx(it)**2))*exp(-1.*alpha_y*(aky(ik)**2))
               end do
           end do
           phi = phinew

           ! Gaussian in g
           do iglo = g_lo%llim_proc, g_lo%ulim_proc
               ik = ik_idx(g_lo,iglo)
               it = it_idx(g_lo,iglo)
               gnew(:,:,iglo) = exp(-1.*alpha_y*(akx(it)**2))*exp(-1.*alpha_x*(aky(ik)**2))
           end do
           g = gnew
       else
           call get_init_field (phinew, aparnew, bparnew)
           phi = phinew; apar = aparnew; bpar = bparnew; g = gnew
       end if
    else
       call getfield (phinew, aparnew, bparnew)
       phi = phinew; apar = aparnew; bpar = bparnew 
    end if
    ! <MAB

  end subroutine init_allfields_implicit

  subroutine get_field_vector (fl, phi, apar, bpar, expflow_opt)
    use theta_grid, only: ntgrid
    use kt_grids, only: naky, ntheta0
    use dist_fn, only: getfieldeq
    use run_parameters, only: fphi, fapar, fbpar
    use prof, only: prof_entering, prof_leaving
    implicit none
    complex, dimension (-ntgrid:,:,:), intent (in) :: phi, apar, bpar
    complex, dimension (:,:,:), intent (out) :: fl
    complex, dimension (:,:,:), allocatable :: fieldeq, fieldeqa, fieldeqp
    integer, intent(in), optional :: expflow_opt
    integer :: istart, ifin

    call prof_entering ("get_field_vector", "fields_implicit")

    allocate (fieldeq (-ntgrid:ntgrid,ntheta0,naky))
    allocate (fieldeqa(-ntgrid:ntgrid,ntheta0,naky))
    allocate (fieldeqp(-ntgrid:ntgrid,ntheta0,naky))

    if(present(expflow_opt)) then
        call getfieldeq (phi, apar, bpar, fieldeq, fieldeqa, fieldeqp, expflow_opt)
    else
        call getfieldeq (phi, apar, bpar, fieldeq, fieldeqa, fieldeqp)
    end if

    ifin = 0

    if (fphi > epsilon(0.0)) then
       istart = ifin + 1
       ifin = (istart-1) + 2*ntgrid+1
       fl(istart:ifin,:,:) = fieldeq
    end if

    if (fapar > epsilon(0.0)) then
       istart = ifin + 1
       ifin = (istart-1) + 2*ntgrid+1
       fl(istart:ifin,:,:) = fieldeqa
    end if

    if (fbpar > epsilon(0.0)) then
       istart = ifin + 1
       ifin = (istart-1) + 2*ntgrid+1
       fl(istart:ifin,:,:) = fieldeqp
    end if

    deallocate (fieldeq, fieldeqa, fieldeqp)

    call prof_leaving ("get_field_vector", "fields_implicit")
  end subroutine get_field_vector

  subroutine get_field_solution (u)
    use fields_arrays, only: phinew, aparnew, bparnew
    use theta_grid, only: ntgrid
    use kt_grids, only: naky, ntheta0
    use run_parameters, only: fphi, fapar, fbpar
    use gs2_layouts, only: jf_lo, ij_idx
    use prof, only: prof_entering, prof_leaving
    implicit none
    complex, dimension (0:), intent (in) :: u
    integer :: ik, it, ifield, ll, lr

    call prof_entering ("get_field_solution", "fields_implicit")

    ifield = 0

    if (fphi > epsilon(0.0)) then
       ifield = ifield + 1
       do ik = 1, naky
          do it = 1, ntheta0
             ll = ij_idx (jf_lo, -ntgrid, ifield, ik, it)
             lr = ll + 2*ntgrid
             phinew(:,it,ik) = u(ll:lr)
          end do
       end do
    endif

    if (fapar > epsilon(0.0)) then
       ifield = ifield + 1
       do ik = 1, naky
          do it = 1, ntheta0
             ll = ij_idx (jf_lo, -ntgrid, ifield, ik, it)
             lr = ll + 2*ntgrid
             aparnew(:,it,ik) = u(ll:lr)
          end do
       end do
    endif

    if (fbpar > epsilon(0.0)) then
       ifield = ifield + 1
       do ik = 1, naky
          do it = 1, ntheta0
             ll = ij_idx (jf_lo, -ntgrid, ifield, ik, it)
             lr = ll + 2*ntgrid
             bparnew(:,it,ik) = u(ll:lr)
          end do
       end do
    endif

    call prof_leaving ("get_field_solution", "fields_implicit")
  end subroutine get_field_solution

  subroutine getfield (phi, apar, bpar)
    use kt_grids, only: naky, ntheta0, akx, aky, &
        explicit_flowshear, implicit_flowshear, mixed_flowshear, interp_before
    use gs2_layouts, only: f_lo, jf_lo, ij, mj, dj, it_idx, ig_idx, in_idx, im_idx
    use prof, only: prof_entering, prof_leaving
    use fields_arrays, only: time_field
    use theta_grid, only: ntgrid
    use dist_fn, only: N_class, i_class
    use mp, only: sum_allreduce, allgatherv, iproc,nproc, proc0
    use job_manage, only: time_message
    use dist_fn_arrays, only: kx_shift
    implicit none
    complex, dimension (-ntgrid:,:,:), intent (in) :: phi, apar, bpar
    complex, dimension (:,:,:), allocatable :: fl
    complex, dimension (:), allocatable :: u
    complex, dimension (:), allocatable :: u_small
    integer :: jflo, ik, it, nl, nr, i, m, n, dc, ic, iflo
    real :: dkx
    integer :: ig_nosum, it_nosum = 0 ! NDCTEST
    integer :: expflow_opt
    logical :: michael_exp = .false. ! NDCTESTswitchexp

    if (proc0) call time_message(.false.,time_field,' Field Solver')

    call prof_entering ("getfield", "fields_implicit")
    allocate (fl(nidx, ntheta0, naky))

    !On first call to this routine setup the receive counts (recvcnts)
    !and displacement arrays (displs)
    if ((.not.allocated(recvcnts)).and.field_subgath) then
       allocate(recvcnts(nproc),displs(nproc)) !Note there's no matching deallocate
       do i=0,nproc-1
          displs(i+1)=MIN(i*jf_lo%blocksize,jf_lo%ulim_world+1) !This will assign a displacement outside the array for procs with no data
          recvcnts(i+1)=MIN(jf_lo%blocksize,jf_lo%ulim_world-displs(i+1)+1) !This ensures that we expect no data from procs without any
       enddo
    endif

    ! new flowshear implementations are only used if ntheta0 > 1
    if(implicit_flowshear .or. mixed_flowshear) then
        dkx = akx(2)-akx(1)
    
        if(interp_before) then
            do ic = i_class, 1, -1
                do iflo = f_lo(ic)%llim_proc, f_lo(ic)%ulim_proc
                    n = in_idx(f_lo(ic),iflo)
                    m = im_idx(f_lo(ic),iflo)
                    ik = f_lo(ic)%ik(m,n)

                    ! NDCTESTinv: quadratic Lagrange interp. at kx +- 0.5*dkx
                    !amcollec(ic)%am_interp(:,iflo) = &
                    !    kx_shift(ik)*(kx_shift(ik)-dkx/2.)/(dkx*dkx/2.) * amcollec(ic)%am_left(:,iflo) &
                    !    - (kx_shift(ik)+dkx/2.)*(kx_shift(ik)-dkx/2.)/(dkx*dkx/4.) * amcollec(ic)%am(:,iflo) &
                    !    + kx_shift(ik)*(kx_shift(ik)+dkx/2.)/(dkx*dkx/2.) * amcollec(ic)%am_right(:,iflo)

                    ! linear interp. at kx +- dkx
                    !amcollec(ic)%am_interp(:,iflo) = &
                    !    (1.-sign(1.,kx_shift(ik)))/2. * abs(kx_shift(ik))/dkx * amcollec(ic)%am_left(:,iflo) &
                    !    + (dkx-abs(kx_shift(ik)))/dkx * amcollec(ic)%am(:,iflo) &
                    !    +(1.+sign(1.,kx_shift(ik)))/2. * abs(kx_shift(ik))/dkx * amcollec(ic)%am_right(:,iflo)

                    ! NDCTESTinv: linear interp. at kx +- 0.5*dkx
                    amcollec(ic)%am_interp(:,iflo) = &
                        (1.-sign(1.,kx_shift(ik)))/2.* abs(kx_shift(ik))/(dkx/2.) * amcollec(ic)%am_left(:,iflo) &
                        + (dkx/2.-abs(kx_shift(ik)))/(dkx/2.) * amcollec(ic)%am(:,iflo) &
                        + (1.+sign(1.,kx_shift(ik)))/2. * abs(kx_shift(ik))/(dkx/2.) * amcollec(ic)%am_right(:,iflo)
                end do
                call init_inverse_matrix(amcollec(ic)%am_interp, aminv, ic)
            end do
        end if
    end if

    ! am*u = fl, Poisson's and Ampere's law, u is phi, apar, bpar 
    ! u = aminv*fl

    ! Modified field equation for explicit flowshear implementation
    ! necessary to make aminv time independent. -- NDC 02/2018
    if(explicit_flowshear) then
        if(michael_exp) then
            ! NDCTESTmichael
            call get_field_vector (fl, phi, apar, bpar)
        else
            ! NDCTESTfelix
            expflow_opt = 1
            call get_field_vector (fl, phi, apar, bpar, expflow_opt)
        end if
    else
        call get_field_vector (fl, phi, apar, bpar)
    end if

    !Initialise array, if not gathering then have to zero entire array
    if(field_subgath) then
       allocate(u_small(jf_lo%llim_proc:jf_lo%ulim_proc))
    else
       allocate(u_small(0:nidx*ntheta0*naky-1))
    endif
    u_small=0.

    !Should this really be to ulim_alloc instead?
    do jflo = jf_lo%llim_proc, jf_lo%ulim_proc
       
       !Class index
       i = ij(jflo)
       
       !Class member index (i.e. which member of the class)
       m = mj(jflo)

       !Get ik index
       ik = f_lo(i)%ik(m,1)  ! For fixed i and m, ik does not change as n varies 

       !Get d(istributed) cell index
       dc = dj(i,jflo)
       
       !Loop over cells in class (these are the 2pi domains in flux tube/box mode)
       do n = 1, N_class(i)
          
          !Get it index
          it = f_lo(i)%it(m,n)
          
          !Get extent of current cell in extended/ballooning space domain
          nl = 1 + nidx*(n-1)
          nr = nl + nidx - 1
          
          !Perform section of matrix vector multiplication
          !
          ! For flow-shear cases, use quadratic Lagrange interpolation
          ! to compute time-dependent aminv --NDC 11/2017
          if((implicit_flowshear .or. mixed_flowshear) .and. .not. interp_before) then
              !u_small(jflo) = u_small(jflo) - sum( fl(:,it,ik) * & ! NDCTEST quadratic
              !    ( kx_shift(ik)*(kx_shift(ik)-dkx)/(2.*dkx*dkx) * aminv_left(i)%dcell(dc)%supercell(nl:nr) & ! NDCTEST
              !    - (kx_shift(ik)+dkx)*(kx_shift(ik)-dkx)/(dkx*dkx) * aminv(i)%dcell(dc)%supercell(nl:nr) & ! NDCTEST
              !    + kx_shift(ik)*(kx_shift(ik)+dkx)/(2.*dkx*dkx) * aminv_right(i)%dcell(dc)%supercell(nl:nr) ) ) ! NDCTEST
              
              !u_small(jflo) = u_small(jflo) - sum( fl(:,it,ik) * & ! NDCTEST linear
              !    ( (1.-sign(1.,kx_shift(ik)))/2.* abs(kx_shift(ik))/dkx * aminv_left(i)%dcell(dc)%supercell(nl:nr) &
              !    + (dkx-abs(kx_shift(ik)))/dkx * aminv(i)%dcell(dc)%supercell(nl:nr) &
              !    + (1.+sign(1.,kx_shift(ik)))/2. * abs(kx_shift(ik))/dkx * aminv_right(i)%dcell(dc)%supercell(nl:nr) ) )
              
              u_small(jflo) = u_small(jflo) - sum( fl(:,it,ik) * & ! NDCTEST shifted by +/-0.5*dkx
                  ( (1.-sign(1.,kx_shift(ik)))/2.* abs(kx_shift(ik))/(dkx/2.) * aminv_left(i)%dcell(dc)%supercell(nl:nr) &
                  + (dkx/2.-abs(kx_shift(ik)))/(dkx/2.) * aminv(i)%dcell(dc)%supercell(nl:nr) &
                  + (1.+sign(1.,kx_shift(ik)))/2. * abs(kx_shift(ik))/(dkx/2.) * aminv_right(i)%dcell(dc)%supercell(nl:nr) ) )
          else
              u_small(jflo)=u_small(jflo)-sum(aminv(i)%dcell(dc)%supercell(nl:nr)*fl(:, it, ik))
          end if
          
          ! it_nosum = it_idx(jf_lo, jflo) ! NDCTEST
          ! ig_nosum = ig_idx(jf_lo, jflo) ! NDCTEST
          ! if (ik==2 .and. ig_nosum==0 .and. it==it_nosum) then ! NDCTEST
          !     write(*,*) akx(it_nosum), ' ', realpart(aminv_left(i)%dcell(dc)%supercell(ntgrid+1+nidx*(n-1))), ' ', & ! NDCTEST
          !         realpart(aminv(i)%dcell(dc)%supercell(ntgrid+1+nidx*(n-1))), ' ', & ! NDCTEST
          !         realpart(aminv_right(i)%dcell(dc)%supercell(ntgrid+1+nidx*(n-1))) ! NDCTEST
          ! end if ! NDCTEST

       end do

    end do

    !Free memory
    deallocate (fl)

    !Gather/reduce the remaining data
    if(field_subgath) then
       allocate (u (0:nidx*ntheta0*naky-1))
       call allgatherv(u_small,recvcnts(iproc+1),u,recvcnts,displs)
       deallocate(u_small)
    else
       call sum_allreduce(u_small)
    endif

    !Reshape data into field arrays and free memory
    if(field_subgath)then
       call get_field_solution (u)
       deallocate(u)
    else
       call get_field_solution (u_small)
       deallocate(u_small)
    endif

    !For profiling
    call prof_leaving ("getfield", "fields_implicit")

    !For timing
    if (proc0) call time_message(.false.,time_field,' Field Solver')

  end subroutine getfield

  subroutine advance_implicit (istep, remove_zonal_flows_switch)
    use run_parameters, only: reset
    use fields_arrays, only: phi, apar, bpar, phinew, aparnew, bparnew, &
        phistar_old, phistar_new ! NDCTESTmichaelnew
    use fields_arrays, only: apar_ext
    use antenna, only: antenna_amplitudes, no_driver
    use dist_fn, only: timeadv, exb_shear, collisions_advance, &
        update_kperp2_tdep, update_aj0_tdep, update_gamtot_tdep, &
        gamtot, getan ! NDCTESTmichael
    use dist_fn, only: g_exb, & ! NDCTESTremap_plot
        first_gk_solve, compute_a_b_r_ainv ! NDCTESTneighb
    use dist_fn_arrays, only: g, gnew, kx_shift, theta0_shift, &
        gamtot_tdep, & ! NDCTESTmichael
        a, b, r, ainv ! NDCTESTneighb
    use unit_tests, only: debug_message
    use mp, only: iproc
    use kt_grids, only: explicit_flowshear, implicit_flowshear, mixed_flowshear, &
        naky, ntheta0 ! NDCTESTmichael
    use kt_grids, only: nx, ny, akx, aky ! NDCTESTremap_plot
    use theta_grid, only: ntgrid ! NDCTESTmichael
    use mp, only: proc0 ! NDCTEST
    use job_manage, only: time_message ! NDCTESTtime
    use gs2_layouts, only: g_lo, yxf_lo, ig_idx, it_idx, ik_idx, isign_idx, is_idx, ie_idx, il_idx ! NDCTESTremap_plot
    use gs2_transforms, only: transform2, update_flowshear_phase_fac, init_transforms ! NDCTESTremap_plot
    use constants, only: pi ! NDCTESTremap_plot
    use le_grids, only: nlambda, negrid ! NDCTESTremap_plot
    use species, only: nspec ! NDCTESTremap_plot
    !use gs2_layouts, only: g_lo, idx ! NDCTESTdist
    implicit none
    integer :: diagnostics = 1
    integer, intent (in) :: istep
    logical, intent (in) :: remove_zonal_flows_switch
    integer, parameter :: verb=4
    !integer :: expflow_opt, ig, it, ik ! NDCTESTmichael
    !complex, dimension(:,:,:), allocatable :: expflow_antot, expflow_antot_tdep ! NDCTESTmichael
    !complex, dimension(:,:,:), allocatable :: dummy1, dummy2, phistar ! NDCTESTmichael
    integer :: expflow_opt, ig, it, ik ! NDCTESTmichaelnew
    complex, dimension(:,:,:), allocatable :: expflow_antot, expflow_antot_tdep ! NDCTESTmichaelnew
    complex, dimension(:,:,:), allocatable :: dummy1, dummy2 ! NDCTESTmichaelnew
    !integer :: isgn, il, ie, is, iglo ! NDCTESTdist
    !character(len=20) :: my_format ! NDCTESTdist
    ! NDCTESTremap_plot
    logical :: remap_plot_shear=.false.
    logical :: remap_plot_nl=.false.
    integer :: iglo,iy,ix,ie,il,is,isgn,iyxf
    real, dimension(:,:), allocatable :: fft_out
    complex, dimension(:,:,:), allocatable :: phi_5d
    character(5) :: istep_str
    ! endNDCTESTremap_plot
    logical :: michael_exp = .false. ! NDCTESTswitchexp
    
    ! NDCTESTremap_plot
    if(remap_plot_shear .or. remap_plot_nl) then
        write(istep_str,"(I0)") istep
        if(explicit_flowshear .or. implicit_flowshear .or. mixed_flowshear) then
            open(83,file="/home/christenl/data/gs2/flowtest/nonlin/nlfelix2/test_xy_"//trim(istep_str)//"_g_exb.dat",status="replace")
        else
            open(83,file="/home/christenl/data/gs2/flowtest/nonlin/nlfelix2/test_xy_"//trim(istep_str)//"_old.dat",status="replace")
        end if
    end if
    ! end NDCTESTremap_plot

    !GGH NOTE: apar_ext is initialized in this call
    if(.not.no_driver) call antenna_amplitudes (apar_ext)
  
    ! NDCQUEST: how is the ExB remap undone if the timestep needs to be re-set ?    
    if (allocated(kx_shift) .or. allocated(theta0_shift)) call exb_shear (gnew, phinew, aparnew, bparnew, istep) 
        
    g = gnew
    phi = phinew
    apar = aparnew 
    bpar = bparnew       

    ! NDCTESTremap_plot
    if(remap_plot_shear) then
        call update_flowshear_phase_fac(g_exb)
        ! copy phi to 5d array to use modified transform routines
        write(*,*) 'Copying phi to 5d array.'
        allocate(phi_5d(-ntgrid:ntgrid,2,g_lo%llim_proc:g_lo%ulim_alloc))
        phi_5d = 0.
        do iglo = g_lo%llim_proc, g_lo%ulim_proc
            it = it_idx(g_lo,iglo)
            ik = ik_idx(g_lo,iglo)
            do ig = -ntgrid, ntgrid
               phi_5d(ig,1,iglo) = phi(ig,it,ik)
               phi_5d(ig,2,iglo) = phi(ig,it,ik)
            end do
        end do
        
        allocate(fft_out(ny,yxf_lo%llim_proc:yxf_lo%ulim_alloc))
        fft_out = 0.

        call transform2(phi_5d,fft_out)
                
        deallocate(phi_5d,fft_out)

    elseif(remap_plot_nl) then

        ! time stepping to evolve g
        call timeadv(phi, apar, bpar, phinew, aparnew, bparnew, istep)

    end if
    ! endNDCTESTremap_plot
    
    if(.not. (remap_plot_shear .or. remap_plot_nl)) then ! NDCTESTremap_plot: remove if statement and align correctly all its content.
        ! In cases with flow-shear, after kx_shift got updated in exb_shear,
        ! update time-dependent kperp2, aj0, gamtot, wdrift, wdriftttp, a, b, r, ainv.
        ! NDC 02/2018
        ! NDCQUEST: how do we deal with this updating if time-step has to be re-set ?
        if(explicit_flowshear .or. implicit_flowshear .or. mixed_flowshear) then
            
            if (proc0) call time_message(.false.,timer_tadv_tdep,' Tadv_tdep') ! NDCTESTtime
            
            call update_kperp2_tdep
            call update_aj0_tdep
            call update_gamtot_tdep
            
            if (proc0) call time_message(.false.,timer_tadv_tdep,' Tadv_tdep') ! NDCTESTtime
            
        end if

        if(implicit_flowshear) then
            
            if (proc0) call time_message(.false.,timer_tadv_abr,' Tadv_rhs') ! NDCTESTtime
            
            call compute_a_b_r_ainv(a,b,r,ainv) ! NDCTESTneighb
            
            if (proc0) call time_message(.false.,timer_tadv_abr,' Tadv_rhs') ! NDCTESTtime
            
        end if

        ! NDCTESTmichaelnew: compute phistar[it]
        if(explicit_flowshear .and. michael_exp) then

            !deallocate is further down in this subroutine
            allocate(expflow_antot(-ntgrid:ntgrid,ntheta0,naky))
            allocate(expflow_antot_tdep(-ntgrid:ntgrid,ntheta0,naky))
            allocate(dummy1(-ntgrid:ntgrid,ntheta0,naky))
            allocate(dummy2(-ntgrid:ntgrid,ntheta0,naky))

            expflow_opt = 2
            call getan(expflow_antot, dummy1, dummy2, expflow_opt)
            expflow_opt = 3
            call getan(expflow_antot_tdep, dummy1, dummy2, expflow_opt)

            phistar_old = 0.
            do ig = -ntgrid,ntgrid
                do it = 1,ntheta0
                    do ik = 1,naky
                        if(aky(ik)/=0.) then
                            phistar_old(ig,it,ik) = 1./gamtot_tdep%old(ig,it,ik)*expflow_antot_tdep(ig,it,ik) &
                                -1./gamtot(ig,it,ik)*expflow_antot(ig,it,ik)
                        end if
                    end do
                end do
            end do

        end if
        
        if(explicit_flowshear .and. michael_exp) then
            ! NDCTESTmichaelnew: replace phi[it] and phi[it+1] by phibar[it]
            phi = phi-phistar_old
            phinew = phinew-phistar_old
        end if
            
        call debug_message(4, 'fields_implicit::advance_implicit calling timeadv 1')
        
        ! To apply g_wesson=0 at the boundary correctly in flow shear cases (see dist_fn::invert_rhs_1),
        ! we need to know whether we are solving the GK equation for the first time in this time step or not.
        ! NDC 06/18
        first_gk_solve = .true.

        call timeadv (phi, apar, bpar, phinew, aparnew, bparnew, istep)
        
        first_gk_solve = .false.    
            
        call debug_message(4, 'fields_implicit::advance_implicit called timeadv 1')
        if(reset) return !Return is resetting

        if(.not.no_driver) aparnew = aparnew + apar_ext 
        
        call debug_message(4, 'fields_implicit::advance_implicit calling getfield')

        ! NDCTESTmichaelnew: in flowshear cases, QN returns phibar[it+1]-phibar[it]
        call getfield (phinew, aparnew, bparnew)
        
        ! NDCTESTmichaelnew: in flowshear cases, this sets phinew=phibar[it+1]
        phinew = phinew + phi
        
        ! NDCTESTmichael
        !if(explicit_flowshear) then
        !    phinew   = phinew  + phistar
        !end if
        aparnew  = aparnew + apar
        bparnew  = bparnew + bpar

        ! NDCQUEST: the removal is wrong for now: it is applied to phibar[it+1]
        ! Should we apply it to phibar[it+1] and phistar[it+1] ? In that case there might
        ! be a problem since phistar[it+1] needs the full g[it+1] to be computed ...
        if (remove_zonal_flows_switch) call remove_zonal_flows
        
        call debug_message(4, 'fields_implicit::advance_implicit calling timeadv')
        
        call timeadv (phi, apar, bpar, phinew, aparnew, bparnew, istep, diagnostics)

        ! NDCTESTmichaelnew: compute phistar[it+1] and get the full phi[it] and phi[it+1]
        if(explicit_flowshear .and. michael_exp) then

            expflow_opt = 4
            call getan(expflow_antot, dummy1, dummy2, expflow_opt)
            expflow_opt = 5
            call getan(expflow_antot_tdep, dummy1, dummy2, expflow_opt)

            phistar_new = 0.
            do ig = -ntgrid,ntgrid
                do it = 1,ntheta0
                    do ik = 1,naky
                        if(aky(ik)/=0.) then
                            phistar_new(ig,it,ik) = 1./gamtot_tdep%new(ig,it,ik)*expflow_antot_tdep(ig,it,ik)-1./gamtot(ig,it,ik)*expflow_antot(ig,it,ik)
                        end if
                    end do
                end do
            end do
            
            phinew = phinew + phistar_new
            phi = phi + phistar_old
            
            deallocate(expflow_antot, expflow_antot_tdep, dummy1, dummy2)

        end if
            
        call debug_message(4, 'fields_implicit::advance_implicit called timeadv')

        ! Advance collisions, if separate from timeadv
        call collisions_advance (phi, bpar, phinew, aparnew, bparnew, istep, diagnostics)

    end if ! NDCTESTremap_plot: remove end if

    ! NDCTESTremap_plot
    if(remap_plot_shear .or. remap_plot_nl) then
        close(83)
    end if
    ! endNDCTESTremap_plot

  end subroutine advance_implicit

  subroutine remove_zonal_flows
    use fields_arrays, only: phinew
    use theta_grid, only: ntgrid
    use kt_grids, only: ntheta0, naky
    implicit none
    complex, dimension(:,:,:), allocatable :: phi_avg

    allocate(phi_avg(-ntgrid:ntgrid,ntheta0,naky)) 
    phi_avg = 0.
    ! fieldline_average_phi will calculate the field line average of phinew and 
    ! put it into phi_avg, but only for ik = 1 (the last parameter of the call)
    call fieldline_average_phi(phinew, phi_avg, 1)
    phinew = phinew - phi_avg
    deallocate(phi_avg)
  end subroutine remove_zonal_flows

  !> This generates a field line average of phi_in and writes it to 
  !! phi_average. If ik_only is supplied, it will only calculate the
  !! field line average for that ky, leaving the rest of phi_avg unchanged. EGH
  
  ! It replaces the routines fieldlineavgphi_loc and fieldlineavgphi_tot,
  ! in fields.f90, which I  think are defunct, as phi is always on every processor.
  subroutine fieldline_average_phi (phi_in, phi_average, ik_only)
    use theta_grid, only: ntgrid, drhodpsi, gradpar, bmag, delthet
    use kt_grids, only: ntheta0, naky
    implicit none
    complex, dimension (-ntgrid:,:,:), intent (in) :: phi_in
    complex, dimension (-ntgrid:,:,:), intent (out) :: phi_average
    integer, intent (in), optional :: ik_only
    real, dimension (-ntgrid:ntgrid) :: jac
    complex :: phi_avg_line
    integer it, ik, ik_only_actual
    ik_only_actual = -1
    if (present(ik_only)) ik_only_actual = ik_only

    jac = 1.0/abs(drhodpsi*gradpar*bmag)
    if (ik_only_actual .gt. 0) then
      do it = 1,ntheta0
         phi_avg_line = sum(phi_in(-ntgrid:ntgrid,it,ik_only_actual)* &
            jac(-ntgrid:ntgrid)*delthet(-ntgrid:ntgrid))/ &
            sum(delthet(-ntgrid:ntgrid)*jac(-ntgrid:ntgrid))
           phi_average(:, it, ik_only_actual) = phi_avg_line
      end do
    else
      do it = 1,ntheta0
        do ik = 1,naky
          phi_average(:, it, ik) = sum(phi_in(-ntgrid:ntgrid,it,ik)*jac*delthet)/sum(delthet*jac)
        end do
      end do
    end if

  end subroutine fieldline_average_phi

  subroutine reset_init
    use gs2_layouts, only: finish_jfields_layouts
    ! finish_fields_layouts name conflicts with routine in 
    ! this module
    use gs2_layouts, only: gs2lo_ffl => finish_fields_layouts
    use unit_tests, only: debug_message
    implicit none
    integer :: i, j
    integer, parameter :: verbosity=3
    initialized = .false.

    call debug_message(verbosity, &
      'fields_implicit::reset_init starting')
    if (.not. allocated (aminv)) return
    do i = 1, size(aminv)
       if (.not. associated (aminv(i)%dcell)) cycle
       do j = 1, size(aminv(i)%dcell)
          if (associated (aminv(i)%dcell(j)%supercell)) &
               deallocate(aminv(i)%dcell(j)%supercell)
       end do
       if (associated (aminv(i)%dcell)) deallocate (aminv(i)%dcell)
    end do
    deallocate (aminv)
    
    if (allocated (aminv_left)) then
        do i = 1, size(aminv_left)
           if (.not. associated (aminv_left(i)%dcell)) cycle
           do j = 1, size(aminv_left(i)%dcell)
              if (associated (aminv_left(i)%dcell(j)%supercell)) &
                   deallocate(aminv_left(i)%dcell(j)%supercell)
           end do
           if (associated (aminv_left(i)%dcell)) deallocate (aminv_left(i)%dcell)
        end do
        deallocate (aminv_left)
    end if
    
    if (allocated (aminv_right)) then
        do i = 1, size(aminv_right)
           if (.not. associated (aminv_right(i)%dcell)) cycle
           do j = 1, size(aminv_right(i)%dcell)
              if (associated (aminv_right(i)%dcell(j)%supercell)) &
                   deallocate(aminv_right(i)%dcell(j)%supercell)
           end do
           if (associated (aminv_right(i)%dcell)) deallocate (aminv_right(i)%dcell)
        end do
        deallocate (aminv_right)
    end if

    ! NDCTESTinv
    if(allocated(amcollec)) then
        do i = 1, size(amcollec)
            if(associated(amcollec(i)%am)) then
                deallocate(amcollec(i)%am)
            end if
            if(associated(amcollec(i)%am_left)) then
                deallocate(amcollec(i)%am_left)
            end if
            if(associated(amcollec(i)%am_right)) then
                deallocate(amcollec(i)%am_right)
            end if
            if(associated(amcollec(i)%am_interp)) then
                deallocate(amcollec(i)%am_interp)
            end if
        end do
        deallocate(amcollec)
    end if

    call gs2lo_ffl
    if (allocated(recvcnts)) deallocate(recvcnts, displs)

    call finish_jfields_layouts
  end subroutine reset_init

  subroutine init_response_matrix
    use mp, only: barrier, &
        proc0 ! NDCTESTtime
    use fields_arrays, only: phi, apar, bpar, phinew, aparnew, bparnew
    use theta_grid, only: ntgrid
    use kt_grids, only: naky, ntheta0, implicit_flowshear, mixed_flowshear, interp_before, &
        explicit_flowshear, akx, kperp2_tdep
    use dist_fn_arrays, only: g, kx_shift, &
        a, b, r, ainv ! NDCTESTneighb
    use dist_fn, only: M_class, N_class, i_class, &
        update_kperp2_tdep, update_aj0_tdep, update_gamtot_tdep, compute_a_b_r_ainv
    use run_parameters, only: fphi, fapar, fbpar
    use gs2_layouts, only: init_fields_layouts, f_lo, init_jfields_layouts
    use prof, only: prof_entering, prof_leaving
    use job_manage, only: time_message ! NDCTESTtime
    implicit none
    integer :: ig, ifield, it, ik, i, m, n
    complex, dimension(:,:), allocatable :: am
    complex, dimension(:,:), allocatable :: am_left, am_right
    logical :: endpoint
    real, dimension(:), allocatable :: dkx ! NDCTESTshift
    logical :: tadv_for_interp ! NDCTESTshift
    real, dimension(naky) :: kx_shift_stored ! NDCTESTneighb

    call prof_entering ("init_response_matrix", "fields_implicit")

    nfield = 0
    if (fphi > epsilon(0.0)) nfield = nfield + 1
    if (fapar > epsilon(0.0)) nfield = nfield + 1
    if (fbpar > epsilon(0.0)) nfield = nfield + 1
    nidx = (2*ntgrid+1)*nfield

    call init_fields_layouts (nfield, nidx, naky, ntheta0, M_class, N_class, i_class)
    call init_jfields_layouts (nfield, nidx, naky, ntheta0, i_class)
    call finish_fields_layouts

    !Either read the reponse
    if(read_response) then
        call read_response_from_file_imp
      !elseif(skip_initialisation) then
       !do i = i_class, 1, -1
          !!Pretty sure this barrier is not needed
          !call barrier
          !!       if (proc0) write(*,*) 'beginning class ',i,' with size ',nidx*N_class(i)
          !!Allocate matrix am. First dimension is basically theta along the entire
          !!connected domain for each field. Second dimension is the local section
          !!of the M_class(i)*N_Class(i)*(2*ntgrid+1)*nfield compound domain.
          !!Clearly this will 
          !allocate (am(nidx*N_class(i), f_lo(i)%llim_proc:f_lo(i)%ulim_alloc))


          !!Do we need to zero all 8 arrays on every loop? This can be more expensive than might think.
          !am = 0.0
          !call init_inverse_matrix (am, i)

          !!Free memory
          !deallocate (am)
       !end do
    else
    !or calculate it

!
! keep storage cost down by doing one class at a time
! Note: could define a superclass (of all classes), a structure containing all am, 
! then do this all at once.  This would be faster, especially for large runs in a 
! sheared domain, and could be triggered by local_field_solve 
! 

!<DD> Comments
!A class refers to a class of connected domain.
!These classes are defined by the extent of the connected domain, there can be 
!many members of each class.
!There are i_class classes in total.
!N_class(ic) is a count of how many 2pi domains there are in members of class ic
!M_class(ic) is how many members of class ic there are.
!Sum N_class(ic)*M_class(ic) for ic=1,i_class is naky*ntheta0
!In comments cell refers to a 2pi domain whilst supercell is the connected domain,
!i.e. we have classes of supercells based on the number of cells they contain.
        
       ! For flow-shear cases
       if(implicit_flowshear .or. mixed_flowshear) then
           ! required for shifting in kx during interpolation
           allocate(dkx(naky))
           dkx = (akx(2) - akx(1))
           kx_shift_stored = kx_shift
       end if

       ! In implicit implementation of flow-shear, need to compute different response
       ! matrices dg/dphi for interpolation, whereas in mixed approach only need to compute one.
       ! NDC 02/2018
       if(implicit_flowshear) then
           tadv_for_interp = .true.
       elseif(mixed_flowshear) then
           tadv_for_interp = .false.
       end if
       
       ! Need to store a collection of am's if interpolation is performed before matrix inversion.
       if(interp_before .and. .not. allocated(amcollec) .and. .not. explicit_flowshear) then
           allocate(amcollec(i_class))
       end if

       do i = i_class, 1, -1
          !Pretty sure this barrier is not needed
          call barrier
          !       if (proc0) write(*,*) 'beginning class ',i,' with size ',nidx*N_class(i)
          !Allocate matrix am. First dimension is basically theta along the entire
          !connected domain for each field. Second dimension is the local section
          !of the M_class(i)*N_Class(i)*(2*ntgrid+1)*nfield compound domain.
          !Clearly this will

          ! If the flow-shear interpolation is performed after matrix inversion,
          ! then only need to store temporary am's
          if((.not. interp_before) .or. explicit_flowshear) then
              allocate (am(nidx*N_class(i), f_lo(i)%llim_proc:f_lo(i)%ulim_alloc))
              am = 0.0
          end if

          ! am's for shifted kx's,
          ! required for aminv interpolation in cases with flow-shear --NDC 11/2017
          if(implicit_flowshear .or. mixed_flowshear) then

              if (proc0) call time_message(.false.,timer_interp_alloc,' Init_invert') ! NDCTESTtime
        
              if(interp_before) then
                 
                  if(.not. associated(amcollec(i)%am)) then

                      allocate(amcollec(i)%am(nidx*N_class(i), f_lo(i)%llim_proc:f_lo(i)%ulim_alloc))
                      allocate(amcollec(i)%am_left(nidx*N_class(i), f_lo(i)%llim_proc:f_lo(i)%ulim_alloc))
                      allocate(amcollec(i)%am_right(nidx*N_class(i), f_lo(i)%llim_proc:f_lo(i)%ulim_alloc))
                      allocate(amcollec(i)%am_interp(nidx*N_class(i), f_lo(i)%llim_proc:f_lo(i)%ulim_alloc))
          
                      amcollec(i)%am = 0.0
                      amcollec(i)%am_left = 0.0
                      amcollec(i)%am_right = 0.0
                      amcollec(i)%am_interp = 0.0

                  end if

              else
                  
                  allocate(am_left(nidx*N_class(i),f_lo(i)%llim_proc:f_lo(i)%ulim_alloc))
                  allocate(am_right(nidx*N_class(i),f_lo(i)%llim_proc:f_lo(i)%ulim_alloc))
                  am_left = 0.
                  am_right = 0.

              end if

              if (proc0) call time_message(.false.,timer_interp_alloc,' Init_invert') ! NDCTESTtime

          end if

          !Do we need to zero all arrays on every loop? This can be more expensive than might think.
          g = 0.0

          phi = 0.0
          apar = 0.0
          bpar = 0.0
          phinew = 0.0
          aparnew = 0.0
          bparnew = 0.0

          !Loop over individual 2pi domains / cells
          do n = 1, N_class(i)
             !Loop over theta grid points in cell
             !This is like a loop over nidx as we also handle all the fields in this loop
             do ig = -ntgrid, ntgrid
                !Are we at a connected boundary point on the lower side (i.e. left hand end of a
                !tube/cell connected to the left)
                endpoint = n > 1
                endpoint = ig == -ntgrid .and. endpoint

                !Start counting fields
                ifield = 0

                !Find response to phi
                if (fphi > epsilon(0.0)) then
                   ifield = ifield + 1
                   if (endpoint) then
                      !Do all members of supercell together
                      do m = 1, M_class(i)
                         ik = f_lo(i)%ik(m,n-1)
                         it = f_lo(i)%it(m,n-1)
                         phinew(ntgrid,it,ik) = 1.0
                      end do
                   endif
                   !Do all members of supercell together
                   do m = 1, M_class(i)
                      ik = f_lo(i)%ik(m,n)
                      it = f_lo(i)%it(m,n)
                      phinew(ig,it,ik) = 1.0
                   end do
                   if (.not. skip_initialisation) then
                       ! NDCTESTshift: moving kxstar to kx
                       if(implicit_flowshear .or. mixed_flowshear) then
                           !interp_shift_kx = -1 NDCTESTshift
                           if (proc0) call time_message(.false.,timer_interp_tdep,' bla') ! NDCTESTtime
                           kx_shift = 0. ! NDCTESTneighb
                           call update_kperp2_tdep
                           call update_aj0_tdep
                           call update_gamtot_tdep
                           if (proc0) call time_message(.false.,timer_interp_tdep,' bla') ! NDCTESTtime

                           if(implicit_flowshear) then
                               if (proc0) call time_message(.false.,timer_interp_abr,' bla') ! NDCTESTtime
                               call compute_a_b_r_ainv(a,b,r,ainv)
                               if (proc0) call time_message(.false.,timer_interp_abr,' bla') ! NDCTESTtime
                           end if
                       end if

                       trigger_timer_aminv = .true. ! NDCTESTtime
                       trigger_timer_interp = .false. ! NDCTESTtime
                       if (proc0) call time_message(.false.,timer_aminv_row,' Tadv_tdep') ! NDCTESTtime
                       if(interp_before .and. .not. explicit_flowshear) then
                           call init_response_row (ig, ifield, amcollec(i)%am, i, n)
                       else
                           call init_response_row (ig, ifield, am, i, n)
                       end if
                       if (proc0) call time_message(.false.,timer_aminv_row,' Tadv_tdep') ! NDCTESTtime
                       trigger_timer_aminv = .false. ! NDCTESTtime

                       ! am for shifted kx's,
                       ! required for aminv interpolation in cases with flow-shear --NDC 11/2017
                       if(implicit_flowshear .or. mixed_flowshear) then
                       
                           !interp_shift_kx = -1 NDCTESTshift
                           ! NDCTESTshift: moving to kx-0.5*dkx
                           if (proc0) call time_message(.false.,timer_interp_tdep,' bla') ! NDCTESTtime
                           kx_shift = -0.5*dkx ! NDCTESTneighb
                           call update_kperp2_tdep ! NDCTEST: change factor to -1.
                           call update_aj0_tdep
                           call update_gamtot_tdep
                           if (proc0) call time_message(.false.,timer_interp_tdep,' bla') ! NDCTESTtime

                           if(implicit_flowshear) then
                               if (proc0) call time_message(.false.,timer_interp_abr,' bla') ! NDCTESTtime
                               call compute_a_b_r_ainv(a,b,r,ainv)
                               if (proc0) call time_message(.false.,timer_interp_abr,' bla') ! NDCTESTtime
                           end if
                           ! endNDCTESTshift

                           !call init_response_row(ig,ifield,am_left,i,n,interp_shift_kx) NDCTESTshift
                           trigger_timer_interp = .true. ! NDCTESTtime
                           trigger_timer_aminv = .false. ! NDCTESTtime
                           if (proc0) call time_message(.false.,timer_interp_row,' Tadv_tdep') ! NDCTESTtime
                           if(interp_before) then
                               call init_response_row(ig,ifield,amcollec(i)%am_left,i,n,tadv_for_interp) ! NDCTESTinv
                           else
                               call init_response_row(ig,ifield,am_left,i,n,tadv_for_interp)
                           end if
                           if (proc0) call time_message(.false.,timer_interp_row,' Tadv_tdep') ! NDCTESTtime
                           trigger_timer_interp = .false. ! NDCTESTtime
                           
                           !interp_shift_kx = 1 NDCTESTshift

                           ! NDCTESTshift: moving to kx+0.5*dkx
                           if (proc0) call time_message(.false.,timer_interp_tdep,' bla') ! NDCTESTtime
                           kx_shift = 0.5*dkx ! NDCTESTneighb
                           call update_kperp2_tdep ! NDCTEST: remove factor of 0.5
                           call update_aj0_tdep
                           call update_gamtot_tdep
                           if (proc0) call time_message(.false.,timer_interp_tdep,' bla') ! NDCTESTtime

                           if(implicit_flowshear) then
                               if (proc0) call time_message(.false.,timer_interp_abr,' bla') ! NDCTESTtime
                               call compute_a_b_r_ainv(a,b,r,ainv)
                               if (proc0) call time_message(.false.,timer_interp_abr,' bla') ! NDCTESTtime
                           end if
                           ! endNDCTESTshift
                           
                           !call init_response_row(ig,ifield,am_right,i,n,interp_shift_kx) NDCTESTshift
                           trigger_timer_interp = .true. ! NDCTESTtime
                           trigger_timer_aminv = .false. ! NDCTESTtime
                           if (proc0) call time_message(.false.,timer_interp_row,' Tadv_tdep') ! NDCTESTtime
                           if(interp_before) then
                               call init_response_row(ig,ifield,amcollec(i)%am_right,i,n,tadv_for_interp) ! NDCTESTinv
                           else
                               call init_response_row(ig,ifield,am_right,i,n,tadv_for_interp)
                           end if
                           if (proc0) call time_message(.false.,timer_interp_row,' Tadv_tdep') ! NDCTESTtime
                           trigger_timer_interp = .false. ! NDCTESTtime

                           ! NDCTESTshift: moving back to kxstar(t)
                           if (proc0) call time_message(.false.,timer_interp_tdep,' bla') ! NDCTESTtime
                           kx_shift = kx_shift_stored ! NDCTESTneighb
                           call update_kperp2_tdep
                           call update_aj0_tdep
                           call update_gamtot_tdep
                           if (proc0) call time_message(.false.,timer_interp_tdep,' bla') ! NDCTESTtime
                           
                           if(implicit_flowshear) then
                               if (proc0) call time_message(.false.,timer_interp_abr,' bla') ! NDCTESTtime
                               call compute_a_b_r_ainv(a,b,r,ainv)
                               if (proc0) call time_message(.false.,timer_interp_abr,' bla') ! NDCTESTtime
                           end if
                           ! endNDCTESTshift

                       end if

                   end if
                   phinew = 0.0
                end if

                !Find response to apar
                if (fapar > epsilon(0.0)) then
                   ifield = ifield + 1
                   if (endpoint) then
                      !Do all members of supercell together
                      do m = 1, M_class(i)
                         ik = f_lo(i)%ik(m,n-1)
                         it = f_lo(i)%it(m,n-1)
                         aparnew(ntgrid,it,ik) = 1.0
                      end do
                   endif
                   !Do all members of supercell together
                   do m = 1, M_class(i)
                      ik = f_lo(i)%ik(m,n)
                      it = f_lo(i)%it(m,n)
                      aparnew(ig,it,ik) = 1.0
                   end do
                   call init_response_row (ig, ifield, am, i, n)
                   aparnew = 0.0
                end if

                !Find response to bpar
                if (fbpar > epsilon(0.0)) then
                   ifield = ifield + 1
                   if (endpoint) then
                      !Do all members of supercell together
                      do m = 1, M_class(i)
                         ik = f_lo(i)%ik(m,n-1)
                         it = f_lo(i)%it(m,n-1)
                         bparnew(ntgrid,it,ik) = 1.0
                      end do
                   endif
                   !Do all members of supercell together
                   do m = 1, M_class(i)
                      ik = f_lo(i)%ik(m,n)
                      it = f_lo(i)%it(m,n)
                      bparnew(ig,it,ik) = 1.0
                   end do
                   call init_response_row (ig, ifield, am, i, n)
                   bparnew = 0.0
                end if
             end do
          end do

          if(.not. interp_before .or. explicit_flowshear) then
              !Invert the matrix
              call init_inverse_matrix (am, aminv, i)

              !Free memory
              deallocate (am)

              ! aminv for shifted kx's,
              ! required for aminv interpolation in cases with flow-sear --NDC 11/2017
                       
              if (implicit_flowshear .or. mixed_flowshear) then
                  if (proc0) call time_message(.false.,timer_interp_invert,' Tadv_tdep') ! NDCTESTtime
                  call init_inverse_matrix(am_left, aminv_left, i)
                  if (proc0) call time_message(.false.,timer_interp_invert,' Tadv_tdep') ! NDCTESTtime
                  if (proc0) call time_message(.false.,timer_interp_alloc,' Init_invert') ! NDCTESTtime
                  deallocate (am_left)
                  if (proc0) call time_message(.false.,timer_interp_alloc,' Init_invert') ! NDCTESTtime

                  if (proc0) call time_message(.false.,timer_interp_invert,' Tadv_tdep') ! NDCTESTtime
                  call init_inverse_matrix(am_right, aminv_right, i)
                  if (proc0) call time_message(.false.,timer_interp_invert,' Tadv_tdep') ! NDCTESTtime
                  if (proc0) call time_message(.false.,timer_interp_alloc,' Init_invert') ! NDCTESTtime
                  deallocate (am_right)
                  if (proc0) call time_message(.false.,timer_interp_alloc,' Init_invert') ! NDCTESTtime
              end if

          end if
       end do
                           
       if(allocated(dkx)) deallocate(dkx)
    
    endif 

    if(dump_response) call dump_response_to_file_imp
    call prof_leaving ("init_response_matrix", "fields_implicit")

  end subroutine init_response_matrix

  subroutine init_response_row (ig, ifield, am, ic, n, tadv_opt)
    use fields_arrays, only: phi, apar, bpar, phinew, aparnew, bparnew
    use theta_grid, only: ntgrid
    use kt_grids, only: naky, ntheta0
    use dist_fn, only: getfieldeq, timeadv, M_class, N_class
    use run_parameters, only: fphi, fapar, fbpar
    use gs2_layouts, only: f_lo, idx, idx_local
    use prof, only: prof_entering, prof_leaving
    use job_manage, only: time_message ! NDCTESTtime
    use mp, only: proc0 ! NDCTESTtime
    implicit none
    integer, intent (in) :: ig, ifield, ic, n
    complex, dimension(:,f_lo(ic)%llim_proc:), intent (in out) :: am
    complex, dimension (:,:,:), allocatable :: fieldeq, fieldeqa, fieldeqp
    integer :: irow, istart, iflo, ik, it, ifin, m, nn
    logical, intent(in), optional :: tadv_opt ! NDCTESTshift
    logical :: tadv ! NDCTESTshift

    if(present(tadv_opt)) then
        tadv = tadv_opt
    else
        tadv = .true.
    end if

    !For profiling
    call prof_entering ("init_response_row", "fields_implicit")

    !Always the same size so why bother doing this each time?
    allocate (fieldeq (-ntgrid:ntgrid, ntheta0, naky))
    allocate (fieldeqa(-ntgrid:ntgrid, ntheta0, naky))
    allocate (fieldeqp(-ntgrid:ntgrid, ntheta0, naky))

    !Find response to delta function fields
    !NOTE:Timeadv will loop over all iglo even though only one ik
    !has any amplitude, this is quite a waste. Should ideally do all
    !ik at once
    !NOTE:We currently do each independent supercell of the same length
    !together, this may not be so easy if we do all the ik together but it should
    !be possible.

    ! NDCTESTshift: also call timeadv for interpolation matrices in mixed flow-shear approach
    if(tadv) then
        
        if (proc0 .and. trigger_timer_aminv) call time_message(.false.,timer_aminv_tadv,' Init_resp') ! NDCTESTtime
        if (proc0 .and. trigger_timer_interp) call time_message(.false.,timer_interp_tadv,' Init_resp') ! NDCTESTtime
        
        !call timeadv (phi, apar, bpar, phinew, aparnew, bparnew, 0)
        call timeadv (phi, apar, bpar, phinew, aparnew, bparnew, 0,0,trigger_timer_aminv,trigger_timer_interp) ! NDCTESTtime
        
        if (proc0 .and. trigger_timer_aminv) call time_message(.false.,timer_aminv_tadv,' Init_resp') ! NDCTESTtime
        if (proc0 .and. trigger_timer_interp) call time_message(.false.,timer_interp_tadv,' Init_resp') ! NDCTESTtime

    end if

    if (proc0 .and. trigger_timer_aminv) call time_message(.false.,timer_aminv_fieldeq,' Init_resp') ! NDCTESTtime
    if (proc0 .and. trigger_timer_interp) call time_message(.false.,timer_interp_fieldeq,' Init_resp') ! NDCTESTtime
    call getfieldeq (phinew, aparnew, bparnew, fieldeq, fieldeqa, fieldeqp)
    if (proc0 .and. trigger_timer_aminv) call time_message(.false.,timer_aminv_fieldeq,' Init_resp') ! NDCTESTtime
    if (proc0 .and. trigger_timer_interp) call time_message(.false.,timer_interp_fieldeq,' Init_resp') ! NDCTESTtime

    !Loop over 2pi domains / cells
    do nn = 1, N_class(ic)

       !Loop over members of the current class (separate supercells/connected domains)
       do m = 1, M_class(ic)

          !Get corresponding it and ik indices
          it = f_lo(ic)%it(m,nn)
          ik = f_lo(ic)%ik(m,nn)
       
          !Work out which row of the matrix we're looking at
          !corresponds to iindex, i.e. which of the nindex points in the
          !supercell we're looking at.
          irow = ifield + nfield*((ig+ntgrid) + (2*ntgrid+1)*(n-1))
          
          !Convert iindex and m to iflo index
          iflo = idx (f_lo(ic), irow, m)
          
          !If this is part of our local iflo range then store
          !the response data
          if (idx_local(f_lo(ic), iflo)) then
             !Where abouts in the supercell does this 2pi*nfield section start
             istart = 0 + nidx*(nn-1)
             
             if (fphi > epsilon(0.0)) then
                ifin = istart + nidx
                istart = istart + 1
                am(istart:ifin:nfield,iflo) = fieldeq(:,it,ik) 
             end if
             
             if (fapar > epsilon(0.0)) then
                ifin = istart + nidx
                istart = istart + 1
                am(istart:ifin:nfield,iflo) = fieldeqa(:,it,ik)
             end if
             
             if (fbpar > epsilon(0.0)) then
                ifin = istart + nidx
                istart = istart + 1
                am(istart:ifin:nfield,iflo) = fieldeqp(:,it,ik)
             end if
             
          end if
                    
       end do
    end do

    !Free memory
    deallocate (fieldeq, fieldeqa, fieldeqp)

    !For profiling
    call prof_leaving ("init_response_row", "fields_implicit")
  end subroutine init_response_row

  ! aminverse: un-allocated instance of field_matrix_type
  ! where inverted matrix will be stored --NDC 11/2017
  subroutine init_inverse_matrix (am, aminverse, ic)
    use file_utils, only: error_unit
    use kt_grids, only: aky, akx
    use theta_grid, only: ntgrid
    use mp, only: broadcast, send, receive, iproc
    use gs2_layouts, only: f_lo, idx, idx_local, proc_id, jf_lo
    use gs2_layouts, only: if_idx, im_idx, in_idx, local_field_solve
    use gs2_layouts, only: ig_idx, ifield_idx, ij_idx, mj, dj
    use prof, only: prof_entering, prof_leaving
    use dist_fn, only: i_class, M_class, N_class
    implicit none
    integer, intent (in) :: ic
    complex, dimension(:,f_lo(ic)%llim_proc:), intent (in out) :: am
    type(field_matrix_type), dimension(:), allocatable, intent(in out) :: aminverse
    complex, dimension(:,:), allocatable :: a_inv, lhscol, rhsrow, col_row_tmp
    complex, dimension (:), allocatable :: am_tmp
    complex :: fac
    integer :: i, j, k, ik, it, m, n, nn, if, ig, jsc, jf, jg, jc
    integer :: irow, ilo, jlo, dc, iflo, ierr
    logical :: iskip, jskip

    call prof_entering ("init_inverse_matrix", "fields_implicit")
    
    allocate (lhscol (nidx*N_class(ic),M_class(ic)))
    allocate (rhsrow (nidx*N_class(ic),M_class(ic)))
   
    !This is the length of a supercell
    j = nidx*N_class(ic)

    !Create storage space
    allocate (a_inv(j,f_lo(ic)%llim_proc:f_lo(ic)%ulim_alloc))
    a_inv = 0.0
    
    if (.not. skip_initialisation) then
      !Set (ifield*ig,ilo) "diagonal" to 1?
      do ilo = f_lo(ic)%llim_proc, f_lo(ic)%ulim_proc
         a_inv(if_idx(f_lo(ic),ilo),ilo) = 1.0
      end do

      ! Gauss-Jordan elimination, leaving out internal points at multiples of ntgrid 
      ! for each supercell
      !Loop over parallel gridpoints in supercell
      do i = 1, nidx*N_class(ic)
         !iskip is true iff the theta grid point(ig) corresponding to i
         !is at the upper end of a 2pi domain/cell and is not the rightmost gridpoint
         iskip = N_class(ic) > 1 !Are the multiple cells => are there connections/boundaries
         iskip = i <= nidx*N_class(ic) - nfield .and. iskip !Are we not near the upper boundary of the supercell
         iskip = mod((i+nfield-1)/nfield, 2*ntgrid+1) == 0 .and. iskip !Are we at a theta grid point corresponding to the rightmost point of a 2pi domain
         iskip = i > nfield .and. iskip !Are we not at the lower boundary of the supercell
         if (iskip) cycle
   
         if (local_field_solve) then
            do m = 1, M_class(ic)
               ilo = idx(f_lo(ic),i,m)
               if (idx_local(f_lo(ic),ilo)) then
                  lhscol(:,m) = am(:,ilo)
                  rhsrow(:,m) = a_inv(:,ilo)
               end if
            end do
         else
            allocate(col_row_tmp(nidx*N_class(ic),2)) ; col_row_tmp = 0.
            !Loop over classes (supercell lengths)
            do m = 1, M_class(ic)
               !Convert to f_lo index
               ilo = idx(f_lo(ic),i,m)
               !Is ilo on this proc?
               if (idx_local(f_lo(ic),ilo)) then
                  !If so store column/row
                  !lhscol(:,m) = am(:,ilo)
                  !rhsrow(:,m) = a_inv(:,ilo)
                  col_row_tmp(:,1) = am(:,ilo)
                  col_row_tmp(:,2) = a_inv(:,ilo)
               end if
               !Here we send lhscol and rhscol sections to all procs
               !from the one on which it is currently known
               !Can't do this outside m loop as proc_id depends on m
               !These broadcasts can be relatively expensive so local_field_solve
               !may be preferable
               !call broadcast (lhscol(:,m), proc_id(f_lo(ic),ilo))
               !call broadcast (rhsrow(:,m), proc_id(f_lo(ic),ilo))
               call broadcast (col_row_tmp, proc_id(f_lo(ic),ilo))
               lhscol(:,m) = col_row_tmp(:,1)
               rhsrow(:,m) = col_row_tmp(:,2)
            end do
            !All procs will have the same lhscol and rhsrow after this loop+broadcast
            deallocate(col_row_tmp)
         end if

         !Loop over field compound dimension
         do jlo = f_lo(ic)%llim_proc, f_lo(ic)%ulim_proc
            !jskip is true similarly to iskip
            jskip = N_class(ic) > 1 !Are there any connections?
            jskip = ig_idx(f_lo(ic), jlo) == ntgrid .and. jskip !Are we at a theta grid point corresponding to the upper boundary?
            !Get 2pi domain/cell number out of total for this supercell
            n = in_idx(f_lo(ic),jlo)
            jskip = n < N_class(ic) .and. jskip !Are we not in the last cell (i.e. not at the rightmost grid point/upper end of supercell)?
            if (jskip) cycle  !Skip this point if appropriate

            !Now get m (class number)
            m = im_idx(f_lo(ic),jlo)

            !Convert class number and cell number to ik and it
            ik = f_lo(ic)%ik(m,n)
            it = f_lo(ic)%it(m,n)
            
            !Work out what the compound theta*field index is.
            irow = if_idx(f_lo(ic),jlo)

            !If ky or kx are not 0 (i.e. skip zonal 0,0 mode) then workout the array
            if (aky(ik) /= 0.0 .or. akx(it) /= 0.0) then
               !Get factor
               fac = am(i,jlo)/lhscol(i,m)

               !Store array element
               am(i,jlo) = fac

               !Store other elements
               am(:i-1,jlo) = am(:i-1,jlo) - lhscol(:i-1,m)*fac
               am(i+1:,jlo) = am(i+1:,jlo) - lhscol(i+1:,m)*fac
               !WOULD the above three commands be better written as
               !am(:,jlo)=am(:,jlo)-lhscol(:,m)*fac
               !am(i,jlo)=fac

               !Fill in a_inv
               if (irow == i) then
                  a_inv(:,jlo) = a_inv(:,jlo)/lhscol(i,m)
               else
                  a_inv(:,jlo) = a_inv(:,jlo) &
                       - rhsrow(:,m)*lhscol(irow,m)/lhscol(i,m)
               end if
            else
               a_inv(:,jlo) = 0.0
            end if
     
         end do
      end do

      !Free memory
      deallocate (lhscol, rhsrow)

  ! fill in skipped points for each field and supercell:
  ! Do not include internal ntgrid points in sum over supercell

      do i = 1, nidx*N_class(ic)
         !iskip is true iff the theta grid point(ig) corresponding to i
         !is at the upper end of a 2pi domain/cell and is not the rightmost gridpoint
         iskip = N_class(ic) > 1 !Are the multiple cells => are there connections/boundaries
         iskip = i <= nidx*N_class(ic) - nfield .and. iskip  !Are we not near the upper boundary of the supercell
         iskip = mod((i+nfield-1)/nfield, 2*ntgrid+1) == 0 .and. iskip !Are we at a theta grid point corresponding to the rightmost point of a 2pi domain
         iskip = i > nfield .and. iskip !Are we not at the lower boundary of the supercell
         !Zero out skipped points
         if (iskip) then
            a_inv(i,:) = 0
            cycle !Seems unnexessary
         end if
      end do
  ! Make response at internal ntgrid points identical to response
  ! at internal -ntgrid points:
      do jlo = f_lo(ic)%llim_world, f_lo(ic)%ulim_world
         !jskip is true similarly to iskip
         jskip = N_class(ic) > 1 !Are there any connections?
         jskip = ig_idx(f_lo(ic), jlo) == ntgrid .and. jskip  !Are we at a theta grid point corresponding to the upper boundary?
         jskip = in_idx(f_lo(ic), jlo) < N_class(ic) .and. jskip  !Are we not in the last cell (i.e. not at the rightmost grid point/upper end of supercell)?
         !If we previously skipped this point then we want to fill it in from the matched/connected point
         if (jskip) then
            !What is the index of the matched point?
            ilo = jlo + nfield
            !If we have ilo on this proc send it to...
            if (idx_local(f_lo(ic), ilo)) then
               !jlo on this proc
               if (idx_local(f_lo(ic), jlo)) then
                  a_inv(:,jlo) = a_inv(:,ilo)
               !jlo on proc which has jlo
               else
                  call send(a_inv(:,ilo), proc_id(f_lo(ic), jlo))
               endif
            else
               !If this proc has jlo then get ready to receive
               if (idx_local(f_lo(ic), jlo)) then
                  call receive(a_inv(:,jlo), proc_id(f_lo(ic), ilo))
               end if
            end if
         end if
      end do
      !The send receives in the above loop should be able to function in a
      !non-blocking manner fairly easily, but probably don't cost that much
      !Would require WAITALL before doing am=a_inv line below

      !Update am
      am = a_inv
    end if ! .not. skip_initialisation

    !Free memory
    deallocate (a_inv)

! Re-sort this class of aminverse for runtime application.  

    !Now allocate array to store matrices for each class
    if (.not.allocated(aminverse)) allocate (aminverse(i_class))

! only need this large array for particular values of jlo.
! To save space, count how many this is and only allocate
! required space:

    !Initialise counter
    dc = 0
! check all members of this class
    do ilo = f_lo(ic)%llim_world, f_lo(ic)%ulim_world

! find supercell coordinates
       !i.e. what is my class of supercell and which cell am I looking at
       m = im_idx(f_lo(ic), ilo)
       n = in_idx(f_lo(ic), ilo)

! find standard coordinates
       !Get theta, field, kx and ky indexes for current point
       ig = ig_idx(f_lo(ic), ilo)
       if = ifield_idx(f_lo(ic), ilo)
       ik = f_lo(ic)%ik(m,n)
       it = f_lo(ic)%it(m,n)

! translate to fast field coordinates
       jlo = ij_idx(jf_lo, ig, if, ik, it)
          
! Locate this jlo, count it, and save address
       !Is this point on this proc, if so increment counter
       if (idx_local(jf_lo,jlo)) then
! count it
          dc = dc + 1
! save dcell address
          dj(ic,jlo) = dc
! save supercell address
          mj(jlo) = m
       endif
          
    end do

! allocate dcells and supercells in this class on this PE:
    !Loop over "fast field" index
    do jlo = jf_lo%llim_proc, jf_lo%ulim_proc
          
       !Allocate store in this class, on this proc to store the jlo points
       if (.not.associated(aminverse(ic)%dcell)) then
          allocate (aminverse(ic)%dcell(dc))
       else
          !Just check the array is the correct size
          j = size(aminverse(ic)%dcell)
          if (j /= dc) then
             ierr = error_unit()
             write(ierr,*) 'Error (1) in init_inverse_matrix: ',&
                  iproc,':',jlo,':',dc,':',j
          endif
       endif
       
       !Get the current "dcell" adress
       k = dj(ic,jlo)

       !No dcell should be 0 but this is a guard
       if (k > 0) then
          !How long is the supercell for this class?
          jc = nidx*N_class(ic)

          !Allocate storage for the supercell if required
          if (.not.associated(aminverse(ic)%dcell(k)%supercell)) then
             allocate (aminverse(ic)%dcell(k)%supercell(jc))
          else
             !Just check the array is the correct size
             j = size(aminverse(ic)%dcell(k)%supercell)
             if (j /= jc) then
                ierr = error_unit()
                write(ierr,*) 'Error (2) in init_inverse_matrix: ', &
                     iproc,':',jlo,':',jc,':',j
             end if
          end if
       end if
    end do

! Now fill aminverse for this class:

    !Allocate temporary supercell storage
    allocate (am_tmp(nidx*N_class(ic)))

    !Loop over all grid points
    do ilo = f_lo(ic)%llim_world, f_lo(ic)%ulim_world

       !Get supercell type (class) and cell index
       m = im_idx(f_lo(ic), ilo)
       n = in_idx(f_lo(ic), ilo)
       
       !Convert to theta,field,kx and ky indexes
       ig = ig_idx(f_lo(ic), ilo)
       if = ifield_idx(f_lo(ic), ilo)
       ik = f_lo(ic)%ik(m,n)
       it = f_lo(ic)%it(m,n)
       
       !Get fast field index
       iflo = ij_idx(jf_lo, ig, if, ik, it)
 
       !If this ilo is local then...
       if (idx_local(f_lo(ic),ilo)) then
          ! send the am data to...
          if (idx_local(jf_lo,iflo)) then
             !the local proc
             am_tmp = am(:,ilo)
          else
             !the remote proc
             call send(am(:,ilo), proc_id(jf_lo,iflo))
          endif
       else
          !Get ready to receive the data
          if (idx_local(jf_lo,iflo)) then
             call receive(am_tmp, proc_id(f_lo(ic),ilo))
          end if
       end if

       !If the fast field index is on this processor
       if (idx_local(jf_lo, iflo)) then
          !Get "dcell" adress
          dc = dj(ic,iflo)

          !Loop over supercell size
          do jlo = 0, nidx*N_class(ic)-1
             !Convert to cell/2pi domain index
             nn = in_idx(f_lo(ic), jlo)
             
             !Get theta grid point
             jg = ig_idx(f_lo(ic), jlo)
             !Get field index
             jf = ifield_idx(f_lo(ic), jlo)
             
             !Convert index
             jsc = ij_idx(f_lo(ic), jg, jf, nn) + 1

             !Store inverse matrix data in appropriate supercell position
             aminverse(ic)%dcell(dc)%supercell(jsc) = am_tmp(jlo+1)
             
          end do
       end if
    end do

    !Free memory
    deallocate (am_tmp)

    !For profiling
    call prof_leaving ("init_inverse_matrix", "fields_implicit")
  end subroutine init_inverse_matrix

  subroutine finish_fields_layouts
    use dist_fn, only: N_class, i_class, itright, boundary
    use kt_grids, only: naky, ntheta0
    use gs2_layouts, only: f_lo, jf_lo, ij, ik_idx, it_idx
    implicit none
    integer :: i, m, n, ii, ik, it, itr, jflo

    call boundary(linked)
    if (linked) then

! Complication comes from having to order the supercells in each class
       do ii = 1, i_class
          m = 1
          do it = 1, ntheta0
             do ik = 1, naky
                call kt2ki (i, n, ik, it)
                ! If (ik, it) is in this class, continue:
                if (i == ii) then
                   ! Find left end of links
                   if (n == 1) then
                      f_lo(i)%ik(m,n) = ik
                      f_lo(i)%it(m,n) = it
                      itr = it
                      ! Follow links to the right
                      do n = 2, N_class(i)
                         itr = itright (ik, itr)
                         f_lo(i)%ik(m,n) = ik
                         f_lo(i)%it(m,n) = itr
                      end do
                      m = m + 1
                   end if
                end if
             end do
          end do
       end do
       
    ! initialize ij matrix
       
       do jflo = jf_lo%llim_proc, jf_lo%ulim_proc
          ik = ik_idx(jf_lo, jflo)
          it = it_idx(jf_lo, jflo)
          
          call kt2ki (ij(jflo), n, ik, it)
          
       end do

    else
       m = 0
       do it = 1, ntheta0
          do ik = 1, naky
             m = m + 1
             f_lo(1)%ik(m,1) = ik
             f_lo(1)%it(m,1) = it
          end do
       end do
       
       ij = 1
    end if

  end subroutine finish_fields_layouts

  subroutine kt2ki (i, n, ik, it)
    use mp, only: mp_abort
    use file_utils, only: error_unit
    use dist_fn, only: l_links, r_links, N_class, i_class
    implicit none
    integer, intent (in) :: ik, it
    integer, intent (out) :: i, n
    integer :: nn, ierr
!
! Get size of this supercell
!
    nn = 1 + l_links(ik,it) + r_links(ik,it)
!
! Find i = N_class**-1(nn)
!
    do i = 1, i_class
       if (N_class(i) == nn) exit
    end do
!
! Consistency check:
!
    if (N_class(i) /= nn) then
       ierr = error_unit()
       write(ierr,*) 'Error in kt2ki:'
       write(ierr,*) 'i = ',i,' ik = ',ik,' it = ',it,&
            ' N(i) = ',N_class(i),' nn = ',nn
       call mp_abort('Error in kt2ki')
    end if
! 
! Get position in this supercell, counting from the left
!
    n = 1 + l_links(ik, it)

  end subroutine kt2ki

  !>A routine to dump the current response matrix to file
  subroutine dump_response_to_file_imp(suffix)
    use fields_arrays, only: response_file
    use theta_grid, only: ntgrid
    use kt_grids, only: naky, ntheta0
    use dist_fn, only: i_class, N_class, M_class, get_leftmost_it, itright
    use gs2_layouts, only: f_lo, jf_lo, ij_idx, idx_local, idx, proc_id,idx_local,dj
    use mp, only: proc0, send, receive
    use gs2_save, only: gs2_save_response
    implicit none
    character(len=*), optional, intent(in) :: suffix !If passed then use as part of file suffix
    character(len=64) :: suffix_local, suffix_default='.response'
    character(len=256) :: file_name
    complex, dimension(:,:), allocatable :: tmp_arr, tmp_arr_full
    complex, dimension(:), allocatable :: tmp_vec_full, tmp_vec
    integer :: ic, im, ik, it, itmin, supercell_length, supercell_length_bound, in, ifld, ig, is_tmp
    integer :: jflo, dc, nn, in_tmp, icount, it_tmp, nl, nr, ifld_tmp, ext_dom_length, ig_tmp, cur_idx
    integer, dimension(:,:), allocatable :: it_to_is, leftmost_it
    integer, dimension(:), allocatable :: tmp_ints
    logical :: is_local
    !Set file suffix
    suffix_local=suffix_default
    if(present(suffix)) suffix_local=suffix

    !Make a lookup array to convert itmin (the leftmost it in a connected domain)
    !to the supercell index "is" used in the local fields. This will be used to 
    !ensure equivalent files can be given the same name.
    allocate(it_to_is(ntheta0,naky),leftmost_it(ntheta0,naky),tmp_ints(ntheta0))
    it_to_is=0
    !//Note the following code is mostly borrowed from fm_init in the local fields
    
    !First find all the leftmost it
    do ik=1,naky
       do it=1,ntheta0
          leftmost_it(it,ik)=get_leftmost_it(it,ik)
       enddo
    enddo

    !Now find supercell ids for each ky at a time
    do ik=1,naky
       tmp_ints=leftmost_it(:,ik)
       it_tmp=0
       is_tmp=0
       do while(sum(tmp_ints).ne.-1*ntheta0)
          it_tmp=it_tmp+1
          cur_idx=tmp_ints(it_tmp)

          !If we've seen this domain skip
          if(cur_idx.eq.-1)cycle

          !Increment counter
          is_tmp=is_tmp+1

          !Here we store the value
          it_to_is(it_tmp,ik)=is_tmp

          !Now we set all other connected locations to -1
          !and store the appropriate is value
          do it=1,ntheta0
             if(tmp_ints(it).eq.cur_idx) then
                tmp_ints(it)=-1
                it_to_is(it,ik)=is_tmp
             endif
          enddo
       enddo
    enddo

    !Cleanup
    deallocate(tmp_ints)

    !/End of borrowed code

    !Notation recap:
    ! A class refers to all independent domains with the same length
    ! i_class is how many classes we have
    ! N_class(i_class) is how many 2Pi domains are in each member of i_class
    ! M_class(i_class) is how many independent domains are in i_class

    allocate(tmp_vec(nfield*(2*ntgrid+1)))
    allocate(tmp_arr(1+(2*ntgrid),nfield))

    !Loop over classes (supercell length)
    do ic=1,i_class
       !Work out how long the supercell is
       supercell_length=1+(2*ntgrid)*nfield*N_class(ic) !Without boundary points
       supercell_length_bound=(1+2*ntgrid)*nfield*N_class(ic) !With boundary points
       !Extended domain length
       ext_dom_length=1+(2*ntgrid)*N_class(ic)

       !Make storage
       allocate(tmp_arr_full(supercell_length,supercell_length))
       allocate(tmp_vec_full(supercell_length))

       !Now loop over all members of this class
       do im=1,M_class(ic)
          !Now we are thinking about a single supercell
          !we can get certain properties before looping
          !over the individual elements
          
          !Get the ik index
          ik=f_lo(ic)%ik(im,1)

          !Get the leftmost it index (named itmin to match local field routines)
          !This is currently used to identify the supercell like "is" is used in
          !the local field routines. It would be nice to also use "is" here (or
          !"itmin" there).
          itmin=leftmost_it(f_lo(ic)%it(im,1),ik)
          
          !Now we have the basic properties we want to loop over the elements
          !First initialise "it"
          it=itmin

          !Initialise counter
          icount=1

          !Loop over the different it (2Pi domains)
          do in=1,N_class(ic)
             !Loop over the fields
             do ifld=1,nfield
                !Loop over theta
                do ig=-ntgrid,ntgrid
                   !Skip the duplicate boundary points
                   if((ig.eq.ntgrid).and.(in.ne.N_class(ic))) cycle

                   !Convert to jf_lo index
                   jflo=ij_idx(jf_lo,ig,ifld,ik,it)

                   !See if it's local
                   is_local=idx_local(jf_lo,jflo)

                   !If it's not local then we have nothing to do
                   !unless we're the proc who writes (proc0).
                   if(.not.(is_local.or.proc0)) cycle

                   !Now pack tmp_vec and do communications if needed
                   if(is_local)then
                      !Get dcell index
                      dc=dj(ic,jflo)

                      !Now we pack the tmp_vec in the correct order
                      !whilst ignoring the repeated boundary points
                      !We need to pick the value of "n" in the right order
                      it_tmp=itmin
                      do in_tmp=1,N_class(ic)
                         !Pick the correct n
                         do nn=1,N_class(ic)
                            if(f_lo(ic)%it(im,nn).eq.it_tmp) exit
                         enddo

                         !Now we can get supercell range (including boundaries)
                         nl=1+nidx*(nn-1)
                         nr=nl+nidx-1
                         
                         !Extract section
                         tmp_vec=aminv(ic)%dcell(dc)%supercell(nl:nr)

                         !All that remains now is to ignore the boundary points
                         !To do this we just split on the field so we can ignore
                         !boundary if we want
                         do ifld_tmp=1,nfield
                            nl=1+(ifld_tmp-1)*(2*ntgrid+1)
                            nr=nl+2*ntgrid
                            tmp_arr(:,ifld_tmp)=tmp_vec(nl:nr)
                         enddo

                         !Now we need to work out where to put things in tmp_vec_full
                         !In doing this we try to match the local fields data layout
                         !to aid comparisons
                         do ifld_tmp=1,nfield
                            do ig_tmp=1,2*ntgrid+1
                               !Skip boundary points
                               if((ig_tmp.eq.(2*ntgrid+1)).and.(in_tmp.ne.N_class(ic))) cycle

                               !Get index
                               cur_idx=ig_tmp+(2*ntgrid)*(in_tmp-1)+(ifld_tmp-1)*ext_dom_length

                               !Store data
                               tmp_vec_full(cur_idx)=tmp_arr(ig_tmp,ifld_tmp)
                            enddo
                         enddo

                         !Increment it
                         it_tmp=itright(ik,it_tmp)
                      enddo

                      !No comms needed if on proc0
                      if(.not.proc0) call send(tmp_vec_full,0)
                   else
                      !Only proc0 should get here but test anyway
                      if(proc0) call receive(tmp_vec_full,proc_id(jf_lo,jflo))
                   endif

                   !Now we need to store in the full array
                   !May need to check index order matches local case.
                   if(proc0) then
                      tmp_arr_full(:,icount)=tmp_vec_full
                   endif

                   !Increment counter
                   icount=icount+1
                enddo
             enddo

             !Increment it
             it=itright(ik,it)
          enddo

          !Now make file name
          if(proc0)then
             write(file_name,'(A,"_ik_",I0,"_is_",I0,A)') trim(response_file),ik,it_to_is(itmin,ik),trim(suffix_local)
             call gs2_save_response(tmp_arr_full,file_name)
          endif
       end do
          
       deallocate(tmp_arr_full,tmp_vec_full)
    end do

    !Tidy
    deallocate(tmp_vec,tmp_arr,leftmost_it,it_to_is)

  end subroutine dump_response_to_file_imp

  !>A routine to read the response matrix from file and populate the implicit
  !response storage, note we also allocate the response storage objects
  subroutine read_response_from_file_imp(suffix)
    use fields_arrays, only: response_file
    use theta_grid, only: ntgrid
    use kt_grids, only: naky, ntheta0
    use dist_fn, only: i_class, N_class, M_class, get_leftmost_it, itright
    use gs2_layouts, only: f_lo, jf_lo, ij_idx, idx_local, idx, proc_id,idx_local,dj
    use mp, only: proc0, send, receive
    use gs2_save, only: gs2_restore_response
    implicit none
    character(len=*), optional, intent(in) :: suffix !If passed then use as part of file suffix
    character(len=64) :: suffix_local, suffix_default='.response'
    character(len=256) :: file_name
    complex, dimension(:,:), allocatable :: tmp_arr, tmp_arr_full
    complex, dimension(:), allocatable :: tmp_vec_full, tmp_vec
    integer :: ic, im, ik, it, itmin, supercell_length, supercell_length_bound, in, ifld, ig, is_tmp
    integer :: jflo, dc, nn, in_tmp, icount, it_tmp, nl, nr, ifld_tmp, ext_dom_length, ig_tmp, cur_idx
    integer :: jflo_dup, dc_dup
    integer, dimension(:,:), allocatable :: it_to_is, leftmost_it
    integer, dimension(:), allocatable :: tmp_ints
    logical :: is_local, is_local_dup
    !Set file suffix
    suffix_local=suffix_default
    if(present(suffix)) suffix_local=suffix

    !First allocate the matrix storage
    call alloc_response_objects

    !Make a lookup array to convert itmin (the leftmost it in a connected domain)
    !to the supercell index "is" used in the local fields. This will be used to 
    !ensure equivalent files can be given the same name.
    allocate(it_to_is(ntheta0,naky),leftmost_it(ntheta0,naky),tmp_ints(ntheta0))
    it_to_is=0
    !//Note the following code is mostly borrowed from fm_init in the local fields
    
    !First find all the leftmost it
    do ik=1,naky
       do it=1,ntheta0
          leftmost_it(it,ik)=get_leftmost_it(it,ik)
       enddo
    enddo

    !Now find supercell ids for each ky at a time
    do ik=1,naky
       tmp_ints=leftmost_it(:,ik)
       it_tmp=0
       is_tmp=0
       do while(sum(tmp_ints).ne.-1*ntheta0)
          it_tmp=it_tmp+1
          cur_idx=tmp_ints(it_tmp)

          !If we've seen this domain skip
          if(cur_idx.eq.-1)cycle

          !Increment counter
          is_tmp=is_tmp+1

          !Here we store the value
          it_to_is(it_tmp,ik)=is_tmp

          !Now we set all other connected locations to -1
          !and store the appropriate is value
          do it=1,ntheta0
             if(tmp_ints(it).eq.cur_idx) then
                tmp_ints(it)=-1
                it_to_is(it,ik)=is_tmp
             endif
          enddo
       enddo
    enddo

    !Cleanup
    deallocate(tmp_ints)

    !/End of borrowed code

    !Notation recap:
    ! A class refers to all independent domains with the same length
    ! i_class is how many classes we have
    ! N_class(i_class) is how many 2Pi domains are in each member of i_class
    ! M_class(i_class) is how many independent domains are in i_class

    allocate(tmp_vec(nfield*(2*ntgrid+1)))
    allocate(tmp_arr(1+(2*ntgrid),nfield))

    !Loop over classes (supercell length)
    do ic=1,i_class
       !Work out how long the supercell is
       supercell_length=1+(2*ntgrid)*nfield*N_class(ic) !Without boundary points
       supercell_length_bound=(1+2*ntgrid)*nfield*N_class(ic) !With boundary points
       !Extended domain length
       ext_dom_length=1+(2*ntgrid)*N_class(ic)

       !Make storage
       allocate(tmp_arr_full(supercell_length,supercell_length))
       allocate(tmp_vec_full(supercell_length))

       !Now loop over all members of this class
       do im=1,M_class(ic)
          tmp_arr_full=0.
          tmp_vec_full=0.

          !Now we are thinking about a single supercell
          !we can get certain properties before looping
          !over the individual elements
          
          !Get the ik index
          ik=f_lo(ic)%ik(im,1)

          !Get the leftmost it index (named itmin to match local field routines)
          !This is currently used to identify the supercell like "is" is used in
          !the local field routines. It would be nice to also use "is" here (or
          !"itmin" there).
          itmin=leftmost_it(f_lo(ic)%it(im,1),ik)
          
          !Now we have the basic properties we want to loop over the elements
          !First initialise "it"
          it=itmin

          !Now make file name
          if(proc0)then
             write(file_name,'(A,"_ik_",I0,"_is_",I0,A)') trim(response_file),ik,it_to_is(itmin,ik),trim(suffix_local)
             call gs2_restore_response(tmp_arr_full,file_name)
          endif

          !Initialise counter
          icount=1

          !Loop over the different it (2Pi domains)
          do in=1,N_class(ic)
             !Loop over the fields
             do ifld=1,nfield
                !Loop over theta
                do ig=-ntgrid,ntgrid
                   !Skip the duplicate boundary points -- This is no good here. !<DD>
!                   if((ig.eq.ntgrid).and.(in.ne.N_class(ic))) cycle

                   !Convert to jf_lo index
                   jflo=ij_idx(jf_lo,ig,ifld,ik,it)

                   !See if it's local
                   is_local=idx_local(jf_lo,jflo)

                   !If it's not local then we have nothing to do
                   !unless we're the proc who writes (proc0).
                   if(.not.(is_local.or.proc0)) cycle

                   !Get row
                   if(proc0)then
                      tmp_vec_full=tmp_arr_full(:,icount)
                      
                      !Increment counter
                      if(.not.(ig.eq.ntgrid.and.in.ne.N_Class(ic))) icount=icount+1
                   endif

                   !Now unpack tmp_vec_full and do communications if needed
                   if(is_local)then
                      !No comms needed if local
                      if(.not.proc0) call receive(tmp_vec_full,0)

                      !Get dcell index
                      dc=dj(ic,jflo)

                      !Now we pack the tmp_vec in the correct order
                      !We must fill in the boundary points
                      !We need to pick the value of "n" in the right order
                      it_tmp=itmin
                      do in_tmp=1,N_class(ic)
                         tmp_arr=0
                         tmp_vec=0

                         !Now we need to work out where to put things in tmp_vec_full
                         !In doing this we try to match the local fields data layout
                         !to aid comparisons
                         do ifld_tmp=1,nfield
                            do ig_tmp=1,2*ntgrid+1
                               !Skip boundary points
                               if((ig_tmp.eq.(2*ntgrid+1)).and.(in_tmp.ne.N_class(ic))) cycle

                               !Get index
                               cur_idx=ig_tmp+(2*ntgrid)*(in_tmp-1)+(ifld_tmp-1)*ext_dom_length

                               !Store data
                               tmp_arr(ig_tmp,ifld_tmp)=tmp_vec_full(cur_idx)
                            enddo
                         enddo

                         !<DD>It may be anticipated that we need to fix the boundary points
                         !here but we don't actually need to do anything.
                         !Because we sum over the entire supercell in getfield we only want
                         !the repeated boundary point to be included once.
                         !We still need to calculate the field at the repeated point but the
                         !fix for that is handled at the bottom of the routine
                         !In other words we don't need something of the form:
                         ! !Fix boundary points
                         ! if(in_tmp.ne.N_class(ic))then
                         !    do ifld_tmp=1,nfield
                         !       cur_idx=1+(2*ntgrid)*(in_tmp)+(ifld_tmp-1)*ext_dom_length
                         !       tmp_arr(2*ntgrid+1,ifld_tmp)=tmp_vec_full(cur_idx)
                         !    enddo
                         ! endif

                         !Store in correct order
                         do ifld_tmp=1,nfield
                            nl=1+(ifld_tmp-1)*(2*ntgrid+1)
                            nr=nl+2*ntgrid
                            tmp_vec(nl:nr)=tmp_arr(:,ifld_tmp)
                         enddo

                         !Pick the correct n
                         do nn=1,N_class(ic)
                            if(f_lo(ic)%it(im,nn).eq.it_tmp) exit
                         enddo

                         !Now we can get supercell range (including boundaries)
                         nl=1+nidx*(nn-1)
                         nr=nl+nidx-1

                         !Store section
                         aminv(ic)%dcell(dc)%supercell(nl:nr)=tmp_vec

                         !Increment it
                         it_tmp=itright(ik,it_tmp)
                      enddo
                   else
                      !Only proc0 should get here but test anyway
                      if(proc0) call send(tmp_vec_full,proc_id(jf_lo,jflo))
                   endif
                enddo
             enddo

             !Increment it
             it=itright(ik,it)
          enddo

          !Now we need to fill in the repeated boundary points

          !If there are no boundary points then advance
          if(N_class(ic).eq.1) cycle
          it=itmin
          do in=1,N_class(ic)-1
             do ifld=1,nfield
                !First get the index of the point we want to fill
                jflo=ij_idx(jf_lo,ntgrid,ifld,ik,it)

                !Now we get the index of the point which has this data
                jflo_dup=ij_idx(jf_lo,-ntgrid,ifld,ik,itright(ik,it))

                !Now get locality
                is_local=idx_local(jf_lo,jflo)
                is_local_dup=idx_local(jf_lo,jflo_dup)

                !Get dcell values
                if(is_local) dc=dj(ic,jflo)
                if(is_local_dup) dc_dup=dj(ic,jflo_dup)

                !Now copy/communicate
                if(is_local)then
                   if(is_local_dup)then
                      aminv(ic)%dcell(dc)%supercell=aminv(ic)%dcell(dc_dup)%supercell
                   else
                      call receive(aminv(ic)%dcell(dc)%supercell,proc_id(jf_lo,jflo_dup))
                   endif
                elseif(is_local_dup)then
                   call send(aminv(ic)%dcell(dc_dup)%supercell,proc_id(jf_lo,jflo))
                endif
             enddo

             !Increment it
             it=itright(ik,it)
          enddo
       end do
       
       !Free
       deallocate(tmp_arr_full,tmp_vec_full)
    end do

    !Tidy
    deallocate(tmp_vec,tmp_arr,leftmost_it,it_to_is)
  end subroutine read_response_from_file_imp

  !>A subroutine to allocate the response matrix storage objects
  subroutine alloc_response_objects
    use dist_fn, only: i_class, N_class
    use gs2_layouts, only: jf_lo, f_lo, im_idx, in_idx, ig_idx, ifield_idx, ij_idx,dj,mj, idx_local
    use theta_grid, only: ntgrid
    implicit none
    integer :: ic, idc, sc_len, ilo, dc, im, in, ig, ifld, ik, it, jlo

    !Top level, one object for each class (length of supercell)
    if(.not.allocated(aminv)) allocate(aminv(i_class))

    !Loop over each class
    do ic=1,i_class
       !Get the supercell length
       sc_len=(2*ntgrid+1)*nfield*N_class(ic)

       !Count how many dcell we have locally and fill related data
       dc=0
       do ilo=f_lo(ic)%llim_world,f_lo(ic)%ulim_world
          !i.e. what is my class of supercell and which cell am I looking at
          im = im_idx(f_lo(ic), ilo)
          in = in_idx(f_lo(ic), ilo)

          ! find standard coordinates
          !Get theta, field, kx and ky indexes for current point
          ig = ig_idx(f_lo(ic), ilo)
          ifld = ifield_idx(f_lo(ic), ilo)
          ik = f_lo(ic)%ik(im,in)
          it = f_lo(ic)%it(im,in)
          
          ! translate to fast field coordinates
          jlo = ij_idx(jf_lo, ig, ifld, ik, it)
          
          ! Locate this jlo, count it, and save address
          !Is this point on this proc, if so increment counter
          if (idx_local(jf_lo,jlo)) then
             ! count it
             dc = dc + 1
             ! save dcell address
             dj(ic,jlo) = dc
             ! save supercell address
             mj(jlo) = im
          endif
       enddo

       !Next level, one object for each point in the class
       if(.not.associated(aminv(ic)%dcell))then
          allocate(aminv(ic)%dcell(dc))
       endif

       !Now loop over each point and allocate storage for the response data
       do idc=1,dc
          !Bottom level, this is actually where data is stored
          if(.not.associated(aminv(ic)%dcell(idc)%supercell)) then
             allocate(aminv(ic)%dcell(idc)%supercell(sc_len))
          endif
       enddo
    enddo

  end subroutine alloc_response_objects

end module fields_implicit

