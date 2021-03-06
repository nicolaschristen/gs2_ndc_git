
!> A program that runs a unit test on the fields_local module to test the NRow tuning functionality.
!! Currently success is defined as giving the same results as
!! the old implicit module...could be improved by an absolute test
!!
!! This is free software released under the MIT license
!!   Written by: Adrian Jackson (adrianj@epcc.ed.ac.uk)
!!   Based on the test_fileds_local test
program test_fields_local_tuning
  use unit_tests
  use fields_local, only: fields_local_unit_test_init_fields_matrixlocal, advance_local, fields_local_functional, minnrow, do_smart_update, field_local_tuneminnrow
  use fields_implicit, only: fields_implicit_unit_test_init_fields_implicit, advance_implicit

  use fields, only: fields_pre_init
  use egrid
  use mp, only: init_mp, finish_mp, broadcast, mp_comm
  use file_utils, only: init_file_utils
  use species, only: init_species, nspec
  use constants, only: pi
  !use fields, only: init_fields
  !use fields_arrays, only: phi
  use dist_fn, only: init_dist_fn
  !use dist_fn_arrays, only: g
  use kt_grids, only: naky, ntheta0, init_kt_grids
  use theta_grid, only: ntgrid, init_theta_grid
  use gs2_layouts, only: init_gs2_layouts, g_lo, ie_idx
  use gs2_main, only: initialize_gs2, gs2_program_state_type
  use gs2_init, only: init, init_level_list
  implicit none
  real :: eps
  logical :: dummy
  type(gs2_program_state_type) :: gs2_state


  ! General config
  eps = 1.0e-7

  if (precision(eps).lt. 11) eps = eps * 1000.0

  ! Set up depenencies
  call init_mp
  gs2_state%mp_comm_external = .true.
  gs2_state%mp_comm = mp_comm
  call initialize_gs2(gs2_state)



  call announce_module_test('fields_local')

  call init(gs2_state%init, init_level_list%fields_level_2 - 1)

  call broadcast(MinNrow)
  call broadcast(do_smart_update)
  call broadcast(field_local_tuneminnrow)

  call announce_test('init_fields_implicit')
  call process_test(fields_implicit_unit_test_init_fields_implicit(), 'init_fields_implicit')

  if (fields_local_functional()) then

    call announce_test('init_fields_matrixlocal')
    call process_test(fields_local_unit_test_init_fields_matrixlocal(), 'init_fields_matrixlocal')

    call announce_test('advance')
    call process_test(test_advance(eps), 'advance')

  else 

    write (*,*) "WARNING: fields_local is non-functional in your build. &
      & Skipping the fields_local unit test. &
      & If you are using the PGI compilers this is to be expected. "
  end if 


  call close_module_test('fields_local')
  call finish_mp
contains

  function test_advance(eps)
    use init_g, only: ginit
    use dist_fn_arrays, only: g, gnew
    use dist_fn, only: get_init_field
    use fields_arrays
    use run_parameters, only: nstep
    use fields, only: remove_zonal_flows_switch
    complex, dimension (:,:,:), allocatable :: gbak 
    complex, dimension (:,:,:), allocatable :: phi_imp, apar_imp, bpar_imp
    complex, dimension (:,:,:), allocatable :: phi_loc, apar_loc, bpar_loc
    character(len=29) :: message
    real, intent(in) :: eps
    logical :: test_advance
    logical :: check_result
    logical :: restarted
    integer :: istep, ik, it

    allocate(gbak(-ntgrid:ntgrid,2,g_lo%llim_proc:g_lo%ulim_alloc))
    allocate(phi_imp(-ntgrid:ntgrid,ntheta0,naky))
    allocate(apar_imp(-ntgrid:ntgrid,ntheta0,naky))
    allocate(bpar_imp(-ntgrid:ntgrid,ntheta0,naky))
    allocate(phi_loc(-ntgrid:ntgrid,ntheta0,naky))
    allocate(apar_loc(-ntgrid:ntgrid,ntheta0,naky))
    allocate(bpar_loc(-ntgrid:ntgrid,ntheta0,naky))

    test_advance = .true.
    !Now we want to fill g with some data, for now just use initialisation routines
    call ginit(restarted)

    !Backup this initial g
    gbak=g

    !Now we setup the initial fields to be consistent with g
    call get_init_field(phinew,aparnew,bparnew)
    phi = phinew; apar = aparnew; bpar = bparnew; g = gnew

    !Now we can do a timestep (or lots)
    do istep=1,nstep
        call advance_implicit(istep, remove_zonal_flows_switch)
    enddo

    !!Now we store the results
    phi_imp=phinew
    apar_imp=aparnew
    bpar_imp=bparnew

    !Restore original g
    g=gbak
    gnew=g

    !Now we setup the initial fields to be consistent with g
    call get_init_field(phinew,aparnew,bparnew)
    phi = phinew; apar = aparnew; bpar = bparnew; g=gnew

    !Now we can do a timestep (or lots)
    do istep=1,nstep
        call advance_local(istep, remove_zonal_flows_switch)
    enddo

    !Now we store the results
    phi_loc=phinew
    apar_loc=aparnew
    bpar_loc=bparnew

    do ik = 1,naky
      do it = 1,ntheta0
        if (it==1 .and. ik==1) cycle
        write(message, fmt="(A19, I2, A6, I2)") 'value of phi,  it =', it, ' ik = ', ik
        call announce_check(message)
        call process_check(test_advance, agrees_with(phi_imp(:, it, ik), phi_loc(:, it, ik), eps), message)
        write(message, fmt="(A19, I2, A6, I2)") 'value of apar, it =', it, ' ik = ', ik
        call announce_check(message)
        call process_check(test_advance, agrees_with(apar_imp(:, it, ik), apar_loc(:, it, ik), eps), message)
        write(message, fmt="(A19, I2, A6, I2)") 'value of bpar, it =', it, ' ik = ', ik
        call announce_check(message)
        call process_check(test_advance, agrees_with(bpar_imp(:, it, ik), bpar_loc(:, it, ik), eps), message)
      end do
    end do

  end function test_advance

end program test_fields_local_tuning
