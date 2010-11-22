.global _start
.text
#        ENTRY            		/*  mark the first instruction to call */
.equ	dim, 3  /* dimension de la matriz */
.equ	lim, dim+1  /* dimension de la matriz +1*/
.equ	sizematrix, dim*dim*4  /*tamaño de matriz -> dimension *dimension * tamaño de palabra*/
.equ	sizerow, dim*4		/* tamaño de fila -> dimension de la matriz* tamaño de palabra*/
.equ	sizerow2, 2*dim*4 	/*tamaño de dos filas -> 2*dimension de la matriz* tamaño de palabra*/
.equ	retcol, (dim-1)*sizerow-4	/* retorno al origen +1 palabra-una fila*/
.equ	retcol2, dim*sizerow-4		/* retorno al origen +1 palabra*/

_start:
.arm /*indicates that we are using the ARM instruction set */
#------standard initial code
# --- Setup interrupt / exception vectors 
      B       Reset_Handler 

Reset_Handler:  
#        
		/*  r0 = pointer to source matrix A */
        LDR     r0, =a
        /*  r1 = pointer to source matrix B */
        LDR     r1, =b
        /*  r2 = pointer to dest. matrix */
        LDR     r2, =c        
        MOV     sp, #0x400      /*  set up stack pointer (r13) */ 
        BL multiply_arm
        /*  r0 = pointer to source matrix A */
        LDR     r0, =a
        /*  r1 = pointer to source matrix B */
        LDR     r1, =b
        LDR     r2, =d        /*  r2 = pointer to dest. matrix */
        ADR r3, multiply_th+1
        adr		r14, return		/* we store the return address in r14*/
        BX r3
return:
.extern     c_multiply
 		LDR     r0, =a
        /*  r1 = pointer to source matrix B */
        LDR     r1, =b
        /*  r2 = pointer to dest. matrix */
		ldr     r2, =e        
        ldr     r3, = c_multiply
        mov     lr, pc 
        bx          r3
stop:
		B		stop
multiply_arm:
        STMFD   sp!, {r0-r14}   /*  saves the working registers */
# r4 -> index j
# r3 -> index i
#r5,r6 -> unused
		MOV r3, #lim

new_column_b:
		MOV r4, #lim
		SUBS r3, r3, #1
		BEQ end_mult_arm
		LDR   r9, [r1], #sizerow
		LDR   r10, [r1],#sizerow
		LDR   r11, [r1],#-retcol
		MOV   r14, r0
		

new_row_a:
		SUBS r4, r4, #1 
		BEQ incr_index_res
		#Cogiendo Columna
		#r6-r8 -> row Matrix A
		#r9-r11-> column Matrix B
		#r12   -> result
		LDMIA   r14!, {r6-r8}
		
		MUL r12, r6, r9
		MLA r12, r7, r10, r12
		MLA r12, r8, r11, r12
		#aumentando puntero a columnas
		STR   r12, [r2], #sizerow
		B new_row_a

incr_index_res:
		SUB   r2, r2, #retcol2
		B new_column_b
		
end_mult_arm:
		LDMFD   sp!, {r0-r14}   /*don't need these now, restore the original registers*/
		BX lr
		
.thumb /*indicates that we are using the thumb instruction set */

multiply_th:
# r0 -> A
# r1 -> B
# r2 -> dest
# r4 -> index j
# r3 -> index i
		MOV r3, #lim

th_new_column_b:
		MOV r4, #lim
		SUB r3, r3, #1
		BEQ end_mult_thr
		#r5-r7-> column Matrix B
		LDR   r5, [r1]
		LDR   r6, [r1, #sizerow]
		LDR   r7, [r1,#sizerow2]
		
th_new_row_a:
		SUB r4, r4, #1 
		BEQ th_incr_index_res
		PUSH {r1,r2,r3,r4}
		#TODO: Cogiendo Columna
		#r1-r3 -> row Matrix A
		#r4   -> result
		LDMIA   r0!, {r1-r3}	
		
		MUL r1, r5
		MUL r2, r6
		MUL r3, r7
		ADD r4, r1, r2
		ADD r4, r3
		POP {r1,r2,r3}
		STR   r4, [r2]
		ADD   r2, r2, #sizerow
		POP {r4}
		
		B th_new_row_a

th_incr_index_res:
		ADD   r1, r1, #4
		SUB   r0, r0, #sizematrix
		SUB   r2, r2, #retcol2
		B th_new_column_b
		
end_mult_thr:
		BX r14   

.data
.ltorg /*guarantees the alignment*/
a:
     .long     1,2,3,4,5,6,7,8,9
b:
	.long     9,8,7,6,5,4,3,2,1
c:
     .long     0,0,0,0,0,0,0,0,0
d:
     .long     0,0,0,0,0,0,0,0,0
e:
     .long     0,0,0,0,0,0,0,0,0

.end /* Mark*/
