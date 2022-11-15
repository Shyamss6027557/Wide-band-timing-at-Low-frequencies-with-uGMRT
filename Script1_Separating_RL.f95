PROGRAM Separating_IQUV
        use iso_fortran_env
        IMPLICIT NONE
        INTEGER::i,j,j_loop_count,k1,k2,k3,k4,loop_sub_count
        INTEGER(kind=int64)::size_in_bytes=89992986624.0,loop_count=1406140416.0
        INTEGER*1,ALLOCATABLE,DIMENSION(:)::read_array,write_array1,write_array2,write_array3,write_array4
        loop_sub_count=loop_count/4
        ALLOCATE(read_array(loop_count), write_array1(loop_sub_count))
        ALLOCATE(write_array2(loop_sub_count), write_array3(loop_sub_count), write_array4(loop_sub_count))
        ! To Read 8 bit Binary Files

        print*, 'loop_count should be multiple of number of channels and 4'
        OPEN(UNIT=1,FILE='J1115-0956_pa_550_200_4096_16_1_8_1_04feb2022.raw',action='read',FORM='UNFORMATTED',ACCESS='STREAM')
        OPEN(UNIT=2,FILE='RR_1'    , FORM='UNFORMATTED',ACCESS='STREAM',action='write', position='append')
        OPEN(UNIT=3,FILE='Im_RL_1' , FORM='UNFORMATTED',ACCESS='STREAM',action='write', position='append')
        OPEN(UNIT=4,FILE='LL_1'    , FORM='UNFORMATTED',ACCESS='STREAM',action='write', position='append')
        OPEN(UNIT=5,FILE='Re_RL_1' , FORM='UNFORMATTED',ACCESS='STREAM',action='write', position='append')
        j_loop_count=size_in_bytes/loop_count
        DO j=1,j_loop_count
                print*, 'loop_count', j, '/',j_loop_count
                READ(1) read_array
                k1=1
                k2=1
                k3=1
                k4=1
                DO i=1, loop_count
                        if (MODULO(i,4)==1) then
                                write_array1(k1)=read_array(i)
                                k1=k1+1
                        elseif (MODULO(i,4)==2) then
                                write_array2(k2)=read_array(i)
                                k2=k2+1
                        elseif (MODULO(i,4)==3) then
                                write_array3(k3)=read_array(i)
                                k3=k3+1
                        elseif (MODULO(i,4)==0) then
                                write_array4(k4)=read_array(i)
                                k4=k4+1
                        endif
                ENDDO
                WRITE(2) write_array1
                WRITE(3) write_array2
                WRITE(4) write_array3
                WRITE(5) write_array4
        ENDDO
        DEALLOCATE(read_array, write_array1, write_array2, write_array3, write_array4)
        CLOSE(1)
        CLOSE(2)
        CLOSE(3)
        CLOSE(4)
        CLOSE(5)

END PROGRAM Separating_IQUV
