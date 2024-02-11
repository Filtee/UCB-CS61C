.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 93.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 94.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 95.
# ==============================================================================
write_matrix:

    # Prologue
	addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)                # s0: ptr to string representing filename
    sw s1, 8(sp)                # s1: ptr to the start of the matrix in memory
    sw s2, 12(sp)               # s2: # of rows in matrix
    sw s3, 16(sp)               # s3: # of cols in matrix
    sw s4, 20(sp)               # s4: file descriptor
    sw s5, 24(sp)               # s5: # of items need to read. 
    sw s6, 28(sp)               # s6: ptr to the buffer.

    # Save all the arguments.
    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3

    # Open file.
    mv a1, s0                   # Load filename ptr into a1.
    addi a2, zero, 1            # Set permission as "w".
    jal fopen                   # Call function "fopen".
    addi t0, zero, -1           # t0 = -1
    beq a0, t0, error_93        # Check if opening fails.
    mv s4, a0                   # Save file descriptor

    # Write into the file.
    mul s5, s2, s3              # Count # of items need to read. 
    addi s5, s5, 2              # Add two int: (row, col).
    jal call_malloc             # Call function "call_malloc".
    sw s2, 0(s6)                # Save int "rows".
    sw s2, 4(s6)                # Save int "cols".
    addi a0, s6, 8              # Count start address of matrix in buffer.
    jal save_matrix             # Save all the items of matrix.
    jal call_fwrite             # Call function "call_fwrite".

    # Close file.
    mv a1, s4                   # Set a1: file descriptor
    jal fclose                  # Call function "fclose"
    bne a0, zero, error_95      # Check if file closing fails.

    # Free space allocated to buffer.
    mv a0, s6
    jal free

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
	addi sp, sp, 32

    ret

# a0: start address in buffer
save_matrix:
    mv t0, zero                 # t0: counter (i)
    mul t1, s2, s3              # t1: # of items in matrix
    loop_start:
        beq t0, t1, loop_end    # Check if loop comes to end.
        slli t2, t0, 2          # Count offset bytes.
        add t3, s1, t2          # Get address of item in matrix.
        add t4, a0, t2          # Get address of item in buffer.
        lw t5, 0(t3)            # Load item from matrix.
        sw t5, 0(t4)            # Save item into buffer.                
        addi t0, t0, 1          # i++
        j loop_start
    loop_end:
    ret

call_malloc:
    slli a0, s5, 2              # Set a0: # of bytes need to read.
    addi sp, sp, -4
    sw ra, 0(sp)
    jal malloc                  # Call function "malloc".
    lw ra, 0(sp)
    addi sp, sp, 4
    beq a0, zero, error_88      # Check if malloc fails.
    mv s6, a0                   # Save ptr to the allocated memory
    ret

call_fwrite:
    mv a1, s4                   # Set a1: file descriptor
    mv a2, s6                   # Set a2: ptr to the buffer to read
    mv a3, s5                   # Set a3: # of items to read
    addi a4, zero, 4            # Set a4: size of each item in buffer
    addi sp, sp, -4
    sw ra, 0(sp)
    jal fwrite                  # Call function "fwrite".
    lw ra, 0(sp)
    addi sp, sp, 4
    bne a0, s5, error_94        # Check if write fails.
    ret

# Exceptions:
error_88:
    li a1, 88
    jal exit2

error_93:
    li a1, 93
    jal exit2

error_94:
    li a1, 94
    jal exit2

error_95:
    li a1, 95
    jal exit2
