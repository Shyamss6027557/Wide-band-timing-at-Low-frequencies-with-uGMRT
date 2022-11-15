PROGRAM Dedispersion_code
        use iso_fortran_env
        IMPLICIT NONE
        INTEGER*1, ALLOCATABLE, DIMENSION(:) ::write_block
        REAL(kind=real64), ALLOCATABLE, DIMENSION(:) :: chan_freq
        INTEGER*1, ALLOCATABLE, DIMENSION(:)::read_block, store_block,read_block_2
        INTEGER, ALLOCATABLE, DIMENSION(:) :: sample_cut_chan
        INTEGER::i,j,j_loop_count,k1,k2,n_chan=512
        INTEGER(kind=int64)::file_size=141968801792.0,block_size,store_size,new_block_size,loop_sample_count=541568.0
        REAL(kind=real64)::bandwidth=200.0,start_freq=549.804687500,t_sample,DM=78.5812
        t_sample=10.24*(10.0**(-6.0)) ! in seconds
        print*, 'loop_sample_count should be greater than 2*sample_chan_cut(1) at least'
        print*, ' put the loop_sample_count such that file_size/(nchan*loop_sample_count) is very close to an integer value'
        print*, 'this code reads samples in 8bits and write dedispersed freq-time series in 8bits'
        print*, 'no. of bits for input and output files can be changed by'
        print*,  'changing the *1/*4 factors in the first few lines of code'
        ALLOCATE(sample_cut_chan(n_chan))
        ALLOCATE(chan_freq(n_chan))
        DO k1=n_chan,1,-1
                chan_freq(k1)=start_freq+(k1-1)*bandwidth/real(n_chan)
                sample_cut_chan(k1)=nint(4148.8*DM*((1.0/chan_freq(k1))**2-(1.0/chan_freq(n_chan))**2)/t_sample)
                print*, k1, chan_freq(k1), bandwidth/real(n_chan)
        ENDDO
        print*, 'sample_cut_chan', sample_cut_chan(1)
        block_size=n_chan*loop_sample_count
        store_size=n_chan*sample_cut_chan(1)
        new_block_size=block_size-store_size
        ALLOCATE(store_block(store_size),read_block_2(block_size+store_size),read_block(block_size))
        ALLOCATE(write_block(new_block_size))
        OPEN(1,FILE='J1242-4712_550_200_512_2.02aug2k22.raw0.dat', ACCESS='STREAM')
        OPEN(2,FILE='HR_1516-43_gsb_ia.dedisp',ACCESS='STREAM')
        j_loop_count=file_size/block_size
        DO j=1, j_loop_count
                print*, 'loop number', j, '/', j_loop_count
                if (j>2) then
                        ALLOCATE(read_block(block_size))
                endif
                Read(1) read_block
                if (j>1) then
                        if (j==2) then
                                deallocate (write_block)
                                new_block_size=block_size
                                ALLOCATE(write_block(new_block_size))
                        endif
                        read_block_2=[store_block, read_block]
                        deallocate (read_block)
                endif
                DO i=1,new_block_size
                        k1=MODULO(i,n_chan)
                        if (k1==0) then
                                k1=n_chan
                        endif
                        k2=i+n_chan*sample_cut_chan(k1)
                        if (j==1) then
                                write_block(i)=read_block(k2)
                        else
                                write_block(i)=read_block_2(k2)
                        endif
                        if (i<=store_size) then
                                if (j==1) then
                                        store_block(i)=read_block(i+new_block_size)
                                else
                                        store_block(i)=read_block_2(i+new_block_size)
                                endif
                        endif
                ENDDO
                WRITE(2) write_block
        ENDDO
        deallocate(sample_cut_chan,chan_freq,read_block_2,store_block, write_block)
        Close(1)
        Close(2)        
END PROGRAM Dedispersion_code
