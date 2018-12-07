module simpledataio_read
  use simpledataio_write, only: real_imaginary_dimension_name
  implicit none
  private
  public :: read_variable_with_offset, read_variable


  interface read_variable_with_offset
    module procedure read_variable_with_offset_real_0
    module procedure read_variable_with_offset_real_1
    module procedure read_variable_with_offset_real_2
    module procedure read_variable_with_offset_real_3
    module procedure read_variable_with_offset_real_4
    module procedure read_variable_with_offset_real_5
    module procedure read_variable_with_offset_real_6
    module procedure read_variable_with_offset_double_precision_0
    module procedure read_variable_with_offset_double_precision_1
    module procedure read_variable_with_offset_double_precision_2
    module procedure read_variable_with_offset_double_precision_3
    module procedure read_variable_with_offset_double_precision_4
    module procedure read_variable_with_offset_double_precision_5
    module procedure read_variable_with_offset_double_precision_6
    module procedure read_variable_with_offset_integer_0
    module procedure read_variable_with_offset_integer_1
    module procedure read_variable_with_offset_integer_2
    module procedure read_variable_with_offset_integer_3
    module procedure read_variable_with_offset_integer_4
    module procedure read_variable_with_offset_integer_5
    module procedure read_variable_with_offset_integer_6
    module procedure read_variable_with_offset_character_0
    module procedure read_variable_with_offset_character_1
    module procedure read_variable_with_offset_character_2
    module procedure read_variable_with_offset_character_3
    module procedure read_variable_with_offset_character_4
    module procedure read_variable_with_offset_character_5
    module procedure read_variable_with_offset_character_6
    module procedure read_variable_with_offset_complex_0
    module procedure read_variable_with_offset_complex_1
    module procedure read_variable_with_offset_complex_2
    module procedure read_variable_with_offset_complex_3
    module procedure read_variable_with_offset_complex_4
    module procedure read_variable_with_offset_complex_5
    module procedure read_variable_with_offset_complex_6
    module procedure read_variable_with_offset_complex_16_0
    module procedure read_variable_with_offset_complex_16_1
    module procedure read_variable_with_offset_complex_16_2
    module procedure read_variable_with_offset_complex_16_3
    module procedure read_variable_with_offset_complex_16_4
    module procedure read_variable_with_offset_complex_16_5
    module procedure read_variable_with_offset_complex_16_6
  end interface read_variable_with_offset

  interface read_variable
    module procedure read_variable_real_0
    module procedure read_variable_real_1
    module procedure read_variable_real_2
    module procedure read_variable_real_3
    module procedure read_variable_real_4
    module procedure read_variable_real_5
    module procedure read_variable_real_6
    module procedure read_variable_double_precision_0
    module procedure read_variable_double_precision_1
    module procedure read_variable_double_precision_2
    module procedure read_variable_double_precision_3
    module procedure read_variable_double_precision_4
    module procedure read_variable_double_precision_5
    module procedure read_variable_double_precision_6
    module procedure read_variable_integer_0
    module procedure read_variable_integer_1
    module procedure read_variable_integer_2
    module procedure read_variable_integer_3
    module procedure read_variable_integer_4
    module procedure read_variable_integer_5
    module procedure read_variable_integer_6
    module procedure read_variable_character_0
    module procedure read_variable_character_1
    module procedure read_variable_character_2
    module procedure read_variable_character_3
    module procedure read_variable_character_4
    module procedure read_variable_character_5
    module procedure read_variable_character_6
    module procedure read_variable_complex_0
    module procedure read_variable_complex_1
    module procedure read_variable_complex_2
    module procedure read_variable_complex_3
    module procedure read_variable_complex_4
    module procedure read_variable_complex_5
    module procedure read_variable_complex_6
    module procedure read_variable_complex_16_0
    module procedure read_variable_complex_16_1
    module procedure read_variable_complex_16_2
    module procedure read_variable_complex_16_3
    module procedure read_variable_complex_16_4
    module procedure read_variable_complex_16_5
    module procedure read_variable_complex_16_6
  end interface read_variable


contains

 subroutine read_variable_with_offset_real_0(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   real, intent(out) :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   real, dimension(1) :: valarray

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+0
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        valarray, start=int(starts), count=int(counts))
        val = valarray(1)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_real_0

 subroutine read_variable_with_offset_real_1(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   real, intent(out), dimension(:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+1
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_real_1

 subroutine read_variable_with_offset_real_2(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   real, intent(out), dimension(:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+2
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):,&   
(offsets(2)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_real_2

 subroutine read_variable_with_offset_real_3(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   real, intent(out), dimension(:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+3
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):,&   
(offsets(2)):,&   
(offsets(3)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_real_3

 subroutine read_variable_with_offset_real_4(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   real, intent(out), dimension(:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+4
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):,&   
(offsets(2)):,&   
(offsets(3)):,&   
(offsets(4)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_real_4

 subroutine read_variable_with_offset_real_5(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   real, intent(out), dimension(:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+5
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):,&   
(offsets(2)):,&   
(offsets(3)):,&   
(offsets(4)):,&   
(offsets(5)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_real_5

 subroutine read_variable_with_offset_real_6(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   real, intent(out), dimension(:,:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+6
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):,&   
(offsets(2)):,&   
(offsets(3)):,&   
(offsets(4)):,&   
(offsets(5)):,&   
(offsets(6)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_real_6

 subroutine read_variable_with_offset_double_precision_0(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   double precision, intent(out) :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   double precision, dimension(1) :: valarray

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+0
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        valarray, start=int(starts), count=int(counts))
        val = valarray(1)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_double_precision_0

 subroutine read_variable_with_offset_double_precision_1(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   double precision, intent(out), dimension(:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+1
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_double_precision_1

 subroutine read_variable_with_offset_double_precision_2(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   double precision, intent(out), dimension(:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+2
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):,&   
(offsets(2)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_double_precision_2

 subroutine read_variable_with_offset_double_precision_3(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   double precision, intent(out), dimension(:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+3
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):,&   
(offsets(2)):,&   
(offsets(3)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_double_precision_3

 subroutine read_variable_with_offset_double_precision_4(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   double precision, intent(out), dimension(:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+4
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):,&   
(offsets(2)):,&   
(offsets(3)):,&   
(offsets(4)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_double_precision_4

 subroutine read_variable_with_offset_double_precision_5(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   double precision, intent(out), dimension(:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+5
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):,&   
(offsets(2)):,&   
(offsets(3)):,&   
(offsets(4)):,&   
(offsets(5)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_double_precision_5

 subroutine read_variable_with_offset_double_precision_6(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   double precision, intent(out), dimension(:,:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+6
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):,&   
(offsets(2)):,&   
(offsets(3)):,&   
(offsets(4)):,&   
(offsets(5)):,&   
(offsets(6)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_double_precision_6

 subroutine read_variable_with_offset_integer_0(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   integer, intent(out) :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   integer, dimension(1) :: valarray

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+0
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        valarray, start=int(starts), count=int(counts))
        val = valarray(1)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_integer_0

 subroutine read_variable_with_offset_integer_1(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   integer, intent(out), dimension(:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+1
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_integer_1

 subroutine read_variable_with_offset_integer_2(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   integer, intent(out), dimension(:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+2
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):,&   
(offsets(2)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_integer_2

 subroutine read_variable_with_offset_integer_3(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   integer, intent(out), dimension(:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+3
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):,&   
(offsets(2)):,&   
(offsets(3)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_integer_3

 subroutine read_variable_with_offset_integer_4(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   integer, intent(out), dimension(:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+4
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):,&   
(offsets(2)):,&   
(offsets(3)):,&   
(offsets(4)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_integer_4

 subroutine read_variable_with_offset_integer_5(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   integer, intent(out), dimension(:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+5
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):,&   
(offsets(2)):,&   
(offsets(3)):,&   
(offsets(4)):,&   
(offsets(5)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_integer_5

 subroutine read_variable_with_offset_integer_6(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   integer, intent(out), dimension(:,:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+6
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):,&   
(offsets(2)):,&   
(offsets(3)):,&   
(offsets(4)):,&   
(offsets(5)):,&   
(offsets(6)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_integer_6

 subroutine read_variable_with_offset_character_0(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   character, intent(out) :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   character, dimension(1) :: valarray

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+0
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        valarray, start=int(starts), count=int(counts))
        val = valarray(1)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_character_0

 subroutine read_variable_with_offset_character_1(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   character, intent(out), dimension(:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+1
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_character_1

 subroutine read_variable_with_offset_character_2(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   character, intent(out), dimension(:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+2
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):,&   
(offsets(2)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_character_2

 subroutine read_variable_with_offset_character_3(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   character, intent(out), dimension(:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+3
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):,&   
(offsets(2)):,&   
(offsets(3)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_character_3

 subroutine read_variable_with_offset_character_4(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   character, intent(out), dimension(:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+4
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):,&   
(offsets(2)):,&   
(offsets(3)):,&   
(offsets(4)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_character_4

 subroutine read_variable_with_offset_character_5(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   character, intent(out), dimension(:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+5
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):,&   
(offsets(2)):,&   
(offsets(3)):,&   
(offsets(4)):,&   
(offsets(5)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_character_5

 subroutine read_variable_with_offset_character_6(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   character, intent(out), dimension(:,:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+6
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val((offsets(1)):,&   
(offsets(2)):,&   
(offsets(3)):,&   
(offsets(4)):,&   
(offsets(5)):,&   
(offsets(6)):), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_character_6

 subroutine read_variable_with_offset_complex_0(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex, intent(out) :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   real, dimension(1) :: realval
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+0+1
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval, start=int(starts), count=int(counts))
         
   val = &
      val +  &
      realval(1) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval, start=int(starts), count=int(counts))
         
   val = &
      val +  &
      realval(1) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_complex_0

 subroutine read_variable_with_offset_complex_1(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex, intent(out), dimension(:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   real, dimension(1, size(val, 1)) :: realval
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+1+1
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):), start=int(starts), count=int(counts))
         
   val(:) = &
      val(:) +  &
      realval(1,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):), start=int(starts), count=int(counts))
         
   val(:) = &
      val(:) +  &
      realval(1,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_complex_1

 subroutine read_variable_with_offset_complex_2(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex, intent(out), dimension(:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   real, dimension(1, size(val, 1), size(val, 2)) :: realval
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+2+1
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):,&
                 (offsets(3)):), start=int(starts), count=int(counts))
         
   val(:,:) = &
      val(:,:) +  &
      realval(1,:,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):,&
                 (offsets(3)):), start=int(starts), count=int(counts))
         
   val(:,:) = &
      val(:,:) +  &
      realval(1,:,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_complex_2

 subroutine read_variable_with_offset_complex_3(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex, intent(out), dimension(:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   real, dimension(1, size(val, 1), size(val, 2), size(val, 3)) :: realval
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+3+1
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):,&
                 (offsets(3)):,&
                 (offsets(4)):), start=int(starts), count=int(counts))
         
   val(:,:,:) = &
      val(:,:,:) +  &
      realval(1,:,:,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):,&
                 (offsets(3)):,&
                 (offsets(4)):), start=int(starts), count=int(counts))
         
   val(:,:,:) = &
      val(:,:,:) +  &
      realval(1,:,:,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_complex_3

 subroutine read_variable_with_offset_complex_4(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex, intent(out), dimension(:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   real, dimension(1, size(val, 1), size(val, 2), size(val, 3), size(val, 4)) :: realval
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+4+1
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):,&
                 (offsets(3)):,&
                 (offsets(4)):,&
                 (offsets(5)):), start=int(starts), count=int(counts))
         
   val(:,:,:,:) = &
      val(:,:,:,:) +  &
      realval(1,:,:,:,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):,&
                 (offsets(3)):,&
                 (offsets(4)):,&
                 (offsets(5)):), start=int(starts), count=int(counts))
         
   val(:,:,:,:) = &
      val(:,:,:,:) +  &
      realval(1,:,:,:,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_complex_4

 subroutine read_variable_with_offset_complex_5(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex, intent(out), dimension(:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   real, dimension(1, size(val, 1), size(val, 2), size(val, 3), size(val, 4), size(val, 5)) :: realval
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+5+1
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):,&
                 (offsets(3)):,&
                 (offsets(4)):,&
                 (offsets(5)):,&
                 (offsets(6)):), start=int(starts), count=int(counts))
         
   val(:,:,:,:,:) = &
      val(:,:,:,:,:) +  &
      realval(1,:,:,:,:,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):,&
                 (offsets(3)):,&
                 (offsets(4)):,&
                 (offsets(5)):,&
                 (offsets(6)):), start=int(starts), count=int(counts))
         
   val(:,:,:,:,:) = &
      val(:,:,:,:,:) +  &
      realval(1,:,:,:,:,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_complex_5

 subroutine read_variable_with_offset_complex_6(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex, intent(out), dimension(:,:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   real, dimension(1, size(val, 1), size(val, 2), size(val, 3), size(val, 4), size(val, 5), size(val, 6)) :: realval
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+6+1
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):,&
                 (offsets(3)):,&
                 (offsets(4)):,&
                 (offsets(5)):,&
                 (offsets(6)):,&
                 (offsets(7)):), start=int(starts), count=int(counts))
         
   val(:,:,:,:,:,:) = &
      val(:,:,:,:,:,:) +  &
      realval(1,:,:,:,:,:,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):,&
                 (offsets(3)):,&
                 (offsets(4)):,&
                 (offsets(5)):,&
                 (offsets(6)):,&
                 (offsets(7)):), start=int(starts), count=int(counts))
         
   val(:,:,:,:,:,:) = &
      val(:,:,:,:,:,:) +  &
      realval(1,:,:,:,:,:,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_complex_6

 subroutine read_variable_with_offset_complex_16_0(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex*16, intent(out) :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   double precision, dimension(1) :: realval
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+0+1
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval, start=int(starts), count=int(counts))
         
   val = &
      val +  &
      realval(1) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval, start=int(starts), count=int(counts))
         
   val = &
      val +  &
      realval(1) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_complex_16_0

 subroutine read_variable_with_offset_complex_16_1(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex*16, intent(out), dimension(:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   double precision, dimension(1, size(val, 1)) :: realval
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+1+1
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):), start=int(starts), count=int(counts))
         
   val(:) = &
      val(:) +  &
      realval(1,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):), start=int(starts), count=int(counts))
         
   val(:) = &
      val(:) +  &
      realval(1,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_complex_16_1

 subroutine read_variable_with_offset_complex_16_2(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex*16, intent(out), dimension(:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   double precision, dimension(1, size(val, 1), size(val, 2)) :: realval
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+2+1
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):,&
                 (offsets(3)):), start=int(starts), count=int(counts))
         
   val(:,:) = &
      val(:,:) +  &
      realval(1,:,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):,&
                 (offsets(3)):), start=int(starts), count=int(counts))
         
   val(:,:) = &
      val(:,:) +  &
      realval(1,:,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_complex_16_2

 subroutine read_variable_with_offset_complex_16_3(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex*16, intent(out), dimension(:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   double precision, dimension(1, size(val, 1), size(val, 2), size(val, 3)) :: realval
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+3+1
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):,&
                 (offsets(3)):,&
                 (offsets(4)):), start=int(starts), count=int(counts))
         
   val(:,:,:) = &
      val(:,:,:) +  &
      realval(1,:,:,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):,&
                 (offsets(3)):,&
                 (offsets(4)):), start=int(starts), count=int(counts))
         
   val(:,:,:) = &
      val(:,:,:) +  &
      realval(1,:,:,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_complex_16_3

 subroutine read_variable_with_offset_complex_16_4(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex*16, intent(out), dimension(:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   double precision, dimension(1, size(val, 1), size(val, 2), size(val, 3), size(val, 4)) :: realval
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+4+1
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):,&
                 (offsets(3)):,&
                 (offsets(4)):,&
                 (offsets(5)):), start=int(starts), count=int(counts))
         
   val(:,:,:,:) = &
      val(:,:,:,:) +  &
      realval(1,:,:,:,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):,&
                 (offsets(3)):,&
                 (offsets(4)):,&
                 (offsets(5)):), start=int(starts), count=int(counts))
         
   val(:,:,:,:) = &
      val(:,:,:,:) +  &
      realval(1,:,:,:,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_complex_16_4

 subroutine read_variable_with_offset_complex_16_5(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex*16, intent(out), dimension(:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   double precision, dimension(1, size(val, 1), size(val, 2), size(val, 3), size(val, 4), size(val, 5)) :: realval
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+5+1
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):,&
                 (offsets(3)):,&
                 (offsets(4)):,&
                 (offsets(5)):,&
                 (offsets(6)):), start=int(starts), count=int(counts))
         
   val(:,:,:,:,:) = &
      val(:,:,:,:,:) +  &
      realval(1,:,:,:,:,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):,&
                 (offsets(3)):,&
                 (offsets(4)):,&
                 (offsets(5)):,&
                 (offsets(6)):), start=int(starts), count=int(counts))
         
   val(:,:,:,:,:) = &
      val(:,:,:,:,:) +  &
      realval(1,:,:,:,:,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_complex_16_5

 subroutine read_variable_with_offset_complex_16_6(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex*16, intent(out), dimension(:,:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   integer :: n, ndims
   double precision, dimension(1, size(val, 1), size(val, 2), size(val, 3), size(val, 4), size(val, 5), size(val, 6)) :: realval
   

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   n2 = n+6+1
   ndims = number_of_dimensions(sfile, variable_name)
   if (ndims /= n2) then
      write (*,*) "WARNING: The variable you pass to read_variable must have the same size &
           & and shape (excluding unlimited dimensions and the complex dimension) &
           & as the variable in the output file, regardless of what the values of starts &
           & and counts are. If you want to use a pass a different array shape to val &
           & you need to use read_variable_no_offset, which will behave in the default &
           & way for netcdf. &
           & You are probably about to encounter a segmentation fault. "
   end if

   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):,&
                 (offsets(3)):,&
                 (offsets(4)):,&
                 (offsets(5)):,&
                 (offsets(6)):,&
                 (offsets(7)):), start=int(starts), count=int(counts))
         
   val(:,:,:,:,:,:) = &
      val(:,:,:,:,:,:) +  &
      realval(1,:,:,:,:,:,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,(offsets(2)):,&
                 (offsets(3)):,&
                 (offsets(4)):,&
                 (offsets(5)):,&
                 (offsets(6)):,&
                 (offsets(7)):), start=int(starts), count=int(counts))
         
   val(:,:,:,:,:,:) = &
      val(:,:,:,:,:,:) +  &
      realval(1,:,:,:,:,:,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_with_offset_complex_16_6


 subroutine read_variable_real_0(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   real, intent(out) :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   real, dimension(1) :: valarray

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        valarray, start=int(starts), count=int(counts))
        val = valarray(1)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_real_0

 subroutine read_variable_real_1(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   real, intent(out), dimension(:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_real_1

 subroutine read_variable_real_2(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   real, intent(out), dimension(:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:,:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_real_2

 subroutine read_variable_real_3(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   real, intent(out), dimension(:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:,:,:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_real_3

 subroutine read_variable_real_4(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   real, intent(out), dimension(:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:,:,:,:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_real_4

 subroutine read_variable_real_5(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   real, intent(out), dimension(:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:,:,:,:,:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_real_5

 subroutine read_variable_real_6(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   real, intent(out), dimension(:,:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:,:,:,:,:,:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_real_6

 subroutine read_variable_double_precision_0(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   double precision, intent(out) :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   double precision, dimension(1) :: valarray

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        valarray, start=int(starts), count=int(counts))
        val = valarray(1)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_double_precision_0

 subroutine read_variable_double_precision_1(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   double precision, intent(out), dimension(:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_double_precision_1

 subroutine read_variable_double_precision_2(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   double precision, intent(out), dimension(:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:,:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_double_precision_2

 subroutine read_variable_double_precision_3(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   double precision, intent(out), dimension(:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:,:,:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_double_precision_3

 subroutine read_variable_double_precision_4(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   double precision, intent(out), dimension(:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:,:,:,:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_double_precision_4

 subroutine read_variable_double_precision_5(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   double precision, intent(out), dimension(:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:,:,:,:,:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_double_precision_5

 subroutine read_variable_double_precision_6(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   double precision, intent(out), dimension(:,:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:,:,:,:,:,:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_double_precision_6

 subroutine read_variable_integer_0(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   integer, intent(out) :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   integer, dimension(1) :: valarray

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        valarray, start=int(starts), count=int(counts))
        val = valarray(1)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_integer_0

 subroutine read_variable_integer_1(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   integer, intent(out), dimension(:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_integer_1

 subroutine read_variable_integer_2(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   integer, intent(out), dimension(:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:,:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_integer_2

 subroutine read_variable_integer_3(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   integer, intent(out), dimension(:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:,:,:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_integer_3

 subroutine read_variable_integer_4(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   integer, intent(out), dimension(:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:,:,:,:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_integer_4

 subroutine read_variable_integer_5(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   integer, intent(out), dimension(:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:,:,:,:,:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_integer_5

 subroutine read_variable_integer_6(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   integer, intent(out), dimension(:,:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:,:,:,:,:,:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_integer_6

 subroutine read_variable_character_0(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   character, intent(out) :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   character, dimension(1) :: valarray

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        valarray, start=int(starts), count=int(counts))
        val = valarray(1)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_character_0

 subroutine read_variable_character_1(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   character, intent(out), dimension(:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_character_1

 subroutine read_variable_character_2(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   character, intent(out), dimension(:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:,:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_character_2

 subroutine read_variable_character_3(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   character, intent(out), dimension(:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:,:,:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_character_3

 subroutine read_variable_character_4(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   character, intent(out), dimension(:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:,:,:,:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_character_4

 subroutine read_variable_character_5(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   character, intent(out), dimension(:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:,:,:,:,:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_character_5

 subroutine read_variable_character_6(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   character, intent(out), dimension(:,:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   
     
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets)
   status =  nf90_get_var(fileid, varid+1, &
        val(:,:,:,:,:,:), start=int(starts), count=int(counts))
        
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_character_6

 subroutine read_variable_complex_0(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex, intent(out) :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   real, dimension(1) :: realval
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval, start=int(starts), count=int(counts))
         
   val = &
      val +  &
      realval(1) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval, start=int(starts), count=int(counts))
         
   val = &
      val +  &
      realval(1) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_complex_0

 subroutine read_variable_complex_1(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex, intent(out), dimension(:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   real, dimension(1, size(val, 1)) :: realval
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:), start=int(starts), count=int(counts))
         
   val(:) = &
      val(:) +  &
      realval(1,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:), start=int(starts), count=int(counts))
         
   val(:) = &
      val(:) +  &
      realval(1,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_complex_1

 subroutine read_variable_complex_2(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex, intent(out), dimension(:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   real, dimension(1, size(val, 1), size(val, 2)) :: realval
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:,:), start=int(starts), count=int(counts))
         
   val(:,:) = &
      val(:,:) +  &
      realval(1,:,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:,:), start=int(starts), count=int(counts))
         
   val(:,:) = &
      val(:,:) +  &
      realval(1,:,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_complex_2

 subroutine read_variable_complex_3(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex, intent(out), dimension(:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   real, dimension(1, size(val, 1), size(val, 2), size(val, 3)) :: realval
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:,:,:), start=int(starts), count=int(counts))
         
   val(:,:,:) = &
      val(:,:,:) +  &
      realval(1,:,:,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:,:,:), start=int(starts), count=int(counts))
         
   val(:,:,:) = &
      val(:,:,:) +  &
      realval(1,:,:,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_complex_3

 subroutine read_variable_complex_4(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex, intent(out), dimension(:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   real, dimension(1, size(val, 1), size(val, 2), size(val, 3), size(val, 4)) :: realval
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:,:,:,:), start=int(starts), count=int(counts))
         
   val(:,:,:,:) = &
      val(:,:,:,:) +  &
      realval(1,:,:,:,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:,:,:,:), start=int(starts), count=int(counts))
         
   val(:,:,:,:) = &
      val(:,:,:,:) +  &
      realval(1,:,:,:,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_complex_4

 subroutine read_variable_complex_5(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex, intent(out), dimension(:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   real, dimension(1, size(val, 1), size(val, 2), size(val, 3), size(val, 4), size(val, 5)) :: realval
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:,:,:,:,:), start=int(starts), count=int(counts))
         
   val(:,:,:,:,:) = &
      val(:,:,:,:,:) +  &
      realval(1,:,:,:,:,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:,:,:,:,:), start=int(starts), count=int(counts))
         
   val(:,:,:,:,:) = &
      val(:,:,:,:,:) +  &
      realval(1,:,:,:,:,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_complex_5

 subroutine read_variable_complex_6(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex, intent(out), dimension(:,:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   real, dimension(1, size(val, 1), size(val, 2), size(val, 3), size(val, 4), size(val, 5), size(val, 6)) :: realval
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:,:,:,:,:,:), start=int(starts), count=int(counts))
         
   val(:,:,:,:,:,:) = &
      val(:,:,:,:,:,:) +  &
      realval(1,:,:,:,:,:,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:,:,:,:,:,:), start=int(starts), count=int(counts))
         
   val(:,:,:,:,:,:) = &
      val(:,:,:,:,:,:) +  &
      realval(1,:,:,:,:,:,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_complex_6

 subroutine read_variable_complex_16_0(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex*16, intent(out) :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   double precision, dimension(1) :: realval
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval, start=int(starts), count=int(counts))
         
   val = &
      val +  &
      realval(1) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval, start=int(starts), count=int(counts))
         
   val = &
      val +  &
      realval(1) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_complex_16_0

 subroutine read_variable_complex_16_1(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex*16, intent(out), dimension(:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   double precision, dimension(1, size(val, 1)) :: realval
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:), start=int(starts), count=int(counts))
         
   val(:) = &
      val(:) +  &
      realval(1,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:), start=int(starts), count=int(counts))
         
   val(:) = &
      val(:) +  &
      realval(1,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_complex_16_1

 subroutine read_variable_complex_16_2(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex*16, intent(out), dimension(:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   double precision, dimension(1, size(val, 1), size(val, 2)) :: realval
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:,:), start=int(starts), count=int(counts))
         
   val(:,:) = &
      val(:,:) +  &
      realval(1,:,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:,:), start=int(starts), count=int(counts))
         
   val(:,:) = &
      val(:,:) +  &
      realval(1,:,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_complex_16_2

 subroutine read_variable_complex_16_3(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex*16, intent(out), dimension(:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   double precision, dimension(1, size(val, 1), size(val, 2), size(val, 3)) :: realval
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:,:,:), start=int(starts), count=int(counts))
         
   val(:,:,:) = &
      val(:,:,:) +  &
      realval(1,:,:,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:,:,:), start=int(starts), count=int(counts))
         
   val(:,:,:) = &
      val(:,:,:) +  &
      realval(1,:,:,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_complex_16_3

 subroutine read_variable_complex_16_4(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex*16, intent(out), dimension(:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   double precision, dimension(1, size(val, 1), size(val, 2), size(val, 3), size(val, 4)) :: realval
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:,:,:,:), start=int(starts), count=int(counts))
         
   val(:,:,:,:) = &
      val(:,:,:,:) +  &
      realval(1,:,:,:,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:,:,:,:), start=int(starts), count=int(counts))
         
   val(:,:,:,:) = &
      val(:,:,:,:) +  &
      realval(1,:,:,:,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_complex_16_4

 subroutine read_variable_complex_16_5(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex*16, intent(out), dimension(:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   double precision, dimension(1, size(val, 1), size(val, 2), size(val, 3), size(val, 4), size(val, 5)) :: realval
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:,:,:,:,:), start=int(starts), count=int(counts))
         
   val(:,:,:,:,:) = &
      val(:,:,:,:,:) +  &
      realval(1,:,:,:,:,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:,:,:,:,:), start=int(starts), count=int(counts))
         
   val(:,:,:,:,:) = &
      val(:,:,:,:,:) +  &
      realval(1,:,:,:,:,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_complex_16_5

 subroutine read_variable_complex_16_6(sfile, variable_name, val)
   use netcdf, only: nf90_get_var, nf90_strerror
   use simpledataio, only: number_of_unlimited_dimensions, number_of_dimensions, netcdf_inputs
   use simpledataio, only: sdatio_file, sdatio_int_kind, set_count, set_start
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   complex*16, intent(out), dimension(:,:,:,:,:,:)  :: val
   integer(sdatio_int_kind), dimension(:), allocatable :: starts, counts, offsets
   integer :: fileid, varid, status, n2
   
   double precision, dimension(1, size(val, 1), size(val, 2), size(val, 3), size(val, 4), size(val, 5), size(val, 6)) :: realval
   

   n2 = number_of_dimensions(sfile, variable_name)
   allocate(starts(n2))
   allocate(counts(n2))
   allocate(offsets(n2))
   val = 0.0
   
   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:,:,:,:,:,:), start=int(starts), count=int(counts))
         
   val(:,:,:,:,:,:) = &
      val(:,:,:,:,:,:) +  &
      realval(1,:,:,:,:,:,:) * (1.0,0.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts


   call set_count(sfile, variable_name, trim(real_imaginary_dimension_name), 1)
   call set_start(sfile, variable_name, trim(real_imaginary_dimension_name), 2)
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts, offsets) 
   status =  nf90_get_var(fileid, varid+1, &
        realval(1:,:,:,:,:,:,:), start=int(starts), count=int(counts))
         
   val(:,:,:,:,:,:) = &
      val(:,:,:,:,:,:) +  &
      realval(1,:,:,:,:,:,:) * (0.0,1.0)
   if (.not. status .eq. 0) write (*,*) 'Error reading variable: ', &
        variable_name, ', ',  nf90_strerror(status), 'starts=', starts, 'counts=', counts

   deallocate(starts, offsets, counts)
 end subroutine read_variable_complex_16_6


end module simpledataio_read

