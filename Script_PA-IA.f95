PROGRAM PA_minus_IA_beam
        use iso_fortran_env
        IMPLICIT NONE
        INTEGER::i,j,j_loop_count
        INTEGER(kind=int64)::size_in_bytes=141943901184.0, loop_size=459365376.0
        INTEGER*1,ALLOCATABLE,DIMENSION(:)::read_array1, read_array2
        INTEGER(kind=1),ALLOCATABLE,DIMENSION(:)::write_array
        ALLOCATE(read_array1(loop_size), read_array2(loop_size))
        ALLOCATE(write_array(loop_size))
        
        OPEN(UNIT=1,FILE='PA',ACCESS='STREAM',action='read')
        OPEN(UNIT=2, FILE='IA',ACCESS='STREAM', action='read')
        OPEN(UNIT=3, FILE='PA-IA',ACCESS='STREAM')

        j_loop_count=size_in_bytes/loop_size
        print*, j_loop_count, size_in_bytes, loop_size
        DO j=1,j_loop_count
                print*, 'data processing ',j, '/', j_loop_count
                READ(1) read_array1
                READ(2) read_array2
                DO i=1, loop_size
                        write_array(i)=read_array1(i)-read_array2(i)
                ENDDO
                WRITE(3) write_array
        ENDDO
        CLOSE(1)
        CLOSE(2)
        CLOSE(3)

        DEALLOCATE(read_array1, read_array2, write_array)
END PROGRAM PA_minus_IA_beam
