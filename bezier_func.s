	section .data
t: dd 0.00001
zero: dd 0.0	
one: dd 1.0

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

	mov		ax, [rdi]		;x[counter]
	mov		bx, [rsi]		;y[counter]
	jmp		print_core_pixel

two_points:

	movss		xmm0, dword [zero]	;licznik
	movss		xmm1, dword [t]	;przypisanie 1

	cvtsi2ss xmm4, [rdi] ;load x0
	cvtsi2ss xmm5, [rdi+4] ; load x1
	cvtsi2ss xmm6, [rsi] ; load y0
	cvtsi2ss xmm7, [rsi+4]; load y1

two_loop:
two_points_x:
	movss xmm3, [one]
	subss xmm3, xmm0 ; 1-t

	movss xmm8, xmm3 ; (1-t)
	mulss xmm8, xmm4 ; (1-t) * x0

	movss xmm9, xmm0 ; t
	mulss xmm9, xmm5 ; t * x1

	addss xmm8, xmm9
	cvtss2si rax, xmm8

two_points_y:
	movss xmm8, xmm3 ; (1-t)
	mulss xmm8, xmm6 ; (1-t) * y0

	movss xmm9, xmm0 ; t 
	mulss xmm9, xmm7 ; t * y1
	
	addss xmm8, xmm9
	cvtss2si rbx, xmm8

draw_from_two_points:

	imul	rbx, 800
	add		rax, rbx
	imul	rax, 3

	add	rax, r10 

	mov	[rax], BYTE 0
	mov	[rax+1], BYTE 0
	mov	[rax+2], BYTE 0


next_two_points:
	addss xmm0, xmm1
	movss xmm3, [one]
	cmpss xmm3, xmm0, 2	
	movq rax, xmm3
	cmp rax, 0
	je two_loop 
	jmp end

three_points:

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
	add		rax, rbx		;pozycja x = x + bajty w rzędzie 
	imul	rax, 3			;pierwszy bajt pixela = pozycja x * 3

	add		r10, rax

	mov		[r10-3], r11d
	mov		[r10], r11d
	mov		[r10+3], r11d
	
	mov		[r10+2397], r11d 
	mov		[r10+2400], r11d 
	mov		[r10+2403], r11d 

	mov		[r10-2403], r11d 
	mov		[r10-2400], r11d 
	mov		[r10-2397], r11d 

end:
	pop		rsi
	pop 	rdi
	mov		rsp, rbp
	pop		rbp
	ret