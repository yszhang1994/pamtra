module equcom 

  use kinds, only: sgl

  implicit none
  save

  real(kind=sgl), dimension(720) :: ncells
  real(kind=sgl), dimension(1440,720) :: tocell

end module equcom
