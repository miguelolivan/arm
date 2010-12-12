/*
	multiply_n_arm. Multiplica dos matrices nxn en código ARM
	
		parámetros:
			r0 -> Puntero al comienzo del la matriz A
			r1 -> Puntero al comienzo del la matriz B
			r2 -> Puntero al comienzo del la matriz C (resultado)
			
		Además usa los registros del siguiente modo:
			r3		-> contador de carga de fila
			r4		-> contador de columnas de B
			r5		-> contador de filas de A
			r6-8		-> valores de fila de A
			r9-11		-> valores de columna de C
			r12		-> Valor temporal de multiplicación acumulación
			r13		-> No usado

*/		
.equ	dim, 4  /* dimension de la matriz */
.equ	lim, dim+1  /* dimension de la matriz +1*/
.equ	sizematrix, dim*dim*4  /*tamaño de matriz -> dimension *dimension * tamaño de palabra*/
.equ	sizerow, dim*4		/* tamaño de fila -> dimension de la matriz* tamaño de palabra*/
.equ	sizerow2, 2*dim*4 	/*tamaño de dos filas -> 2*dimension de la matriz* tamaño de palabra*/
.equ	retcol, (dim-1)*sizerow-4	/* retorno al origen +1 palabra-una fila*/
.equ	retcol2, dim*sizerow-4		/* retorno al origen +1 palabra*/
.global multiply_n_arm

multiply_n_arm:
        	STMFD   sp!, {r0-r14}   /*  saves the working registers */

# r4 -> index i
		MOV r4, #lim

new_column_b_n:
# r5 -> index j
		MOV r5, #lim
		SUBS r4, r4, #1
		BEQ end_mult_arm_n
new_row_a_n:
		SUBS r5, r5, #1 
		BEQ incr_index_res_n
# r3 -> index k
		MOV r3, #dim
		MOV r12, #0

load_block:
		CMP   r3, #3
		BLO   load_words
		#r6-r8 -> row Matrix A
		#r9-r11-> column Matrix B
		#r12   -> result
		LDR   r9, [r1], #sizerow
		LDR   r10, [r1], #sizerow
		LDR   r11, [r1], #sizerow
		
		LDMIA  r0!, {r6-r8} 
		MLA r12, r6, r9, r12
		MLA r12, r7, r10, r12
		MLA r12, r8, r11, r12
		SUBS  r3, r3, #3
		B load_block
load_words:
		CMP  r3, #0
		BEQ end_load
load_word:
		LDR   r9, [r1], #sizerow
		LDR   r6, [r0], #4 
		MLA r12, r6, r9, r12
		SUBS r3, r3, #1
		BNE load_word
end_load:
		STR   r12, [r2], #sizerow
		SUB   r1, r1, #sizematrix
		B new_row_a_n

incr_index_res_n:
		#siguiente columna
		SUB   r2, r2, #retcol2
		ADD   r1, r1, #4
		SUB   r0, r0, #sizematrix
		B new_column_b_n
		
end_mult_arm_n:
		LDMFD   sp!, {r0-r14}   /*don't need these now, restore the original registers*/
		BX lr
