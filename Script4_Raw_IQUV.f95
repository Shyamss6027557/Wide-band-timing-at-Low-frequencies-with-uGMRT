PROGRAM raw_stokes_IQUV
        use iso_fortran_env
        IMPLICIT NONE
        INTEGER::i,j,j_loop_count,k1,n_chan=4096
        INTEGER(kind=int64)::size_in_bytes=22496944128.0,loop_size=268435456.0
        INTEGER*1,ALLOCATABLE,DIMENSION(:)::read_array1, read_array2
        REAL(kind=4),ALLOCATABLE,DIMENSION(:)::write_array1, write_array2
        REAL(kind=8),ALLOCATABLE,DIMENSION(:)::bandshape_array_RR_2,bandshape_array_LL_2
        print*, 'loop_size should be multiple of n_chan'
        ALLOCATE(read_array1(loop_size),read_array2(loop_size))
        ALLOCATE(write_array1(loop_size),write_array2(loop_size))
        ALLOCATE(bandshape_array_RR_2(n_chan),bandshape_array_LL_2(n_chan))
        
        OPEN(UNIT=1,FILE='Bandshape_RR_2',ACCESS='STREAM',action='read')
        OPEN(UNIT=2,FILE='Bandshape_LL_2',ACCESS='STREAM',action='read')
        READ(1) bandshape_array_RR_2 
        READ(2) bandshape_array_LL_2
        Close(1)
        Close(2)

        OPEN(UNIT=3, FILE='RR_2',ACCESS='STREAM')
        OPEN(UNIT=4, FILE='LL_2',ACCESS='STREAM')
        OPEN(UNIT=5, FILE='raw_dedisp_I',ACCESS='STREAM')
        OPEN(UNIT=11, FILE='raw_dedisp_V',ACCESS='STREAM')

        j_loop_count=size_in_bytes/loop_size
        DO j=1,j_loop_count
                print*, 'data processing 1/2 ',j, '/', j_loop_count
                READ(3) read_array1
                READ(4) read_array2
                DO i=1, loop_size
                        k1=MODULO(i,n_chan)
                        if (k1==0) then
                                k1=n_chan
                        endif
                        write_array1(i)=read_array1(i)/(bandshape_array_RR_2(k1)+1.0)+read_array2(i)/(bandshape_array_LL_2(k1)+1.0)
                        write_array2(i)=read_array1(i)/(bandshape_array_RR_2(k1)+1.0)-read_array2(i)/(bandshape_array_LL_2(k1)+1.0)
                ENDDO
                WRITE(5) write_array1
                WRITE(11) write_array2
        ENDDO
        CLOSE(3)
        CLOSE(4)
        CLOSE(5)
        CLOSE(11)

        OPEN(UNIT=7,FILE='Re_RL_2', ACCESS='STREAM')
        OPEN(UNIT=8,FILE='Im_RL_2', ACCESS='STREAM')
        OPEN(UNIT=9,FILE='raw_dedisp_Q', ACCESS='STREAM')
        OPEN(UNIT=10,FILE='raw_dedisp_U', ACCESS='STREAM')
        DO j=1,j_loop_count
                print*, 'data processing 2/2 ',j, '/', j_loop_count
                READ(7) read_array1
                READ(8) read_array2
                DO i=1, loop_size
                        k1=MODULO(i,n_chan)
                        if (k1==0) then
                                k1=n_chan
                        endif
                        write_array1(i)=2*read_array1(i)/(sqrt(bandshape_array_RR_2(k1)*bandshape_array_LL_2(k1))+1.0)
                        write_array2(i)=2*read_array2(i)/(sqrt(bandshape_array_RR_2(k1)*bandshape_array_LL_2(k1))+1.0)
                ENDDO
                WRITE(9) write_array1
                WRITE(10) write_array2
        ENDDO
        CLOSE(7)
        CLOSE(8)
        CLOSE(9)
        CLOSE(10)
        DEALLOCATE(read_array1, read_array2, write_array1, write_array2,bandshape_array_RR_2, bandshape_array_LL_2)

 
 
END PROGRAM raw_stokes_IQUV
