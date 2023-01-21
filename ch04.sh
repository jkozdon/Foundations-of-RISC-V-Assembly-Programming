# EX01
cat > ch04_ex01.s << EOF
# define exit as 93
.equ exit, 93
# program code
.section .text
# export _start for linker
.globl  _start
_start:
        li      a7, exit
        ecall
# data: init one word (16-bit value) with 1 and read/write
.section .data
counter:
.word 1
# rodata: constant text string
.section .rodata
text_begin:
.asciz  "Text"
text_end:
# current address minus address of text_begin = length of text
.byte .-text_begin
# non initialized block with same size as the text
.section .bss
# start next part by address aligned to multiple of 2^2 = 4
.align 2
copy_begin:
.zero text_end-text_begin
EOF

riscv64-unknown-elf-as -o ch04_ex01.o ch04_ex01.s

riscv64-unknown-elf-ld -o ch04_ex01 ch04_ex01.o

riscv64-unknown-elf-objdump -f -d -Mno-aliases,numeric ch04_ex01

riscv64-unknown-elf-objdump -t ch04_ex01

riscv64-unknown-elf-objdump -F -s ch04_ex01

# EX02
cat > ch04_ex02.s << EOF
.text
.globl _start
_start:
    la x1, counter    #load address of counter
    addi x1, x1, 4    #go to next word address += 4
    lw x2, 0(x1)      #load value from address, the 2

    li x1, 2
    lw x3, counter    #load word from address counter, the 0
    add x3, x2, x1    #add: x3 = x2 + x1
    sw x3, counter, x2 #save x3, use x2 for address
.data
counter:
    .word 0, 2
EOF

riscv64-unknown-elf-as -o ch04_ex02.o ch04_ex02.s
riscv64-unknown-elf-ld -o ch04_ex02 ch04_ex02.o
riscv64-unknown-elf-objdump -f -d -Mno-aliases,numeric ch04_ex02

# EX03
# Compute a(n) = a(n-1) + 3 via recursion
cat > ch04_ex03.s << EOF
.globl _start
_start:
        li a0, 5  # compute for n = 5
        call compute

        # exit
        li a7, 93
        ecall

compute:
        # allocate stack for register ra
        # RV64 registers are 64 bit = 8 bytes
        addi sp, sp, -8
        sd ra, 0(sp)

        # check if recursion ends; yes? then jump
        beq a0, x0, compend

        # otherwise prepare a(n-1)
        addi a0, a0, -1
       # recursion
        call compute
       # result of a(n) = a(n-1) + 3
        addi a0, a0, 3
        # return function
        j compret
compend:
        # if (n ==0) is reached, return a(0) = 2
        li a0, 2
compret:
        # restore ra
        ld ra, 0(sp)
        # free stack
        addi sp, sp, 8
        ret
EOF

riscv64-unknown-elf-as -o ch04_ex03.o ch04_ex03.s
riscv64-unknown-elf-ld -o ch04_ex03 ch04_ex03.o
riscv64-unknown-elf-objdump -f -d -Mno-aliases,numeric ch04_ex02
