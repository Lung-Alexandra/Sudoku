.data	
	fp: .space 4
	trei: .long 3
	nrcom: .long 0
	poz: .long 0
	num: .long 0
	prim_elem: .long 0
	lines: 	.long 9
	columns: .long 9
	lineIndex: .space 4
	columnIndex: .space 4
	lineIndex1: .space 4
	columnIndex1: .space 4
	lineIndex3: .space 4
	columnIndex3: .space 4
	slinie: .space 4
	scoloana: .space 4
	matrix:	.space 1000
	fisier: .space 10
	mod: .asciz "r"
	fisiero: .space 10
	modo: .asciz "w"
	formatmes: .asciz "Dati numele fisierului din care se citesc datele: "
	formatmes2: .asciz "Dati numele fisierului in care se scriu datele: "
	nosol: .asciz "Nu exista solutie\n"
	formatInt: .asciz "%d "
	newLine: .asciz "\n"
	formatin: .asciz "%d"

.text

.global main
		
afisare:
	// %esp:(<adr de in>)(*matrix)
	pushl %ebp
	movl %esp, %ebp
	// %esp:%ebp:(%ebp v)(<adr de in>)(*matrix)
	
	pushl %edi
	// %esp:(%edi v)%ebp:(%ebp v)(<adr de in>)(*matrix)
	movl 8(%ebp), %edi 
	
	pushl $modo
	pushl $fisiero
	call fopen
	popl %edx
	popl %edx
    	movl %eax, fp
        
	pushl %ebx
	movl $0, lineIndex

afisare_for_lines:
	movl lineIndex, %ecx
	cmp %ecx, lines
	je afisare_ret
	
	// incepe al doilea for
	movl $0, columnIndex
	afisare_for_columns:
		movl columnIndex, %ecx
		cmp %ecx, columns
		je afisare_cont_for_lines
		
		// prelucrarea efectiva
		// elementul curent este la 
		// lineIndex * columns + columnIndex
		// relativ la adresa de inceput a matricei
		// adica relativ la %edi 
		// toate elementele sunt .long = au dim. 4 bytes
		
		movl lineIndex, %eax
		// %eax = lineIndex
		mull columns
		// %eax = %eax * columns
		addl columnIndex, %eax
		// %eax := %eax (lineIndex * columns) + columnIndex
		
		movl (%edi, %eax, 4), %ebx
		// %ebx acum este elementul curent din matrice
		// %ebx = matrix[lineIndex][columnIndex]
		// de la pozitia (lineIndex, columnIndex)
		// %ebx este elementul pe care vreau sa il afisez
		
		movl fp, %eax
		pushl %ebx
		push $formatInt
		pushl %eax
		call fprintf 
		pop %ebx 
		pop %ebx
		popl %ebx
		
		pushl $0
		call fflush
		popl %ebx
		
		addl $1, columnIndex
		jmp afisare_for_columns
	
afisare_cont_for_lines:
	movl fp, %eax
	push $newLine
	pushl %eax
	call fprintf 
	pop %ebx 
	popl %ebx

	addl $1, lineIndex
	jmp afisare_for_lines

afisare_ret:
	popl %ebx
	popl %edi
	popl %ebp
	ret


	
citire:
	// %esp:(<adr de in>)(*matrix)
	pushl %ebp
	movl %esp, %ebp
	// %esp:%ebp:(%ebp v)(<adr de in>)(*matrix)

	pushl %edi
	// %esp:(%edi v)%ebp:(%ebp v)(<adr de in>)(*matrix)
	movl 8(%ebp), %edi 
	
	pushl $mod
	pushl $fisier
	call fopen
	popl %edx
	popl %edx
        movl %eax, fp
	pushl %ebx
	movl $0, lineIndex
	
citire_for_lines:
	movl lineIndex, %ecx
	cmp %ecx, lines
	je citire_ret
	
	// incepe al doilea for
	movl $0, columnIndex
	citire_for_columns:
		movl columnIndex, %ecx
		cmp %ecx, columns
		je citire_cont_for_lines
		
		// elementul curent este la 
		// lineIndex * columns + columnIndex
		
		movl lineIndex, %eax
		// %eax = lineIndex
		mull columns
		// %eax = %eax * columns
		addl columnIndex, %eax
		// %eax := %eax (lineIndex * columns) + columnIndex
		movl %eax, poz
		movl fp, %eax 	
	 	
		pushl $num
		pushl $formatin
		pushl %eax
		call fscanf
		popl %ebx
		popl %ebx
		popl %ebx
		
		movl poz, %ebx
		movl num, %eax
		movl %eax, (%edi, %ebx, 4)

		
		addl $1, columnIndex
		jmp citire_for_columns
	
citire_cont_for_lines:
	addl $1, lineIndex
	jmp citire_for_lines


citire_ret:
	popl %ebx
	popl %edi
	popl %ebp
	ret

numok:
	// %esp:(<adr de in>)(linie)(coloana)(numar)
	pushl %ebp
	movl %esp, %ebp
	// %esp:%ebp:(%ebp v)(<adr de in>)(linie)(coloana)(numar)
	
	pushl %edi
	// %esp:(%edi v)%ebp:(%ebp v)(<adr de in>)(linie)(coloana)(numar)
	movl $matrix, %edi 
	movl 8(%ebp), %eax
	movl %eax, lineIndex1
	movl 12(%ebp), %eax
	movl %eax, columnIndex1 
	movl 16(%ebp), %eax
	movl %eax, num 
	pushl %ebx
	xor %ecx, %ecx
//vedem daca avem nr deja pe linie
numok_for1:
	cmp $9, %ecx
	je numok_for2inter
	
	
	movl lineIndex1, %eax
	// %eax = lineIndex1
	mull columns
	// %eax = %eax * columns
	addl %ecx, %eax
	// %eax := %eax (lineIndex1 * columns) + %ecx
	
	movl (%edi, %eax, 4), %ebx
	// %ebx acum este elementul curent din matrice
	// %ebx = matrix[lineIndex1][ecx]
	cmp num, %ebx
	je returnare0 		
		
	addl $1, %ecx
	jmp numok_for1

numok_for2inter:
	xor %ecx, %ecx
	
numok_for2:
	
	cmp $9, %ecx
	je numok_for3inter
	
	movl %ecx, %eax
	
	mull columns
	// %eax = %eax * columns
	addl columnIndex1, %eax
	// %eax := %eax (ecx * columns) + columnIndex1
	
	movl (%edi, %eax, 4), %ebx
	// %ebx acum este elementul curent din matrice
	// %ebx = matrix[ecx][columnIndex1]
	cmp num, %ebx
	je returnare0 		
		
	//movl poz, %ecx	
	addl $1, %ecx
	jmp numok_for2

numok_for3inter:

	xorl %edx, %edx
	movl lineIndex1, %eax
	divl trei
	movl lineIndex1, %eax
	subl %edx, %eax
	movl %eax, slinie
	
	xorl %edx, %edx
	movl columnIndex1, %eax
	divl trei
	movl columnIndex1, %eax
	subl %edx, %eax
	movl %eax, scoloana
	
	
	movl $0,lineIndex3
	
numok_for3:	
	movl lineIndex3, %ecx
	cmp $3, %ecx
	je returnare1
	
	// incepe al doilea for
	movl $0, columnIndex3
	numok_for3_columns:
		movl columnIndex3, %ecx
		cmp $3, %ecx
		je numokfor3_cont_for_lines
		
		movl lineIndex3, %eax
		addl slinie, %eax
		// %eax = lineIndex
		mull columns
		// %eax = %eax * columns
		addl columnIndex3, %eax
		addl scoloana, %eax
		// %eax := %eax ((slinie+lineIndex) * columns) + (columnIndex+scoloana)
		movl $matrix, %edi
		movl (%edi, %eax, 4), %ebx
		// %ebx acum este elementul curent din matrice
		// %ebx = matrix[slinie+lineIndex][scoloana+columnIndex]
		
		
		cmp num, %ebx
		je returnare0
		
		addl $1, columnIndex3
		jmp numok_for3_columns
	
numokfor3_cont_for_lines:

	addl $1, lineIndex3
	jmp numok_for3
	
returnare0:
	xor %eax, %eax
	
	popl %ebx
	popl %edi
	popl %ebp
	ret
	
returnare1:
	xor %eax, %eax
	incl %eax

	popl %ebx
	popl %edi
	popl %ebp
	ret


sudoku:
	pushl %ebp
	movl %esp, %ebp
	
	
	pushl %edi
	
	
	movl 8(%ebp), %eax
	movl %eax, lineIndex
	movl 12(%ebp), %eax
	movl %eax, columnIndex 
	pushl %ebx
	cmp $9, %eax
	je posibilret
	
	jmp continuareif2
//if eax ==0 ->is safe return 0 
posibilret:
	movl lineIndex, %ebx
	cmp $8, %ebx
	je returnare1s
	
continuareif2:
	movl columnIndex, %ebx	
	cmp $9, %ebx
	je new
	
	jmp continuareif3
new:
	incl lineIndex
	movl $0, columnIndex

continuareif3:
	movl lineIndex, %eax
	mull columns
	addl columnIndex, %eax
	
	movl $matrix, %edi
	movl (%edi, %eax, 4), %ebx
	cmp $0, %ebx
	jne reapelare
	
	movl $0, %ecx
	incl %ecx
	jmp for_completare

reapelare:
	incl columnIndex
	pushl columnIndex
	pushl lineIndex
	call sudoku
	popl lineIndex
	popl columnIndex
	decl columnIndex 
	cmp $1, %eax
	je sudokuret 
	
for_completare:
	
	cmp $10, %ecx
	je returnare0s	
	
	pushl %ecx
	pushl columnIndex
	pushl lineIndex
	call numok
	popl %ebx
	popl %ebx
	popl %ecx
	
	cmp $0 , %eax
	je inter_cont
	
	movl lineIndex, %eax
	mull columns
	addl columnIndex, %eax
	
	movl $matrix, %edi
	movl %ecx, (%edi, %eax, 4)
	
	pushl %ecx
	incl columnIndex
	pushl columnIndex
	pushl lineIndex
	call sudoku
	popl lineIndex
	popl columnIndex
	decl columnIndex 
	popl %ecx
	
	cmp $1, %eax
	je returnare1s
	

inter_cont:	
	movl lineIndex, %eax
	mull columns
	addl columnIndex, %eax
	
	movl $matrix, %edi
	movl $0, (%edi, %eax, 4)
			
complet_cont:		
	addl $1, %ecx
	jmp for_completare

		 
returnare0s:
	xor %eax, %eax
	
	popl %ebx
	popl %edi
	popl %ebp
	ret
	
returnare1s:
	xor %eax, %eax
	incl %eax

	popl %ebx
	popl %edi
	popl %ebp
	ret
	
sudokuret: 
	popl %ebx
	popl %edi
	popl %ebp
	ret

main:
	pushl $formatmes
	call printf 
	popl %ebx
	
	pushl $fisier
	call gets
	popl %ebx
	
	pushl $formatmes2
	call printf 
	popl %ebx
	
	pushl $fisiero
	call gets
	popl %ebx
	
	//citesc 
	pushl $matrix
	call citire
	popl %ebx
	
	
	pushl $0
	pushl $0
	call sudoku
	popl %ebx
	popl %ebx
	
	cmp $0, %eax
	je afisarenosol

	pushl $matrix
	call afisare
	popl %ebx

	jmp et_exit
	
afisarenosol:
	pushl $modo
	pushl $fisiero
	call fopen
	popl %ebx
	popl %ebx
    	movl %eax, fp
        
	movl fp, %eax
	pushl $nosol
	pushl %eax
	call fprintf 
	popl %ebx 
	popl %ebx
	
	pushl $0
	call fflush
	popl %ebx

	movl fp, %eax
	push $newLine
	pushl %eax
	call fprintf 
	pop %ebx 
	popl %ebx
	
et_exit:
	mov $1, %eax
	mov $0, %ebx
	int $0x80
