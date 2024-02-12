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

    # Check if there are an incorrect # of command line args.
    addi t0, zero, 5
    bne a0, t0, error_89

    # Prologue
	addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)            # s0: argv
    sw s1, 8(sp)            # s1: print_classification
    sw s2, 12(sp)           # s2: M0 attributes
    sw s3, 16(sp)           # s3: M1 attributes
    sw s4, 20(sp)           # s4: input matrix attributes
    sw s5, 24(sp)           # s5: D1 attributes
    sw s6, 28(sp)           # s6: D2 attributes

    mv s0, a1
    mv s1, a2

    # Malloc space for each ptr. (M0, M1, I_M, D1, D2)
    addi a0, zero, 3        # Set a0: 3 items.
    jal call_malloc         # Call function "call_malloc"
    mv s2, a0               # Save the ptr at s2.
    addi a0, zero, 3        # Set a0: 3 items.
    jal call_malloc         # Call function "call_malloc"
    mv s3, a0               # Save the ptr at s3.
    addi a0, zero, 3        # Set a0: 3 items.
    jal call_malloc         # Call function "call_malloc"
    mv s4, a0               # Save the ptr at s4.
    addi a0, zero, 3        # Set a0: 3 items.
    jal call_malloc         # Call function "call_malloc"
    mv s5, a0               # Save the ptr at s5.
    addi a0, zero, 3        # Set a0: 3 items.
    jal call_malloc         # Call function "call_malloc"
    mv s6, a0               # Save the ptr at s6.

	# =====================================
    # LOAD MATRICES
    # =====================================

    lw a0, 4(s0)            # Set a0: M0_PATH
    addi a1, s2, 0          # Set a1: ptr to integer (rows).
    addi a2, s2, 4          # Set a2: ptr to integer (cols).
    jal read_matrix         # Call function "read_matrix".
    sw a0, 8(s2)            # Save M0_Matrix.

    lw a0, 8(s0)            # Set a0: M1_PATH
    addi a1, s3, 0          # Set a1: ptr to integer (rows).
    addi a2, s3, 4          # Set a2: ptr to integer (cols).
    jal read_matrix         # Call function "read_matrix".
    sw a0, 8(s3)            # Save M1_Matrix.

    lw a0, 12(s0)           # Set a0: INPUT_PATH
    addi a1, s4, 0          # Set a1: ptr to integer (rows).
    addi a2, s4, 4          # Set a2: ptr to integer (cols).
    jal read_matrix         # Call function "read_matrix".
    sw a0, 8(s4)            # Save Input_Matrix.

    # Malloc for matrix d1
    lw t0, 0(s2)            # t0: rows of m0
    lw t1, 4(s4)            # t1: cols of input matrix
    sw t0, 0(s5)            # Save rows of d1.
    sw t1, 4(s5)            # Save cols of d1.
    mul a0, t0, t1          # Set a0: # of items.
    jal call_malloc         # Call function "call_malloc".
    sw a0, 8(s5)            # Save d1.

    # Malloc for matrix d2
    lw t0, 0(s3)            # t0: rows of m1
    lw t1, 4(s4)            # t1: cols of input matrix
    sw t0, 0(s6)            # Save rows of d2.
    sw t1, 4(s6)            # Save cols of d2.
    mul a0, t0, t1          # Set a0: # of items.
    jal call_malloc         # Call function "call_malloc".
    sw a0, 8(s6)            # Save d2.

    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    # m0 * input
    lw a0, 8(s2)            # Set a0: ptr to the start of m0.
    lw a1, 0(s2)            # Set a1: # of rows (height) of m0.
    lw a2, 4(s2)            # Set a2: # of cols (width) of m0.
    lw a3, 8(s4)            # Set a3: ptr to the start of input.
    lw a4, 0(s4)            # Set a4: # of rows (height) of input.
    lw a5, 4(s4)            # Set a5: # of cols (width) of input.
    lw a6, 8(s5)            # Set a6: ptr to the start of D1.
    jal matmul              # Call function "matmul".

    # ReLU(m0 * input)
    lw a0, 8(s5)            # Set a0: ptr to the array.
    lw t0, 0(s5)            # t0: rows of d1
    lw t1, 4(s5)            # t1: cols of d1
    mul a1, t0, t1          # Set a1: # of elements in the array.
    jal relu                # Call function "relu".

    # m1 * ReLU(m0 * input)
    lw a0, 8(s3)            # Set a0: ptr to the start of m1.
    lw a1, 0(s3)            # Set a1: # of rows (height) of m1.
    lw a2, 4(s3)            # Set a2: # of cols (width) of m1.
    lw a3, 8(s5)            # Set a3: ptr to the start of d1.
    lw a4, 0(s5)            # Set a4: # of rows (height) of d1.
    lw a5, 4(s5)            # Set a5: # of cols (width) of d1.
    lw a6, 8(s6)            # Set a6: ptr to the start of d2.
    jal matmul              # Call function "matmul".

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    lw a0, 16(s0)           # Set a0: ptr to filename string.
    lw a1, 8(s6)            # Set a1: ptr to the start of score.
    lw a2, 0(s6)            # Set a2: # of rows (height) of m1.
    lw a3, 4(s6)            # Set a3: # of cols (width) of input.
    jal write_matrix        # Call function "write_matrix".

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    lw a0, 8(s6)            # Set a0: ptr to the start of score.
    lw t1, 0(s6)            # t0: rows of score.
    lw t2, 4(s6)            # t1: cols of score.
    mul a1, t1, t2          # Set a1: # of elements in score.
    jal argmax              # Call function "argmax".

    # Print classification
    bne s1, zero, skip_print    
    mv a1, a0               # Set a1: integer to print.
    jal print_int

    # Print newline afterwards for clarity
    addi a1, zero, 10       # Set a1: char to print('\n', 10).

skip_print:
    # Free mallocs.
    mv a0, s2               # Set a0: ptr to m0 attributes.
    jal call_free
    mv a0, s3               # Set a0: ptr to m1 attributes.
    jal call_free
    mv a0, s4               # Set a0: ptr to i_m attributes.
    jal call_free
    mv a0, s5               # Set a0: ptr to d1 attributes.
    jal call_free
    mv a0, s6               # Set a0: ptr to d2 attributes.
    jal call_free

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

# a0: ptr to matrix attributes.
call_free:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0               # s0: ptr to matrix attributes.
    lw a0, 8(s0)            # Set a0: matrix.
    jal free                # Call function "free".
    mv a0, s0               # Set a0: ptr to matrix attributes.
    jal free                # Call function "free".
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

# Exceptions:
error_88:
    li a1, 88
    jal exit2

error_89:
    li a1, 89
    jal exit2
