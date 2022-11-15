PROGRAM Channel_averaging
        use iso_fortran_env
        IMPLICIT NONE
        INTEGER::i,j,j_loop_count,k,k1,sample_size_in_bytes=4,chan_avg_factor=512 ! !Channels=4096
        INTEGER(kind=int64)::size_in_bytes=565938143232.0,n_samples,loop_size=459365376.0,write_array_size
        REAL(kind=4),ALLOCATABLE,DIMENSION(:)::read_array
        REAL(kind=4),ALLOCATABLE,DIMENSION(:)::write_array
        print*, 'note that number of samples = size_in_bytes/sample_size_in_bytes here, consider this while entering loop_size'
        print*, 'loop_size and chan_avg_factor should be multiple of n_chan'
        n_samples=size_in_bytes/sample_size_in_bytes
        write_array_size=loop_size/chan_avg_factor
        
        ALLOCATE(read_array(loop_size), write_array(write_array_size))
        OPEN(UNIT=1, FILE='HR_1516-43_gsb_ia.dedisp_bandshape_corrected',ACCESS='STREAM')
        OPEN(UNIT=2, FILE='HR_1516-43_gsb_ia.dedisp_bandshape_corrected_FT',ACCESS='STREAM')

        j_loop_count=n_samples/loop_size
        DO j=1,j_loop_count
                print*, 'data processing ',j, '/', j_loop_count
                READ(1) read_array
                DO i=1, write_array_size
                        write_array(i)=0
                        DO k=1, chan_avg_factor
                                k1=(i-1)*chan_avg_factor+k
                                write_array(i)=write_array(i)+read_array(k1)
                        ENDDO
                ENDDO
                WRITE(2) write_array
        ENDDO
        CLOSE(1)
        CLOSE(2)
        DEALLOCATE(read_array, write_array)
 
END PROGRAM Channel_averaging
