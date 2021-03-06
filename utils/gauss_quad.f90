module gauss_quad
  ! <doc>
  !  Utilities for Gaussian quadrature.
  !  This module provides subroutines to obtain zeros and weights of
  !  Gauss-Legendre and Gauss-Laguerre quadrature rules.
  ! </doc>

  implicit none

  private

  public :: get_legendre_grids_from_cheb
  public :: get_radau_gauss_grids
  public :: get_laguerre_grids
  public :: laguerre_norm

  logical, parameter :: debug=.false.
  logical :: weight_roundoff_correction=.false.

contains
  subroutine get_legendre_grids_from_cheb (x1, x2, zero, wgt)
    ! <doc>
    !  returns Legendre zeros and weights in the given interval [x1,x2].
    !  The order is determined from the size of the array 'zero'.
    ! </doc>
    use constants, only: pi => dpi
    real, intent (in) :: x1, x2
    real, dimension (:), intent (out) :: zero, wgt
    integer :: i, nn, nh
    double precision :: xold, xnew, pold, pnew
    double precision, dimension (:), allocatable :: zz, ww

    nn = size(zero)
    nh = (nn+1)/2
    allocate (zz(nh))
    allocate (ww(nh))

    ! search zero from 1 to 0 using chebyshev grid points
    ! this is O(nn^2) operations
    xold = cos(pi / (2*(nn+1)))
    pold = legendre_p(nn,xold)
    do i=1, nh
       xnew = cos(pi*(2*i+1)/(2.0*(nn+1)))
       pnew = legendre_p(nn,xnew)
       call find_zero_bisect_newton (nn, xold, xnew, pold, pnew, zz(i))
       xold = xnew
       pold = pnew
    end do
    ! invert them to give zeros in (-1,0]
    zz(1:nn/2) = -zz(1:nn/2)

    ! weight from formula
!    ww = dble(2.0) / (dble(1.0) - zz**2) / legendre_pp(nn,zz,dble(0.0))**2
    ww = dble(2.0) / (dble(1.0) - zz**2) / legendre_pp(nn,zz)**2

    ! rescale (x2 may be smaller than x1)
    zero(1:nh) = real(zz * (x2-x1) + (x1+x2)) / 2.0
    zero(nh+1:nn) = real(zz(nn/2:1:-1) * (x1-x2) + (x1+x2)) / 2.0
    wgt(1:nh) = real(ww * abs(x2-x1) / 2.0)
    wgt(nh+1:nn) = wgt(nn/2:1:-1)

    deallocate (zz)
    deallocate (ww)

    ! roundoff correction
!!$    if (abs(sum(wgt)/abs(x2-x1)) - 1.0 > epsilon(wgt)) then
!!$       print *, 'roundoff correction occurred'
    if (weight_roundoff_correction) then
       if (mod(nn,2)==0) then
          wgt(nh) = abs(x2-x1) / 2.0 - sum(wgt(1:nh-1))
          wgt(nh+1) = wgt(nh)
       else
          wgt(nh) = abs(x2-x1) - sum(wgt(1:nh-1)) * 2.0
       end if
    end if

    call check_legendre_zero (x1, x2, zero)
    call check_legendre_weights (abs(x2-x1), wgt)

    if (debug) then
       print *, 'get_legendre_grids_from_cheb: sum of weights = ', sum(wgt)
       print *, 'get_legendre_grids_from_cheb: section length = ', abs(x2-x1)
    end if

  end subroutine get_legendre_grids_from_cheb

  subroutine find_zero_bisect_newton (n, xold, xnew, pold, pnew, zz)
    use mp, only: mp_abort
    use file_utils, only: error_unit
    implicit none
    integer, intent (in) :: n
    double precision, intent (in) :: xold, xnew, pold, pnew
!    real, intent (in) :: eps
    double precision, intent (out) :: zz
    integer :: i, maxit=100
    real :: eps
    double precision :: x1, x2, p1, p2, pz

    ! <doc>
    !  eps is declared as real on purpose.
    !  We don't require higher order precision for convergence test
    !  because of a performance reason. The following definition means
    !  eps is a geometric mean of the machine-epsilons in real and double
    !  precisions. 
    !  (note that real/double are promoted to double/double or double/quad 
    !  depending on the compiler.)
    !  
    !  [same applies to eps in find_zero below.]
    ! </doc>

    eps = sqrt(epsilon(eps)*epsilon(x1)) * 2.0
    i=0
    x1 = xold
    x2 = xnew
    p1 = pold
    p2 = pnew

    if (debug) write(*,'(4f10.5)') x1, p1, x2, p2

    ! bisection
    do i=1, 5
       zz = (x1+x2) * dble(.5)
       pz = legendre_p(n,zz)
       if (abs(pz) <= epsilon(pz)) return
       if (pz*p1 < 0.0) then
          p2=pz ; x2=zz
       else
          p1=pz ; x1=zz
       end if
       if (debug) write(*,'(4f10.5)') x1, p1, x2, p2
    end do

    if (debug) print*, 'finished bisection'

    ! newton-raphson
    if (zz==x1) x1 = x2
!    do while (abs(zz/x1-1.0) > eps)
    do i=1, maxit
       x1 = zz
       p1 = legendre_p(n,x1)
!       zz = x1 - p1 / legendre_pp(n,x1,p1)
       zz = x1 - p1 / legendre_pp(n,x1)
       pz = legendre_p(n,zz)
       if (debug) write (*,'(4f10.5)') zz, pz, x1, p1
       if (min(abs(zz/x1-1.0), abs(pz)) < eps) exit
    end do

    if (i==maxit+1) write (error_unit(),*) &
         & 'WARNING: too many iterations in get_legendre_grids'

    if (debug) call mp_abort("Abort in gauss_quad:find_zero_bisect_newton as debug=.true.")

  end subroutine find_zero_bisect_newton

  elemental function legendre_p (n, x)
    implicit none
    integer, intent (in) :: n
    double precision, intent (in) :: x
    integer :: k
    double precision :: p, p1, p2, legendre_p

    select case (n)
    case (0)
       legendre_p = dble(1.0)
    case (1)
       legendre_p = x
    case default
       p1 = x
       p2 = dble(1.0)
       do k=2, n
          p = ((2*k-1)*x*p1 - (k-1)*p2) / k
          p2 = p1
          p1 = p
       end do
       legendre_p = p
    end select

  end function legendre_p

!  elemental function legendre_pp (n, x, p1)
  elemental function legendre_pp (n, x)
    implicit none
    integer, intent (in) :: n
    double precision, intent (in) :: x
!    double precision, intent (in), optional :: p1
    double precision :: legendre_pp

!    if (present(p1)) then
!       legendre_pp = n * ( x * p1 - legendre_p(n-1,x) ) &
!            / (x**2 - dble(1.0))
!    else
    legendre_pp = n * ( x * legendre_p(n,x) - legendre_p(n-1,x) ) &
         / (x**2 - dble(1.0))
!    end if

  end function legendre_pp

  subroutine check_legendre_zero (x0, x1, zero)
    use mp, only: mp_abort
    use file_utils, only: error_unit
    implicit none
    real, intent (in) :: x0, x1
    real, dimension (:), intent (in) :: zero
    logical :: error=.false.
    integer :: nn, nh
    real :: xx, xmin, xmax
    real, dimension (:), allocatable :: zz

    nn = size(zero)
    nh = (nn+1)/2
    error = .false.
    xmin = min(x0, x1)
    xmax = max(x0, x1)
    allocate (zz(nn))
    zz = zero
    if (zz(1) > zz(nn)) zz(1:nn) = zero(nn:1:-1)
    if (zz(1) < xmin .or. zz(nn) > xmax) then
       write (error_unit(),*) 'ERROR in legendre: grid out of range'
       error = .true.
    end if

    if (nn==1) then
       if (abs(2.0*zz(1)/(xmin+xmax) - 1.0) > epsilon(0.0)) then
          write (error_unit(), '("ERROR in legendre: zz(1)= ", f20.15)') zz(1)
          error = .true.
       end if
    else
       ! check if distances at the edge: This suffices for nn<=3
       if (zz(2)-zz(1) <= zz(1)-xmin .or. zz(nn)-zz(nn-1) <= xmax-zz(nn)) then
          write (error_unit(),*) 'ERROR in legendre: wrong distance at edge'
          error = .true.
       end if
       ! check distances at the center: The above and this suffices for nn=4
       if (mod(nn,2)==0 .and. nn>=4) then
          if ( zz(nh+1)-zz(nh) <= zz(nh)-zz(nh-1) .or. &
               zz(nh+1)-zz(nh) <= zz(nh+2)-zz(nh+1) ) then
             write (error_unit(),*) &
                  & 'ERROR in legendre: wrong distance at center'
             error = .true.
          end if
       end if
       if (nn >= 5) then
          ! check if distances are increasing toward center
          ! lower half
          if (any(zz(3:nh)-zz(2:nh-1) <= zz(2:nh-1)-zz(1:nh-2))) then
             write (error_unit(),*) 'ERROR in legendre: distance decreasing toward center'
             error = .true.
          end if
          ! upper half
          ! The separate use of nh and nn/2 are intentionally so that they
          ! both work for even and odd cases
          if ( any(zz(nn/2+2:nn-1)-zz(nn/2+1:nn-2) &
               & <= zz(nn/2+3:nn)-zz(nn/2+2:nn-1)) ) then
             write (error_unit(),*) 'ERROR in legendre: distance decreasing toward center'
             error = .true.
          end if
       end if

    end if

    ! check if legendre_p(n, zero(i)) are close enough to zero
    if (debug) then
       xx = maxval(abs(real( legendre_p(nn, &
            dble((zz(:)-xmin)/(xmax-xmin)*2.0-1.0)) )))
       if (xx/nn**2 > epsilon(xx)) then
          write (error_unit(),*) 'WARNING in legendre: maxval(n,zz(:))= ', xx
          ! Do not stop as it is mostly a minor issue
       end if
    end if

    if (error) call mp_abort ('STOP in check_legendre_zero')

  end subroutine check_legendre_zero

!  subroutine check_legendre_weights (norm, wgt, eps)
  subroutine check_legendre_weights (norm, wgt)
    use mp, only: mp_abort
    use file_utils, only: error_unit
    implicit none
    real, intent (in) :: norm!, eps
    real, dimension (:), intent (in) :: wgt
    logical :: error=.false.
    integer :: n, nh
    real :: s

    n = size(wgt)
    error = .false.
    nh = (n+1)/2

    ! check if weights are all positive
    if (any(wgt < 0.)) then
       write (error_unit(),*) 'ERROR in legendre: weights got negative'
       error = .true.
    end if

    if (n>=2) then
       ! check symmetry of weights
       if ( any( abs(wgt(n:n+1-n/2:-1)/wgt(1:n/2) - 1.0) > epsilon(wgt) ) ) then
          write (error_unit(),*) 'WARNING in legendre: symmetry of weights broken'
          error = .true.
       end if

       ! check if weights are increasing toward center
       if (n>=3) then
          if (any(wgt(2:nh) <= wgt(1:nh-1))) then
             write (error_unit(),*) 'ERROR in legendre: weights decreasing toward center'
             error = .true.
          end if
       end if
    end if

    ! check if their sum is close enough to normalized value
    if (debug) then
!       s = sum(wgt)
       s = sum(dble(wgt)) ! ignore roundoff error arising from 8-byte summation
       if (abs(norm/s-1.0) > epsilon(s)) then
          write (error_unit(),*) 'WARNING in legendre: weights summation incorrect:', &
               & size(wgt), s/norm-1.0
          ! Do not stop as it is mostly a minor issue
       end if
    end if

    if (error) call mp_abort ('STOP in check_legendre_weights')

  end subroutine check_legendre_weights

  subroutine get_radau_gauss_grids (x1, x2, zero, wgt, report_in)
    ! <doc>
    !  returns radau zeros and weights in the given interval [x1,x2].
    !  The order is determined from the size of the array 'zero'.
    !  Note that the last element of 'zero' and 'wgt' are the fixed lower endpoint 
    !  -1 in (1,-1]
    !  Note also that 'zero'(i) contains the zeros in descending order 1 -> -1 with increasing i
    ! </doc>
    use mp, only: mp_abort
    use file_utils, only: error_unit
    use constants, only: pi => dpi
    real, intent (in) :: x1, x2
    logical, intent (in), optional :: report_in
    real, dimension (:), intent (out) :: zero, wgt
    integer :: i, nn, nzero
    double precision :: xold, xnew, pold, pnew, delta
    double precision, dimension (:), allocatable :: zz, ww
    logical :: report
    
    if(present(report_in)) report= report_in
    
    nn = size(zero) 
    allocate (zz(nn))
    allocate (ww(nn))

    delta = 0.001 ! The smallest interval which we divide the domain [-1,1] into to search for roots
    nzero = 0 ! The number of zeros found
    xold = dble(1.0) ! The starting point of iteration
    pold = radau_p(nn,xold)
    
    do i=1,2000 ! to cover a range x=[-1,1]
        xnew= xold-dble(delta*i)
        pnew = radau_p(nn,xnew)
        if(pold*pnew<0.0) then ! i.e.if there is a root between xold,xnew
        ! Now apply bisection and Newton-Raphson to find the route in the interval xold,xnew
           nzero=nzero+1
           call find_zero_bisect_newton_radau (nn, xold, xnew, pold, pnew, zz(nzero))           
           xold = xnew
           pold = pnew 
        end if
        if(nzero == nn-1) exit ! as all roots have been found
    end do
    
    if (nzero /= nn-1 ) then
        write (error_unit(),*) "ERROR: get_radau_gauss_grids failed to find all roots-exiting"
        do i=1, nzero
          write (error_unit(),*) i, zz(i)
        end do
        call mp_abort("ERROR: get_radau_gauss_grids failed to find all roots-exiting")
    end if
    
    ! Assign the known weight to the lower end point
    zz(nn) = -dble(1.0)
    ww(nn) = dble(2.0/nn**2)
    
    ww(1:nn-1) = (dble(1.0) - zz(1:nn-1)) / (nn*legendre_p(nn-1,zz(1:nn-1)))**2

    ! rescale (x2 may be smaller than x1)
    zero = real(zz * (x2-x1) + (x1+x2)) / 2.0
    wgt = real(ww * abs(x2-x1) / 2.0)
    
    if (report) then
        write(*,*) "i, zz, ww"
        do i=1,nn
            write(*,fmt="(1i5,2f20.16)") i, zz(i), ww(i)
        end do
        write(*,*) "i, zero, wgt"
        do i=1,nn
            write(*,fmt="(1i5,2f20.16)") i, zero(i), wgt(i)
        end do
    end if

    
    deallocate (zz)
    deallocate (ww)

    !call check_radau_gauss_zero (x1, x2, zero)
    !call check_radau_gauss_weights (abs(x2-x1), wgt)

    if (debug) then
       print *, 'get_radau_gauss_grids: sum of weights = ', sum(wgt)
       print *, 'get_radau_gauss_grids: section length = ', abs(x2-x1)
    end if

  end subroutine get_radau_gauss_grids
! polynomial for Radau-Gauss quadrature
  elemental function radau_p (n, x)
    implicit none
    integer, intent (in) :: n
    double precision, intent (in) :: x
    double precision :: radau_p

    radau_p = (legendre_p(n-1,x) + legendre_p(n,x) ) &
         / (x + dble(1.0))

  end function radau_p
! Radau-Gauss polynomial derivative
  elemental function radau_pp (n, x)
    implicit none
    integer, intent (in) :: n
    double precision, intent (in) :: x
    double precision :: radau_pp

    radau_pp = (legendre_pp(n-1,x) + legendre_pp(n,x) - radau_p(n,x) ) &
         / (x + dble(1.0))

  end function radau_pp
  
  subroutine find_zero_bisect_newton_radau (n, xold, xnew, pold, pnew, zz)
    use mp, only: mp_abort
    use file_utils, only: error_unit
    implicit none
    integer, intent (in) :: n
    double precision, intent (in) :: xold, xnew, pold, pnew
!    real, intent (in) :: eps
    double precision, intent (out) :: zz
    integer :: i, maxit=100
    real :: eps
    double precision :: x1, x2, p1, p2, pz

    ! <doc>
    !  eps is declared as real on purpose.
    !  We don't require higher order precision for convergence test
    !  because of a performance reason. The following definition means
    !  eps is a geometric mean of the machine-epsilons in real and double
    !  precisions. 
    !  (note that real/double are promoted to double/double or double/quad 
    !  depending on the compiler.)
    !  
    !  [same applies to eps in find_zero below.]
    ! </doc>

    eps = sqrt(epsilon(eps)*epsilon(x1)) * 2.0
    i=0
    x1 = xold
    x2 = xnew
    p1 = pold
    p2 = pnew

    if (debug) write(*,'(4f10.5)') x1, p1, x2, p2

    ! bisection
    do i=1, 8
       zz = (x1+x2) * dble(.5)
       pz = radau_p(n,zz)
       if (abs(pz) <= epsilon(pz)) return
       if (pz*p1 < 0.0) then
          p2=pz ; x2=zz
       else
          p1=pz ; x1=zz
       end if
       if (debug) write(*,'(4f10.5)') x1, p1, x2, p2
    end do

    if (debug) print*, 'find_zero_bisect_newton_radau: finished bisection'

    ! newton-raphson
    if (zz==x1) x1 = x2
!    do while (abs(zz/x1-1.0) > eps)
    do i=1, maxit
       x1 = zz
       p1 = radau_p(n,x1)
       zz = x1 - p1 / radau_pp(n,x1)
       pz = radau_p(n,zz)
       if (debug) write (*,'(4f10.5)') zz, pz, x1, p1
       if (min(abs(zz/x1-1.0), abs(pz)) < eps) exit
    end do

    if (i==maxit+1) write (error_unit(),*) &
         & 'WARNING: too many iterations in find_zero_bisect_newton_radau'

    if (debug) call mp_abort("Abort in gauss_quad:find_zero_bisect_newton_radau as debug=.true.")

  end subroutine find_zero_bisect_newton_radau
  
  subroutine get_laguerre_grids (zero, wgt)
    ! <doc>
    !  returns Laguerre zeros and weights.
    !  The order is determined from the size of the array 'zero'.
    ! </doc>
    use mp, only: mp_abort
    use file_utils, only: error_unit
    implicit none
    real, dimension (:), intent (out) :: zero
    real, dimension (:), intent (out) :: wgt
    logical :: error=.false.
    integer :: i, j, n, nzero
    double precision :: x, delx, pold, pnew
    double precision, dimension (:), allocatable :: zz

    n = size (zero)
    allocate (zz(n))
    zz = 0.0

    if (n > 180) then
       write (error_unit(),*) 'ERROR: can''t get so many laguerre grid points'
       write (error_unit(),*) 'ERROR: size(zero)= ', n
       error = .true.
    end if

    ! search zero from 0 to xmax using evenly spaced grid points
    if (n==1) then

       zero(1) = 1.0
       wgt(1) = 1.0
       return

    else

       nzero = 0
       pold = laguerre_l(n,dble(0.0))
       delx = 0.001
       do i=1, 1000      ! up to x=1
          x = delx*i
!          print*, x
          pnew = laguerre_l(n,x)
!          if (pold*pnew < epsilon(0.0)) then
          if (pold*pnew < 0.0) then
             nzero = nzero+1
             call find_zero (n, x-delx, x, pold, pnew, zz(nzero))
          end if
          pold=pnew
       end do

       do j=0, 3
          delx = delx * 10.
          do i=1, 900
             x = delx*(i+100)
!             print*, x
             pnew = laguerre_l(n,x)
             if (pold*pnew < 0.0) then
                nzero = nzero+1
                call find_zero (n, x-delx, x, pold, pnew, zz(nzero))
             end if
             if (nzero == n) exit
             pold=pnew
          end do
          if (nzero == n) exit
       end do

    end if

    zero = zz
    wgt = real(zz / (n+1)**2 / laguerre_l(n+1,zz)**2)

    deallocate (zz)

    ! roundoff correction
    if (weight_roundoff_correction) then
       i = sum(maxloc(wgt))
       wgt(i) = 1.0 - sum(wgt(1:i-1)) - sum(wgt(i+1:n))
    end if

    ! check number of found zeros
    if (nzero < n) then
       write (error_unit(),*) 'ERROR in laguerre: didn''t find all zeros'
       do i=1, n
          write (error_unit(),*) i, zero(i)
       end do
       call mp_abort("ERROR in laguerre: didn't find all zeros")
    end if

    if (error) call mp_abort ('STOP in get_laguerre_grids')

  end subroutine get_laguerre_grids

  subroutine find_zero (n, xold, xnew, pold, pnew, zz)
    use file_utils, only: error_unit
    implicit none
    integer, intent (in) :: n
    double precision, intent (in) :: xold, xnew, pold, pnew
    double precision, intent (out) :: zz
    integer :: i, maxit=100
    real :: eps
    double precision :: x1, x2, p1, p2, pz

    ! <doc>
    !  eps is declared as real on purpose.
    !  [see comment in find_zero_bisect_newton above.]
    ! </doc>

    eps = sqrt(epsilon(eps)*epsilon(x1)) * 2.0
    x1 = xold
    x2 = xnew
    p1 = pold
    p2 = pnew

    if (debug) write (*,'(a,4es15.5e3)') 'initial ', x1, p1, x2, p2

    ! bisection
    do i=1, 8
       zz = (x1+x2) * dble(.5)
       pz = laguerre_l(n,zz)
       if (abs(pz) <= epsilon(dble(0.0))) return
       if (pz*p1 < 0.) then
          p2=pz ; x2=zz
       else
          p1=pz ; x1=zz
       end if
       if (debug) write (*,'(a,4es15.5e3)') 'bisection ', x1, p1, x2, p2
    end do

    ! newton-raphson
    if (zz==x1) x1 = x2
    do i=1, maxit
       x1 = zz
       p1 = laguerre_l(n,x1)
       zz = x1 - p1 / laguerre_lp(n,x1)
       pz = laguerre_l(n,zz)
       if (debug) write (*,'(a,4es15.5e3)') &
            'newton ', zz, pz, x1, p1
       if (min(abs(zz/x1-1.0), abs(pz)) < eps) exit
    end do

    if (i==maxit+1) write (error_unit(),*) &
         & 'WARNING: too many iterations in get_laguerre_grids'

  end subroutine find_zero

  elemental function laguerre_l (n, x)

    ! returns L_n(x)
    ! where L_n(x) is an ordinary Laguerre polynomial

    implicit none
    integer, intent (in) :: n
    double precision, intent (in) :: x
    integer :: k
    double precision :: laguerre_l, p, p1, p2

    ! returns L_n(x)
    ! where L_n(x) is an ordinary Laguerre polynomial

    p1 = dble(1.0) - x
    p2 = dble(1.0)

    if (n==0) then
       laguerre_l = p2
       return
    else if (n==1) then
       laguerre_l = p1
       return
    end if

    do k=2, n
       p = ((2*k-1-x) * p1 - (k-1) * p2) / k
       p2 = p1
       p1 = p
    end do

    laguerre_l = p

  end function laguerre_l

  elemental function laguerre_norm (n, x)
    implicit none
    integer, intent (in) :: n
    real, intent (in) :: x
    integer :: k
    double precision :: laguerre_norm, p, p1, p2, fac

    ! returns (-1)**n n! L_n(x)
    ! where L_n(x) is an ordinary Laguerre polynomial

    p1 = dble(1.0)-x
    p2 = dble(1.0)

    if (n==0) then
       laguerre_norm = p2
       return
    else if (n==1) then
       laguerre_norm = -p1
       return
    end if

    do k=2, n
       p = ((2*k-1-x) * p1 - (k-1) * p2)/k
       p2 = p1
       p1 = p
    end do

    fac = 1.0
    if (mod(n,2) == 1) then
      fac = -1.0
    end if

    laguerre_norm = fac*p

  end function laguerre_norm

  elemental function laguerre_lp (n, x)
    implicit none
    integer, intent (in) :: n
    double precision, intent (in) :: x
    double precision :: laguerre_lp

    laguerre_lp = n * (laguerre_l(n,x) - laguerre_l(n-1,x)) / x

  end function laguerre_lp

  subroutine check_laguerre_zeros (zero)
    use file_utils, only: error_unit
    use mp, only: mp_abort
    implicit none
    real, dimension (:), intent (in) :: zero
    logical :: error=.false.
    integer :: i, n

    n = size(zero)

    ! check positiveness
    if (any(zero <= 0.0)) then
       write (error_unit(),*) 'ERROR in laguerre: grid not positive'
       error = .true.
    end if

    ! check alignment
    if (any(zero(2:n)-zero(1:n-1) < 0.0)) then
       write (error_unit(),*) 'ERROR in laguerre: wrong alignment'
       error = .true.
    end if

    ! check distances are increasing
    do i=1, n-2
       if (zero(i+1)-zero(i) > zero(i+2)-zero(i+1)) then
          write (error_unit(),*) 'ERROR in laguerre: distances are decreasing at i= ', i
          error = .true.
       end if
    end do

    if (error) call mp_abort ('STOP in check_laguerre_zeros')

  end subroutine check_laguerre_zeros

  subroutine check_laguerre_weights (wgt, eps)
    use file_utils, only: error_unit
    use mp, only: mp_abort
    implicit none
    real, intent (in) :: eps
    real, dimension (:), intent (in) :: wgt
    logical :: error=.false.
    integer :: imax, n
    real :: s

    n = size(wgt)

    ! check if weights are all positive
    if (any(wgt <= 0.0)) then
       write (error_unit(),*) 'ERROR in laguerre: weights are not positive at n =', n
       error = .true.
    end if

    ! check if there is a single maximum
    imax = sum(maxloc(wgt))
    if (any(wgt(1:imax-1) > wgt(2:imax))) then
       write (error_unit(),*) 'ERROR in laguerre: weights decreasing before maximum'
       error = .true.
    end if
    if (any(wgt(imax:n-1) < wgt(imax+1:n))) then
       write (error_unit(),*) 'ERROR in laguerre: weights increasing after maximum'
       error = .true.
    end if

    ! check if their sum is close enough to normalized value
    if (debug) then
       s = sum(dble(wgt))
       if (abs(s-1.0) > eps) then
          write (error_unit(),*) 'WARNING in laguerre: weights summation incorrect:', &
               size(wgt), s
          ! Do not stop as it is mostly a minor issue
       end if
    end if

    if (error) call mp_abort ('STOP error in check_laguerre_weights')

  end subroutine check_laguerre_weights
end module gauss_quad
