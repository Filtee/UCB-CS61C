.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:
    # Check if the length of vector is less than 1.
    addi t0, zero, 1            # t0 = 1
    blt a1, t0, error           # if s1 < 1 then error

    # Prologue
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)

loop_start:
    mv s0, a0                   # s0: pointer to the start of vector
    mv s1, a1                   # s1: number of elements

    # Set the first item as default.
    addi t0, zero, 1            # t0: counter
    mv t1, zero                 # t1: index of the largest
    lw t2, 0(s0)                # t2: current larget value

loop_continue:
    # Check if the loop comes to the end.
    beq t0, s1, loop_end        # if t0 == s1 then loop_end     

    slli t3, t0, 2              # Count the offset bytes.
    add t3, s0, t3              # Get the address of item.
    lw t3, 0(t3)                # Load the value of item.

    # Check if value is the largest.
    ble t3, t2, loop_back       # if t3 <= t2 then loop_back
    mv t1, t0                   # Restore the current index.
    mv t2, t3                   # Restore the largest value.
loop_back:
    addi t0, t0, 1              # cnt++
    j loop_continue             # jump to loop_continue

loop_end:
    mv a0, t1                   # Set return value.

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8

    ret

error:
    li a1, 77                   # Set error code 77.
    jal exit2                   # Terminate the program.
