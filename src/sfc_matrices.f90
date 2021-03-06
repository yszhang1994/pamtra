module sfc_matrices
  use kinds
  use report_module
  use constants, only: c
  use settings, only: freqs, nummu, nstokes, mu_values, quad_weights, ground_type
  use vars_rt, only: rt_sfc_emissivity, rt_sfc_reflectivity
  use vars_index, only: i_x, i_y, i_f
  use vars_atmosphere, only: atmo_groundtemp
  use rt_utilities, only: planck_function
  
  implicit none


  integer :: n,j 
  real(dbl) :: rv, rh, r1, r2, r3, r4
  real(dbl) :: planck, wavelength
!  real(kind=dbl) :: reflect (nstokes, nummu, nstokes, nummu, 2) 
!  real(kind=dbl) :: trans (nstokes, nummu, nstokes, nummu, 2) 
!  real(kind=dbl) :: radiance (nstokes, nummu)
 
  contains
  subroutine get_sfc_matrices(errorstatus,reflect, trans,radiance)
!  subroutine get_sfc_matrices(errorstatus)
    real(kind=dbl), intent(out) :: reflect (nstokes, nummu, nstokes, nummu, 2) 
    real(kind=dbl), intent(out) :: trans (nstokes, nummu, nstokes, nummu, 2) 
    real(kind=dbl), intent(out) :: radiance (nstokes, nummu)

    integer, intent(out) :: errorstatus
  
    integer(kind=long) :: err = 0
    character(len=80) :: msg
    character(len=14) :: nameOfRoutine = 'get_sfc_matrices'

    if (verbose >= 3) call report(info,'Start of ', nameOfRoutine)

    reflect = 0._dbl
    trans = 0._dbl
    radiance = 0._dbl

    wavelength = c / (freqs(i_f)*1.d3)
 
    n = nstokes * nummu 
    
    if (verbose >= 4) then
      print*, 'Debug output in ', nameOfRoutine
      print*, 'wavelength: ', wavelength
      print*, 'ground_type: ', ground_type
      print*, 'rt_sfc_emissivity: ', rt_sfc_emissivity(1,1)
      print*, 'rt_sfc_reflectivity: ', rt_sfc_reflectivity(1,1)
    end if

    if (ground_type .eq. 'O' .or. ground_type .eq. 'F') then
      call fresnel_matrices(reflect, trans,radiance)
      if (err /= 0) then
          msg = 'error in surface reflection calculation'
          call report(err,msg, nameOfRoutine)
          errorstatus = err
          return
      end if   
    else if (ground_type .eq. 'L') then
      call lambert_matrices(reflect, trans,radiance)
      if (err /= 0) then
          msg = 'error in surface reflection calculation'
          call report(err,msg, nameOfRoutine)
          errorstatus = err
          return
      end if
    else if (ground_type .eq. 'S') then
      call specular_matrices(reflect, trans, radiance)
      if (err /= 0) then
          msg = 'error in surface reflection calculation'
          call report(err,msg, nameOfRoutine)
          errorstatus = err
          return
      end if
    else
      msg = 'Wrong or no ground_type selected'
      call report(err,msg, nameOfRoutine)
      errorstatus = 1
    end if

    if (verbose >= 3) call report(info,'End of ', nameOfRoutine)
    
  end subroutine get_sfc_matrices
  
  subroutine fresnel_matrices(reflect, trans,radiance)!(reflect,trans,radiance)

    real(kind=dbl), intent(out) :: reflect (nstokes, nummu, nstokes, nummu, 2) 
    real(kind=dbl), intent(out) :: trans (nstokes, nummu, nstokes, nummu, 2) 
    real(kind=dbl), intent(out) :: radiance (nstokes, nummu)
    character(len=14) :: nameOfRoutine = 'fresnel_matrices'
    
    if (verbose >= 3) call report(info,'Start of ', nameOfRoutine)

    call midentity (n, trans (1, 1, 1, 1, 1) ) 
    call midentity (n, trans (1, 1, 1, 1, 2) ) 

    call planck_function(atmo_groundtemp(i_x,i_y), 'r', wavelength, planck) 
    do j = 1, nummu 
      rv = rt_sfc_reflectivity(1,j) ! The square of the vertical abs value
      rh = rt_sfc_reflectivity(2,j) ! The square of the horizontal abs value
      r1 = (rv+rh)/2.0d0
      r2 = (rv-rh)/2.0d0
      reflect (1, j, 1, j, 2) = r1 
      if (nstokes.gt.1) then 
	  reflect (1, j, 2, j, 2) = r2 
	  reflect (2, j, 1, j, 2) = r2 
	  reflect (2, j, 2, j, 2) = r1 
      end if
      radiance (1, j) = (1.0 - r1) * planck 
      if (nstokes .gt. 1) radiance(2, j) = - r2 * planck 
    end do

    if (verbose >= 3) call report(info,'End of ', nameOfRoutine)
    
  end subroutine fresnel_matrices
  
  subroutine lambert_matrices(reflect, trans,radiance)
  
    integer :: j, j1, j2
    real(kind=dbl), intent(out) :: reflect (nstokes, nummu, nstokes, nummu, 2) 
    real(kind=dbl), intent(out) :: trans (nstokes, nummu, nstokes, nummu, 2) 
    real(kind=dbl), intent(out) :: radiance (nstokes, nummu)
    character(len=14) :: nameOfRoutine = 'lambert_matrices'
    
    if (verbose >= 3) call report(info,'Start of ', nameOfRoutine)

    n = nstokes * nummu 
    call midentity (n, trans (1, 1, 1, 1, 1) ) 
    call midentity (n, trans (1, 1, 1, 1, 2) ) 

    call planck_function(atmo_groundtemp(i_x,i_y), 'r', wavelength, planck)

    ! the lambertian ground reflects the flux equally in all directions
    ! and completely unpolarizes the radiation                  
    do j1 = 1, nummu 
      do j2 = 1, nummu 
	  reflect(1,j1,1,j2,2) = 2.0 * rt_sfc_reflectivity(1,1) * mu_values(  &
	      j2) * quad_weights(j2)                                        
      end do
    end do

    do j = 1, nummu
       radiance(1, j) = rt_sfc_emissivity(1,1) * planck
    end do

    if (verbose >= 3) call report(info,'End of ', nameOfRoutine)
    
  end subroutine lambert_matrices

  subroutine specular_matrices(reflect, trans,radiance)

    integer :: j
    real(kind=dbl), intent(out) :: reflect(nstokes, nummu, nstokes, nummu, 2) 
    real(kind=dbl), intent(out) :: trans(nstokes, nummu, nstokes, nummu, 2) 
    real(kind=dbl), intent(out) :: radiance(nstokes, nummu)
    
    character(len=14) :: nameOfRoutine = 'specular_matrices'
    
    if (verbose >= 3) call report(info,'Start of ', nameOfRoutine)
    
    call midentity(n, trans(1, 1, 1, 1, 1)) 
    call midentity(n, trans(1, 1, 1, 1, 2)) 

    do j = 1, nummu 
      r1 = rt_sfc_reflectivity(1,1)
      reflect(1, j, 1, j, 2) = r1 
      r2 = 0.
      if (nstokes .gt. 1) then 
	  reflect(1, j, 2, j, 2) = r2 
	  reflect(2, j, 1, j, 2) = r2 
	  reflect(2, j, 2, j, 2) = r1 
      end if
    end do
    
    call planck_function(atmo_groundtemp(i_x,i_y), 'r', wavelength, planck) 
    do j = 1, nummu 
      radiance (1, j) = rt_sfc_emissivity(1,1) * planck 
    end do
    
    if (verbose >= 3) call report(info,'End of ', nameOfRoutine)
    
  end subroutine specular_matrices

end module sfc_matrices