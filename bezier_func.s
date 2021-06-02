	section .data
t: dd 0.00001
zero: dd 0.0	
one: dd 1.0
two: dd 2.0

	section	.text
global draw_bezier

draw_bezier:

	push	rbp
	mov		rbp, rsp	;prolog

	push	rdi ;początek tablicy współrzędnych x
	push	rsi ;początek tablicy współrzędnych y
	
	mov		rax, 0		;wyzeruj rax
	mov		rbx, 0		;wyzeruj rbx

	mov		r10, rdx		;adres początku bitmapy
	mov		r11, 0xff000000	;zapis koloru

points:

	cmp		rcx, 0
	je		one_point

	cmp		rcx, 1
	je		two_points

	cmp		rcx, 2
	je		three_points

	cmp		rcx, 3
	je		four_points

	cmp		rcx, 4
	je		five_points

one_point:

	mov		ax, [rdi]		;x0
	mov		bx, [rsi]		;y0
	jmp		print_core_pixel

two_points:

	movss	xmm0, dword [zero]	;licznik
	movss	xmm2, dword [t]		;przypisanie t

two_loop:

	movss	xmm1, dword [one]	;przypisanie 1
	movss	xmm3, xmm1
	subss	xmm3, xmm0	;przypisanie (1 - t)

two_points_x:

	cvtsi2ss	xmm4, [rdi]		;konwersja x0 do floata	
	cvtsi2ss	xmm5, [rdi+4] 	;konwersja x1 do floata

	movss	xmm6, xmm4	;x = x0
	mulss	xmm6, xmm3	;x = x0 * (1 - t) 

	movss 	xmm7, xmm5	;tmp = x1
	mulss	xmm7, xmm0	;tmp = x1 * t

	addss	xmm6, xmm7	;x = x0 * (1 - t) + x1 * t 

	cvtss2si	rax, xmm6	;konwersja x do inta
	
two_points_y:

	cvtsi2ss	xmm4, [rsi]		;konwersja y0 do floata
	cvtsi2ss	xmm5, [rsi+4]	;konwersja y1 do floata

	movss	xmm6, xmm4	;y = y0
	mulss	xmm6, xmm3	;y = y0 * (1 - t) 

	movss 	xmm7, xmm5	;tmp = y1
	mulss	xmm7, xmm0	;tmp = y1 * t

	addss	xmm6, xmm7	;y = y0 * (1 - t) + y1 * t 

	cvtss2si	rbx, xmm6	;konwersja y do inta

draw_from_two_points:

	imul	rbx, 800	;bajty w rzędzie = y * szerokość
	add		rax, rbx	;pozycja pixela = bajty w rzedzie + x
	imul	rax, 3		;pierwszy bajt pixela = pozycja pixela * 3

	add		rax, r10 	;adres pixela

	mov		[rax], word 0
	mov		[rax+2], byte 0

next_two_points:

	addss	xmm0, xmm2	;licznik + t
	cmpss	xmm1, xmm0, 2	
	movq	rax, xmm1
	cmp		rax, 0
	je		two_loop

	mov		rax, 0
	mov 	rbx, 0

	mov		ax, [rdi+4]
	mov		bx, [rsi+4]

	jmp 	print_core_pixel	

three_points:

	movss	xmm0, [zero]	;licznik
	movss	xmm2, [t]		;przypisanie t

three_loop:

	movss	xmm1, [one]		;przypisanie 1
	movss	xmm3, xmm1
	subss	xmm3, xmm0		;przypisanie (1 - t)

	cvtsi2ss	xmm4, [rdi]		;konwersja x0 do floata
	cvtsi2ss	xmm5, [rdi+4]	;konwersja x1 do floata
	cvtsi2ss	xmm6, [rdi+8]	;konwersja x2 do floata	

	movss	xmm7, xmm4	;x = x0
	movss	xmm8, xmm3	;tmp = (1 - t)
	mulss	xmm8, xmm3	;tmp = (1 - t) ^ 2
	mulss	xmm7, xmm8	;x = x0 * (1 - t) ^ 2

	movss	xmm8, xmm3	;tmp = (1 - t)
	mulss	xmm8, [two]		;tmp = 2 * (1 - t)
	mulss	xmm8, xmm0	;tmp = 2 * (1 - t) * t
	mulss	xmm8, xmm5	;tmp = 2 * (1 - t) * t * x1
	addss	xmm7, xmm8	;x = x0 * (1 - t) ^ 2 + 2 * (1 - t) * t * x1

	movss	xmm8, xmm0	;tmp = t
	mulss	xmm8, xmm0	;tmp = t ^ 2
	mulss	xmm8, xmm6	;tmp = t ^ 2 * x2
	addss	xmm7, xmm8	;x = x0 * (1 - t) ^ 2 + 2 * (1 - t) * t * x1 + t ^ 2 * x2 

	cvtss2si	rax, xmm7

	cvtsi2ss	xmm4, [rsi]		;konwersja y0 do floata
	cvtsi2ss	xmm5, [rsi+4]	;konwersja y1 do floata
	cvtsi2ss	xmm6, [rsi+8]	;konwersja y2 do floata	

	movss	xmm7, xmm4	;y = y0
	movss	xmm8, xmm3	;tmp = (1 - t)
	mulss	xmm8, xmm3	;tmp = (1 - t) ^ 2
	mulss	xmm7, xmm8	;y = y0 * (1 - t) ^ 2

	movss	xmm8, xmm3	;tmp = (1 - t)
	mulss	xmm8, [two]		;tmp = 2 * (1 - t)
	mulss	xmm8, xmm0	;tmp = 2 * (1 - t) * t
	mulss	xmm8, xmm5	;tmp = 2 * (1 - t) * t * y1
	addss	xmm7, xmm8	;y = y0 * (1 - t) ^ 2 + 2 * (1 - t) * t * y1

	movss	xmm8, xmm0	;tmp = t
	mulss	xmm8, xmm0	;tmp = t ^ 2
	mulss	xmm8, xmm6	;tmp = t ^ 2 * y2
	addss	xmm7, xmm8	;y = y0 * (1 - t) ^ 2 + 2 * (1 - t) * t * y1 + t ^ 2 * y2 

	cvtss2si	rbx, xmm7	;konwersja y do inta
	
	imul	rbx, 800	;bajty w rzędzie = y * szerokość
	add		rax, rbx	;pozycja pixela = bajty w rzedzie + x
	imul	rax, 3		;pierwszy bajt pixela = pozycja pixela * 3

	add		rax, r10 	;adres pixela

	mov		[rax], word 0
	mov		[rax+2], byte 0	;zapis koloru


	addss	xmm0, xmm2	;licznik + t
	cmpss	xmm1, xmm0, 2	
	movq	rax, xmm1
	cmp		rax, 0
	je		three_loop

	mov		rax, 0
	mov 	rbx, 0

	mov		ax, [rdi+8]		;x[counter]
	mov		bx, [rsi+8]		;y[counter]
	jmp		print_core_pixel

four_points:

	mov		ax, [rdi+12]		;x[counter]
	mov		bx, [rsi+12]		;y[counter]
	jmp		print_core_pixel

five_points:

	mov		ax, [rdi+16]		;x[counter]
	mov		bx, [rsi+16]		;y[counter]
	jmp		print_core_pixel

print_core_pixel:

	imul	rbx, 800		;bajty w rzędzie = y * szerokość
	add		rax, rbx		;pozycja pixela = x + bajty w rzędzie 
	imul	rax, 3			;pierwszy bajt pixela = pozycja pixela * 3

	add		r10, rax

	mov		[r10-3], dword 0 
	mov		[r10+1], dword 0 
	mov		[r10+5], byte 0 
	
	mov		[r10+2397], dword 0 
	mov		[r10+2401], dword 0 
	mov		[r10+2405], byte 0 

	mov		[r10-2403], dword 0  
	mov		[r10-2399], dword 0 
	mov		[r10-2395], byte 0 

end:
	pop		rsi
	pop 	rdi
	mov		rsp, rbp
	pop		rbp
	ret