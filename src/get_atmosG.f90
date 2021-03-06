subroutine get_atmosg(freq)!, kextatmo_o2,kextatmo_h2o,kextatmo_n2)
  !                                                                        
  !     Calculate average air pressure and vapor pressure in specified    
  !     layers, given the temperature, pressure, and relative humidity    
  !     from cloud-resolving model output.                                
  !     vapor_pressure viene data in mb = hPa
  !
  !     convert from Np/km to Np/m

  use kinds
  use vars_atmosphere
  use settings
  use vars_index, only: i_x, i_y

  implicit none



  !   integer, intent(in) :: nlyr
  integer :: nz
  !   real(kind=dbl), dimension(nlyr), intent(in) :: press
  !   real(kind=dbl), dimension(nlyr), intent(in) :: temp
  !   real(kind=dbl), dimension(nlyr), intent(in) :: vapor_pressure
  !   real(kind=dbl), dimension(nlyr), intent(in) :: rho_vap
  ! real(kind=dbl), dimension(nlyr), intent(out) ::  kextatmo_o2, kextatmo_h2o, kextatmo_n2
  real(kind=dbl) :: absair, abswv
  !  real(kind=dbl) :: abs_o2, abs_n2                                                                        
  real(kind=dbl), intent(in) :: freq
  real(kind=dbl) :: tc

  !   character(3) :: gas_mod


  do nz = 1, atmo_nlyrs(i_x,i_y)          

     tc = atmo_temp(i_x,i_y,nz) - 273.15 
     if (gas_mod .eq. 'L93') then
        call mpm93(freq, atmo_press(i_x,i_y,nz)/1.d3, atmo_vapor_pressure(i_x,i_y,nz)/1.d3,tc, 0.0d0, rt_kextatmo(nz))
        rt_kextatmo(nz) = rt_kextatmo(nz)/1000.
     else if (gas_mod .eq. 'R98') then
        ! Rosenkranz 1998 gas absorption model
        ! Input parameters:
        !    frequency                    GHz
        !    temperature                   K
        !    water vapor density         kg/m**3
        !    total air pressure            Pa
        !
        ! Output parameters:
        !    extinction by dry air       Np/km
        !    extinction by water vapor   Np/km      
        call gasabsr98(freq,atmo_temp(i_x,i_y,nz),atmo_rho_vap(i_x,i_y,nz),atmo_press(i_x,i_y,nz),absair,abswv)!,abs_n2,abs_o2)

        rt_kextatmo(nz) = (absair + abswv)/1000.    ! [Np/m]

     else
        rt_kextatmo(nz) = 0
        print*, "No gas absorption model specified!"
        stop
     end if


  end do


  
  if (verbose .gt. 1) print*, 'variables filled up!'                                                            
  return 

end subroutine get_atmosg
