.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:

    # Error checks
    addi t0, zero, 1
    # Check if the dimensions of m0 do not make sense.
    blt a1, t0, error_72        # if a1 < 1 then error_72
    blt a2, t0, error_72        # if a2 < 1 then error_72
    # Check if the dimensions of m0 do not make sense.
    blt a4, t0, error_73        # if a3 < 1 then error_73
    blt a5, t0, error_73        # if a4 < 1 then error_73
    # Check if the dimensions of m0 and m1 don't match.
    bne a2, a4, error_74        # if a2 != a4 then error_74
    

    # Prologue
    addi sp, sp, -32
    sw ra, 0(sp)                
    sw s0, 4(sp)                # s0: pointer to the start of m0
    sw s1, 8(sp)                # s1: number of rows of m0
    sw s2, 12(sp)               # s2: number of columns of m0
    sw s3, 16(sp)               # s3: pointer to the start of m1
    sw s4, 20(sp)               # s4: number of rows of m1
    sw s5, 24(sp)               # s5: number of columns of m1
    sw s6, 28(sp)               # s6: pointer to the start of d

    mv s0, a0                   
    mv s1, a1                   
    mv s2, a2                   
    mv s3, a3                   
    mv s4, a4                   
    mv s5, a5                   
    mv s6, a6              

    mv t0, zero                 # t0: row counter
    mv t1, zero                 # t1: column counter

outer_loop_start:
    beq t0, s1, outer_loop_end  # if t0 == s1 then outer_loop_end
    mul t2, t0, s2              # Count gap between each row vector.
    slli t2, t2, 2              # Count the offset bytes.
    add t2, s0, t2              # Count address of row vector.

inner_loop_start:
    beq t1, s5, inner_loop_end  # if t1 == s5 then inner_loop_end
    slli t3, t1, 2              # Count the offset bytes.
    add t3, s3, t3              # Count address of column vector.

    mv a0, t2                   # a0: pointer to the start of v0
    mv a1, t3                   # a1: pointer to the start of v1
    mv a2, s2                   # a2: length of the vectors
    addi a3, zero, 1            # a3: stride of v0
    mv a4, s5                   # a4: stride of v1

    addi sp, sp, -12
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    ebreak
    jal dot                     # Call function "dot".
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    addi sp, sp, 12

    mul t3, t0, s5              # t2 =  t0 * s5
    add t3, t3, t1              # Count offset by index of D.
    slli t3, t3, 2              # Count offset bytes of D.
    add t3, s6, t3              # Count the address of D item.
    sw a0, 0(t3)                # Save result in D(t0, t1).

    addi t1, t1, 1              # Increment column counter by 1.
    j inner_loop_start          # jump back to inner_loop_start

inner_loop_end:
    addi t0, t0, 1              # Increment row counter by 1.
    mv t1, zero                 # Set column counter back to 0.
    j outer_loop_start          # jump back to outer_loop_start

outer_loop_end:
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

error_72:
    li a1, 72
    jal exit2

error_73:
    li a1, 73
    jal exit2

error_74:
    li a1, 74
    jal exit2