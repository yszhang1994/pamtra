SUBROUTINE LEGEndre2PHASEFUNCTION (A1, LMAX, NPNA, NPL, P11, ANG)

      use kinds

      IMPLICIT NONE

      INTEGER NPNA, NPL, LMAX, L1, L1MAX, I1
      REAL(kind=dbl) PL (NPL), A1 (NPL), ANG (NPNA), P11 (NPNA), DN, DA, DB
      REAL(kind=dbl) D6, TAA, TB, U, F11
! ***
      DN = 1D0 / DFLOAT (NPNA - 1)
      DA = DACOS ( - 1D0) * DN
      DB = 180D0 * DN
      L1MAX = LMAX + 1

! *** COMPUTATION OF .F11
      TB = - DB
      TAA = - DA
      D6 = DSQRT (6D0) * 0.25D0

! *** LOOP ON THE NUMBER OF ANGLES

      DO 500 I1 = 1, NPNA
         TAA = TAA + DA
         TB = TB + DB
         U = COS (TAA)
! ==> FOR LEGENDRE
         CALL FLEG2 (U, PL, L1MAX)
         F11 = 0.D0

         DO 403 L1 = 1, L1MAX
            F11 = F11 + A1 (L1) * PL (L1)
  403    END DO


         P11 (I1) = F11
         ANG (I1) = TB * DACOS ( - 1.D0) / 180.0
  500 END DO

      RETURN
END SUBROUTINE LEGEndre2PHASEFUNCTION
