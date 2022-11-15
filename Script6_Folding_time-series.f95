PROGRAM Folding_time_series
        use iso_fortran_env
        IMPLICIT NONE
        INTEGER::i,j,j_loop_count,k1,k2,k3,sample_size_in_bytes=4,n_chan=128,n_bins
        INTEGER(kind=int64)::size_in_bytes=2785017856.0,n_samples,loop_size=4686976.0 ! 36617.0*128=4686976.0
        REAL(kind=4),ALLOCATABLE,DIMENSION(:)::read_array, folded_profile
        REAL(kind=4),ALLOCATABLE,DIMENSION(:,:)::write_array
        REAL(kind=8)::Period=1.3108135311651, t_sample=0.00032768 ! Period and t_sample in seconds
        print*, 'note that number of samples = size_in_bytes/sample_size_in_bytes here, consider this while entering loop_size'
        print*, 'loop_size should be multiple of n_chan'
        n_samples=size_in_bytes/sample_size_in_bytes
        n_bins=64!int(Period/t_sample)
        print*, 'bins', n_bins 
        ALLOCATE(read_array(loop_size), folded_profile(n_bins))
        ALLOCATE(write_array(n_chan, n_bins))
        OPEN(UNIT=1, FILE='raw_dedisp_I_128chan',ACCESS='STREAM')
        OPEN(UNIT=2, FILE='raw_dedisp_I_128chan_folded.txt')
        OPEN(UNIT=3, FILE='raw_dedisp_I_FT_folded.txt')
        j_loop_count=n_samples/loop_size
        DO j=1,j_loop_count
                print*, 'data processing ',j, '/', j_loop_count
                READ(1) read_array
                DO i=1, loop_size
                        k1=MODULO(i, n_chan)
                        if (k1==0) then
                                k1=n_chan
                        endif
                        k2=int(i/n_chan)+1
                        k2=k2+(j-1)*(loop_size/n_chan)
                        k3=int((k2*t_sample/Period-int(k2*t_sample/Period))*n_bins)+1
                        write_array(k1,k3)=write_array(k1,k3)+read_array(i)                        
                ENDDO
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
        ENDDO
        CLOSE(2)
        CLOSE(3)
        DEALLOCATE(write_array, folded_profile)
 
END PROGRAM Folding_time_series
