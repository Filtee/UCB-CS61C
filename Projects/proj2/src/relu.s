.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    # Check if array length is less than 1
    addi t0, zero, 1            # t0 = 1
    blt a1, t0, error           # if s1 < 1 then error

    # Prologue
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)

loop_start:
    mv s0, a0                   # s0: pointer to the array
    mv s1, a1                   # s1: number of elements
    mv t0, zero                 # t0: counter

loop_continue:
    # Check if the loop has come to the end.
    beq t0, s1, loop_end        # if t0 == s1 then loop_end

    slli t1, t0, 2              # Count the offset of bytes.
    add t1, s0, t1              # Get address of the item.
    lw t2, 0(t1)                # Get the value of item.

    bge t2, zero, loop_back     # if t2 >= 0 then loop_back
    mv t2, zero                 # t2 = 0
    sw t2, 0(t1)                # Set the item value to 0.
loop_back:
    addi t0, t0, 1              # cnt++
    j loop_continue             # jump to loop_continue

loop_end:
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    
	ret

error:
    li a1, 78           # Set error code 78.
    jal exit2           # Terminate the program.
    