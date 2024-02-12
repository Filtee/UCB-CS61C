.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)            # s0: pointer to filename string
    sw s1, 8(sp)            # s1: pointer to number of rows
    sw s2, 12(sp)           # s2: pointer to number of columns
    sw s3, 16(sp)           # s3: file descriptor
    sw s4, 20(sp)           # s4: ptr to the memory allocated.
    sw s5, 24(sp)           # s5: # of items need to read.

    # Save all the arguments.
    mv s0, a0
    mv s1, a1
    mv s2, a2

    # Open file.
    mv a1, s0               # Load filename ptr into a1.
    mv a2, zero             # Set permission as "r".
    jal fopen               # Call function "fopen".
    addi t0, zero, -1       # t0 = -1
    beq a0, t0, error_90    # Check if opening fails.
    mv s3, a0               # Save file descriptor.

    # Read (rows, cols) from file.
    addi s5, zero, 2        # Save # of items need to read. 
    jal call_malloc         # Call function "call_malloc".
    jal call_fread          # Call function "call_fread".
    lw t0, 0(s4)            # Load rows from buffer.
    sw t0, 0(s1)            # Set ptr to # of rows.
    lw t1, 4(s4)            # Load cols from buffer.
    sw t1, 0(s2)            # Set ptr to # of cols.
    mv a0, s4               # Set a0: ptr to heap memory to free.
    jal free                # Free malloced buffer.

    # Read matrix from file.
    lw t0, 0(s1)            # Load rows from ptr.
    lw t1, 0(s2)            # Load cols from ptr.
    mul s5, t0, t1          # Save # of items need to read. 
    jal call_malloc         # Call function "call_malloc".
    jal call_fread          # Call function "call_fread".

    # Close file.
    mv a1, s3               # Set a1: file descriptor
    jal fclose              # Call function "fclose"
    bne a0, zero, error_92  # Check if file closing fails.

    # Set return values.
    mv a0, s4               # Set a0: ptr to the matrix in memory.
    mv a1, s1               # Set a1
    mv a2, s2               # Set a2

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28

    ret

call_malloc:
    slli a0, s5, 2          # Set a0: # of bytes need to read.
    addi sp, sp, -4
    sw ra, 0(sp)
    jal malloc              # Call function "malloc".
    lw ra, 0(sp)
    addi sp, sp, 4
    beq a0, zero, error_88  # Check if malloc fails.
    mv s4, a0               # s4: ptr to the allocated memory
    ret

call_fread:
    mv a1, s3               # Set a1: file descriptor.
    mv a2, s4               # Set a2: ptr to the buffer.
    slli a3, s5, 2          # Set a3: # of bytes to be read.
    addi sp, sp, -4
    sw ra, 0(sp)
    jal fread               # Call function "fread".
    lw ra, 0(sp)
    addi sp, sp, 4
    slli t0, s5, 2          # Set a3: # of bytes to be read.
    bne a0, t0, error_91    # Check if file reading fails.
    ret

# Exceptions:
error_88:
    li a1, 88
    jal exit2

error_90:
    li a1, 90
    jal exit2

error_91:
    li a1, 91
    jal exit2

error_92:
    li a1, 92
    jal exit2
