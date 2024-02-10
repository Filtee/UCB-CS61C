.globl abs

.text
# =================================================================
# FUNCTION: Given an int return its absolute value.
# Arguments:
# 	a0 (int) is input integer
# Returns:
#	a0 (int) the absolute value of the input
# =================================================================
abs:
    # Prologue
    addi sp, sp, -4
    sw s0, 0(sp)

    mv s0, a0            # s0 = a0
    bgt s0, zero, end    # if s0 > 0 then end
    sub s0, zero, s0     # s0 = -s0

end:
    mv a0, s0            # a0 = s0

    # Epilogue
    lw s0, 0(sp)
    addi sp, sp, 4

    ret
