PROGRAM Folding_time_series
        use iso_fortran_env
        IMPLICIT NONE
        INTEGER::i,j,j_loop_count,k1,k4,sample_size_in_bytes=4,n_chan=1,n_bins,k3a4, k3a5
        INTEGER(kind=int64)::size_in_bytes=1105347936.0,n_samples,loop_size=149533.0!17327145.0 ! 36617.0*128=4686976.0
        REAL(kind=4),ALLOCATABLE,DIMENSION(:)::read_array, folded_profile
        REAL(kind=4),ALLOCATABLE,DIMENSION(:,:)::write_array, N_parts_array, subint_array
        REAL(kind=16)::t_sample, k2,P, P_d,P_dd, const1,const2,const3, N_t
        REAL(kind=8):: k3a1, k3a2, k3a3 ! Period and t_sample in seconds
        t_sample=10.24e-6  ! in seconds
        P=5.31338255461464e-3   ! in seconds
        P_d=-2.06826982208285e-11
        P_dd=1.82686138788885e-14 !1.82686138788885*(10.0**(-14))
        n_bins=nint(P/t_sample) !Changing n_bins may cause structures in subintegration plots
        const1=1.0/P
        const2=-P_d/(2.0*P**2)
        const3=P_d**2/(3.0*P**3)-P_dd/(6.0*P**2)
        print*, P, P_d, P_dd, t_sample
        print*, const1, const2, const3
        print*, 'note that number of samples = size_in_bytes/sample_size_in_bytes here, consider this while entering loop_size'
        print*, 'loop_size should be multiple of n_chan'
        n_samples=size_in_bytes/sample_size_in_bytes
        print*, 'set bins=', n_bins,';', 'maximum possible bins=', nint(P/t_sample)
        ALLOCATE(read_array(loop_size), folded_profile(n_bins))
        ALLOCATE(write_array(n_chan, n_bins))
        OPEN(UNIT=1, FILE='HR_1516-43_gsb_ia.dedisp_bandshape_corrected_FT',ACCESS='STREAM')
        OPEN(UNIT=2, FILE='raw_dedisp_I_sub-band_folded.plot')
        OPEN(UNIT=3, FILE='raw_dedisp_I_FT_folded.plot')
        OPEN(UNIT=4, FILE='raw_dedisp_I_sub-int_folded.plot')
        j_loop_count=int(n_samples/loop_size)
        print*, 'number of sub-integrations for plotting purpose=', j_loop_count
        ALLOCATE(N_parts_array(j_loop_count, n_bins))
        DO j=1,j_loop_count
                ALLOCATE(subint_array(n_chan, n_bins))
                DO i=1, n_chan
                        DO k4=1, n_bins
                                subint_array(i,k4)=0.0
                        ENDDO
                ENDDO 
                print*, 'data processing ',j, '/', j_loop_count
                READ(1) read_array
                DO i=1, loop_size
                        k2=int(i/n_chan)+1
                        k1=MODULO(i, n_chan)
                        if (k1==0) then
                                k1=n_chan
                                k2=int(i/n_chan)
                        endif
                        k2=(k2+(j-1)*(loop_size/n_chan))*t_sample ! K2 is time
                        N_t=const1*k2+const2*k2**2+const3*k2**3
                        k3a1=(N_t-int(N_t))*n_bins
                        k3a2=k3a1-int(k3a1)
                        k3a3=1.0-k3a2
                        k3a4=int(k3a1)
                        k3a5=k3a4+1
                        if (k3a4==0) then
                                k3a4=n_bins
                        endif
       !                 print*, k3a1, k3a2, k3a3, k3a4, k3a5
                        !print*, (N_t-int(N_t))*n_bins, k3, n_bins
                        !k3=int((k2*t_sample/P-int(k2*t_sample/P))*n_bins)+1
                        write_array(k1,k3a4)=write_array(k1,k3a4)+k3a3*read_array(i)
                        write_array(k1,k3a5)=write_array(k1,k3a5)+k3a2*read_array(i)
                        subint_array(k1,k3a4)=subint_array(k1,k3a4)+k3a3*read_array(i)
                        subint_array(k1,k3a5)=subint_array(k1,k3a5)+k3a2*read_array(i)         
                ENDDO
                DO k4=1,n_bins
                        DO i=1, n_chan
                                N_parts_array(j, k4)=N_parts_array(j, k4)+subint_array(i, k4)
                        ENDDO
                ENDDO
                DEALLOCATE(subint_array)
        ENDDO
        DEALLOCATE(read_array)
        CLOSE(1)
        DO j=1, n_bins
                DO i=1, n_chan
                        folded_profile(j)=folded_profile(j)+write_array(i,j)
                ENDDO
        ENDDO
        DO j=1, n_bins
                WRITE(2,*) write_array(:, j)
                WRITE(3,*) folded_profile(j)
                WRITE(4,*) N_parts_array(:,j)
        ENDDO
        CLOSE(2)
        CLOSE(3)
        CLOSE(4)
        DEALLOCATE(write_array, folded_profile, N_parts_array)
 
END PROGRAM Folding_time_series
