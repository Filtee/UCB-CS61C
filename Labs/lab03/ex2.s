.globl main

.data
source:
    .word   3
    .word   1
    .word   4
    .word   1
    .word   5
    .word   9
    .word   0
dest:
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0

.text
fun:
    addi t0, a0, 1       # t0 = a0 + 1;
    sub t1, x0, a0       # t1 = -a0;
    mul a0, t0, t1       # a0 = t0 * t1;
    jr ra                # return;

main:
    # BEGIN PROLOGUE
    addi sp, sp, -20
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw ra, 16(sp)
    # END PROLOGUE
    addi t0, x0, 0       # int k = 0;
    addi s0, x0, 0       # int sum = 0;
    la s1, source
    la s2, dest
loop:
    slli s3, t0, 2       # s3 = k * 4; (Offset Bytes)
    add t1, s1, s3       # t1 = s1 + OB;
    lw t2, 0(t1)         # t2 = source[k];
    beq t2, x0, exit     # if (t2 == 0) ==> exit;
    add a0, x0, t2       # a0 = source[k];
    addi sp, sp, -8      # Adjust stack for 2 items;
    sw t0, 0(sp)         # Save t0 for use afterwards.
    sw t2, 4(sp)         # Save t2 for use afterwards.
    jal fun              # Proceed function "fun".
    lw t0, 0(sp)         # Restore t0 for caller.
    lw t2, 4(sp)         # Restore t2 for caller.
    addi sp, sp, 8       # Adjust stack to delete 2 items;
    add t2, x0, a0       # t2 = fun(source[k]);
    add t3, s2, s3       # t3 = s2 + OB;
    sw t2, 0(t3)         # dest[k] = fun(source[k]);
    add s0, s0, t2       # sum += dest[k];
    addi t0, t0, 1       # k++;
    jal x0, loop         # Loop.
exit:
    add a0, x0, s0       # a0 = sum;
    # BEGIN EPILOGUE
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, 20
    # END EPILOGUE
    jr ra
