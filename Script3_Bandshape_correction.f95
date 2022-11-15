PROGRAM bandpass_correction
        use iso_fortran_env
        IMPLICIT NONE
        INTEGER::i,j,j_loop_count,k1,n_chan=512
        INTEGER(kind=int64)::size_in_bytes=1677721600.0,loop_size=16777216.0
        REAL(kind=real64)::k2=0.0
        INTEGER*1,ALLOCATABLE,DIMENSION(:)::read_array
        REAL*8,ALLOCATABLE,DIMENSION(:)::bandshape_array
        print*, 'loop_size should be multiple of n_chan'
        ALLOCATE(read_array(loop_size),bandshape_array(n_chan))
        
        OPEN(UNIT=1,FILE='HR_1516-43_gsb_ia.dedisp',action='read',FORM='UNFORMATTED',ACCESS='STREAM')
        OPEN(UNIT=2,FILE='Bandshape_HR_1516-43_gsb_ia.dedisp.txt')
        OPEN(UNIT=3, FILE='Bandshape_HR_1516-43_gsb_ia.dedisp',FORM='UNFORMATTED',ACCESS='STREAM', action='write')

        j_loop_count=size_in_bytes/loop_size
        DO j=1,j_loop_count
                print*, 'data processing', j, '/', j_loop_count
                READ(1) read_array
                DO i=1, loop_size
                        k1=MODULO(i,n_chan)
                        if (k1==0) then
                                k1=n_chan
                        endif
                        bandshape_array(k1)=bandshape_array(k1)+read_array(i)
                        k2=k2+1
                ENDDO
        ENDDO
        CLOSE(1)
        k2=k2/n_chan
        DEALLOCATE(read_array)
        DO j=1, n_chan
                bandshape_array(j)=bandshape_array(j)/k2
                WRITE(2,*) bandshape_array(j)
        ENDDO
        CLOSE(2)
        WRITE(3) bandshape_array
        CLOSE(3)        
        DEALLOCATE(bandshape_array) 
 
END PROGRAM bandpass_correction
