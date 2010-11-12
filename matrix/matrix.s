.global _start
.text
#        ENTRY            		/*  mark the first instruction to call */
.equ	dim, 3  /* dimension de la matriz */
.equ	lim, dim+1  /* dimension de la matriz +1*/
.equ	sizerow, dim*4  /* dimension de la matriz* tamaño de palabra*/
.equ	sizerow2, (dim-1)*sizerow-4  /* return to origin +1*/
.equ	sizerow3, dim*sizerow-4  /* return to origin +1*/

_start:
.arm /*indicates that we are using the ARM instruction set */
#------standard initial code
# --- Setup interrupt / exception vectors 
      B       Reset_Handler 

Reset_Handler:  
#        
        LDR     r0, =a        /*  r0 = pointer to source matrix A */
        LDR     r1, =b       /*  r1 = pointer to source matrix B */
        LDR     r2, =c        /*  r2 = pointer to dest. matrix */
        MOV     sp, #0x400      /*  set up stack pointer (r13) */ 
        BL multiply_arm
        ADR r3, multiply_th+1
        BX r3

.extern     multiply 
        ldr         r3, = multiply
        mov         lr, pc 
#        bx          r3
stop:
		B		stop
multiply_arm:
        STMFD   sp!, {r0-r14}   /*  saves the working registers */
# r4 -> index j
# r3 -> index i
		MOV r3, #lim

new_column_b:
		MOV r4, #lim
		SUBS r3, r3, #1
		BEQ end_mult_arm
		LDR   r9, [r1], #sizerow
		LDR   r10, [r1],#sizerow
		LDR   r11, [r1],#-sizerow2
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
		SUB   r2, r2, #sizerow3
		B new_column_b
		
end_mult_arm:
		LDMFD   sp!, {r0-r14}   /*don't need these now, restore the original registers*/
		BX lr
		
.thumb /*indicates that we are using the thumb instruction set */

multiply_th:
# r4 -> index j
# r3 -> index i
		MOV r3, #lim

th_new_column_b:
		MOV r4, #lim
		SUB r3, r3, #1
		BEQ end_mult_th
		#TODO: -> read row -> pop registers in order to gain room -> 	
		#LDR   r5, [r1], #sizerow
		# ->  value from A, value from B and multiply?
		# ->  OR temp row 
		#LDR   r6, [r1],#sizerow
		#LDR   r7, [r1],#-sizerow2
		#MOV   r14, r0
		

th_new_row_a:
		SUB r4, r4, #1 
		BEQ th_incr_index_res
		#TODO: Cogiendo Columna
		#r5-r7 -> row Matrix A
		#r5-r7-> column Matrix B
		#r12   -> result
		#LDMIA   r14!, {r6-r8}	
		
		#MUL r12, r6, r9
		#MLA r12, r7, r10, r12
		#MLA r12, r8, r11, r12
		##aumentando puntero a columnas
		#STR   r12, [r2], #sizerow
		B th_new_row_a

th_incr_index_res:
		SUB   r2, r2, #sizerow3
		B th_new_column_b
		
end_mult_th:
		B stop   /*don't need these now, restore the original registers*/


.data
.ltorg /*guarantees the alignment*/
a:
     .long     1,2,3,4,5,6,7,8,9
b:
     .long     9,8,7,6,5,4,3,2,1
     #.long     1,0,0,0,1,0,0,0,1
c:
     .long     0,0,0,0,0,0,0,0,0

.end /* Mark*/
