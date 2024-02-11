.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    # Prologue 0
	addi sp, sp, -40
    sw ra, 0(sp)
    sw s0, 4(sp)            # s0: argc
    sw s1, 8(sp)            # s1: argv
    sw s2, 12(sp)           # s2: print_classification
    sw s3, 16(sp)           # s3: M0_PATH
    sw s4, 20(sp)           # s4: M1_PATH
    sw s5, 24(sp)           # s5: INPUT_PATH
    sw s6, 28(sp)           # s6: OUTPUT_PATH

    mv s0, a0
    mv s1, a1
    mv s2, a2
    lw s3, 4(s1)            # Load M0_PATH.
    lw s4, 8(s1)            # Load M1_PATH.
    lw s5, 12(s1)           # Load INPUT_PATH.
    lw s6, 16(s1)           # Load OUTPUT_PATH.

	# =====================================
    # LOAD MATRICES
    # =====================================

    # Prologue for 6 temporaries.
    addi sp, sp, -24

    # New 2 ptrs for # of rows and cols.
    addi a0, zero, 2

    # Load pretrained m0
    mv a0, s3               # Set a0: M0_PATH
    mv a1, zero             # Set a1: NULL ptr to integer (rows).
    mv a2, zero             # Set a2: NULL ptr to integer (cols).
    jal read_matrix         # Call function "read_matrix".
    sw a0, 0(sp)            # Save M0_Matrix.
    sw a1, 4(sp)            # Save M0_Rows.

    # Load pretrained m1
    mv a0, s4               # Set a0: M1_PATH
    mv a1, zero             # Set a1: NULL ptr to integer (rows).
    mv a2, zero             # Set a2: NULL ptr to integer (cols).
    jal read_matrix         # Call function "read_matrix".
    sw a0, 8(sp)            # Save M1_Matrix.
    sw a1, 12(sp)           # Save M1_Rows_Cols

    # Load input matrix
    mv a0, s5               # Set a0: INPUT_PATH
    mv a1, zero             # Set a1: NULL ptr to integer (rows).
    mv a2, zero             # Set a2: NULL ptr to integer (cols).
    jal read_matrix         # Call function "read_matrix".
    sw a0, 16(sp)           # Save Input_Matrix.
    sw a1, 20(sp)           # Save Input_Rows_Cols

    # Epilogue for 6 temporaries.
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    lw t3, 12(sp)
    lw t4, 16(sp)
    lw t5, 20(sp)
    addi sp, sp, 24

    # Prologue 1
	addi sp, sp, -40
    sw s0, 0(sp)            # s0: M0_Matrix
    sw s1, 4(sp)            # s1: M1_Matrix
    sw s2, 8(sp)            # s2: Input_Matrix
    sw s3, 12(sp)           # s3: Score
    sw s7, 28(sp)           # s7: OUTPUT_PATH

    mv s7, s6
    mv s0, t0
    mv s4, t1
    mv s1, t2
    mv s5, t3
    mv s2, t4
    mv s6, t5

    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    # m0 * input
    mv a0, s0               # Set a0: ptr to the start of m0.
    lw a1, 0(s4)            # Set a1: # of rows (height) of m0.
    lw a2, 4(s4)            # Set a2: # of cols (width) of m0.
    mv a3, s2               # Set a3: ptr to the start of input.
    lw a4, 0(s6)            # Set a4: # of rows (height) of input.
    lw a5, 4(s6)            # Set a5: # of cols (width) of input.

    mul s8, a1, a5          # Count total items matrix d.
    jal call_malloc         # Call function "call_malloc".
    mv s9, a0               # Save ptr to the memory allocated.
    mv a6, s9               # Set a6: ptr to the start of d.
    jal matmul              # Call function "matmul".

    # ReLU(m0 * input)
    mv a0, s9               # Set a0: ptr to the array.
    mv a1, s8               # Set a1: # of elements in the array.
    jal relu                # Call function "relu".

    # m1 * ReLU(m0 * input)
    mv a0, s0               # Set a0: ptr to the start of m1.
    lw a1, 0(s4)            # Set a1: # of rows (height) of m1.
    lw a2, 4(s4)            # Set a2: # of cols (width) of m1.
    mv a3, s9               # Set a3: ptr to the start of d.
    lw a4, 0(s4)            # Set a4: # of rows (height) of d.
    lw a5, 4(s6)            # Set a5: # of cols (width) of d.

    mul s8, a1, a5          # Count total items matrix score.
    jal call_malloc         # Call function "call_malloc".
    mv s3, a0               # Allocate memory for score.
    mv a6, s3               # Set a6: ptr to the start of score.
    jal matmul              # Call function "matmul".

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    mv a0, s7               # Set a0: ptr to filename string.
    mv a1, s3               # Set a1: ptr to the start of score.
    lw a2, 0(s4)            # Set a2: # of rows (height) of m1.
    lw a3, 4(s6)            # Set a3: # of cols (width) of input.
    jal write_matrix        # Call function "write_matrix".

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    mv a0, s3               # Set a0: ptr to the start of score.
    lw t0, 0(s4)            # t0: rows of score.
    lw t1, 0(s6)            # t1: cols of score.
    mul a2, t0, t1          # Set a1: # of elements in score.
    jal argmax              # Call function "argmax".

    # Print classification
    mv a1, a0               # Set a1: integer to print.
    jal print_int

    # Print newline afterwards for clarity
    addi a1, zero, 10       # Set a1: char to print('\n', 10).

    # Free mallocs.
    mv a0, s0
    jal free
    mv a0, s1
    jal free
    mv a0, s2
    jal free
    mv a0, s3
    jal free
    mv a0, s4
    jal free
    mv a0, s5
    jal free
    mv a0, s6
    jal free
    mv a0, s7
    jal free
    mv a0, s8
    jal free
    mv a0, s9
    jal free

    # Epilogue 1
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw s9, 36(sp)
	addi sp, sp, 40

    # Epilogue 0
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

# a0: # of items need {malloc}.
call_malloc:
    addi sp, sp, -4
    sw ra, 0(sp)
    slli a0, a0, 2          # Set a0: # of bytes need to read.
    jal malloc              # Call function "malloc".
    beq a0, zero, error_88  # Check if malloc fails.
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# Exceptions:
error_88:
    li a1, 88
    jal exit2
