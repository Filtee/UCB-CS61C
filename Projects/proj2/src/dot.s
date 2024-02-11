.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 75.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 76.
# =======================================================
dot:
    # Check exceptions first hand.
    addi t0, zero, 1
    # Check if the length of the vector is less than 1.
    blt a2, t0, error_75    # if s1 < 1 then error_75
    # Check if the stride of either vector is less than 1.
    blt a3, t0, error_76    # if s3 < 1 then error_76
    blt a4, t0, error_76    # if s3 < 1 then error_76

    # Prologue
    addi sp, sp, -20
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)

loop_start:
    mv s0, a0               # s0: pointer to the start of v0
    mv s1, a1               # s1: pointer to the start of v1
    mv s2, a2               # s2: length of the vectors
    mv s3, a3               # s3: stride of v0
    mv s4, a4               # s4: stride of v1
    mv t0, zero             # t0: counter
    mv t1, zero             # t1: sum of dot product

loop_continue:
    # Check if the loop comes to the end.
    beq t0, s2, loop_end    # if t0 == s1 then loop_end

    mul t2, t0, s3          # Count the offset by index of v0.
    slli t2, t2, 2          # Count offset bytes of v0.
    add t2, s0, t2          # Get address of v0.
    lw t2, 0(t2)            # Load item from v0.

    mul t3, t0, s4          # Count the offset by index of v1.
    slli t3, t3, 2          # Count offset bytes of v1.
    add t3, s1, t3          # Get address of v1.
    lw t3, 0(t3)            # Load item from v1.

    mul t2, t2, t3          # Count product of i-th element.
    add t1, t1, t2          # Add into sum.

    addi t0, t0, 1          # cnt++
    j loop_continue         # Jump back to loop_continue.

loop_end:
    mv a0, t1               # Set return value.

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    addi sp, sp, 20
    
    ret

error_75:
    li a1, 75
    jal exit2

error_76:
    li a1, 76
    jal exit2