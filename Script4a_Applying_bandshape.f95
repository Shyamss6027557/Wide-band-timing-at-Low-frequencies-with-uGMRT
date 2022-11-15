PROGRAM Applying_bandshape
        use iso_fortran_env
        IMPLICIT NONE
        INTEGER::i,j,j_loop_count,k1,n_chan=512
        INTEGER(kind=int64)::size_in_bytes=141943901184.0, loop_size=459365376.0
        INTEGER*1,ALLOCATABLE,DIMENSION(:)::read_array1
        REAL(kind=4),ALLOCATABLE,DIMENSION(:)::write_array1
        REAL(kind=8),ALLOCATABLE,DIMENSION(:)::bandshape_array_RR_2
        print*, 'loop_size should be multiple of n_chan'
        ALLOCATE(read_array1(loop_size))
        ALLOCATE(write_array1(loop_size))
        ALLOCATE(bandshape_array_RR_2(n_chan))
        
        OPEN(UNIT=1,FILE='Bandshape_HR_1516-43_gsb_ia.dedisp',ACCESS='STREAM',action='read')
        READ(1) bandshape_array_RR_2 
        Close(1)

        OPEN(UNIT=3, FILE='HR_1516-43_gsb_ia.dedisp',ACCESS='STREAM')
        OPEN(UNIT=5, FILE='HR_1516-43_gsb_ia.dedisp_bandshape_corrected',ACCESS='STREAM')

        j_loop_count=size_in_bytes/loop_size
        print*, j_loop_count, size_in_bytes, loop_size
        DO j=1,j_loop_count
                print*, 'data processing ',j, '/', j_loop_count
                READ(3) read_array1
                DO i=1, loop_size
                        k1=MODULO(i,n_chan)
                        if (k1==0) then
                                k1=n_chan
                        endif
                        write_array1(i)=read_array1(i)/(bandshape_array_RR_2(k1)+1.0)
                ENDDO
                WRITE(5) write_array1
        ENDDO
        CLOSE(3)
        CLOSE(5)

        DEALLOCATE(read_array1, write_array1, bandshape_array_RR_2)

END PROGRAM Applying_bandshape
