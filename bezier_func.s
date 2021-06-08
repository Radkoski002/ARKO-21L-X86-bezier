	section .data
t: dd 0.00001
zero: dd 0.0	
one: dd 1.0
two: dd 2.0
three: dd 3.0
four: dd 4.0
six: dd 6.0

	section	.text
global draw_bezier

draw_bezier:

	push	rbp
	mov		rbp, rsp	;prolog

	mov		r9, rdx		;adres początku bitmapy
	mov		r11, rcx	;backup licznika

	movss	xmm0, [zero]	;licznik
	movss	xmm2, [t]		;przypisanie t

print_core_pixels:

	mov 	rax, 0
	mov		rbx, 0

	mov		ax, [rdi]
	mov		bx, [rsi]

	imul	rbx, 800		;bajty w rzędzie = y * szerokość
	add		rax, rbx		;pozycja pixela = x + bajty w rzędzie 
	imul	rax, 3			;pierwszy bajt pixela = pozycja pixela * 3

	mov		r10, r9
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

	cmp		r11, 0
	je		line	

	dec		r11

	add		rdi, 4 
	add		rsi, 4 
	jmp		print_core_pixels

line:

	mov		r11, rcx
	cmp		r11, 0
	je		points

	imul	r11, 4
	sub		rdi, r11
	sub		rsi, r11
	
	mov		r11, rcx
line_cond:
	
	cmp		r11, 0
	je		points

	movss	xmm0, [zero]

line_loop:

	movss	xmm1, dword [one]	;przypisanie 1
	movss	xmm3, xmm1
	subss	xmm3, xmm0	;przypisanie (1 - t)

line_x:

	cvtsi2ss	xmm4, [rdi]		;konwersja x0 do floata	
	cvtsi2ss	xmm5, [rdi+4] 	;konwersja x1 do floata

	movss	xmm6, xmm4	;x = x0
	mulss	xmm6, xmm3	;x = x0 * (1 - t) 

	movss 	xmm7, xmm5	;tmp = x1
	mulss	xmm7, xmm0	;tmp = x1 * t

	addss	xmm6, xmm7	;x = x0 * (1 - t) + x1 * t 

	cvtss2si	rax, xmm6	;konwersja x do inta
	
line_y:

	cvtsi2ss	xmm4, [rsi]		;konwersja y0 do floata
	cvtsi2ss	xmm5, [rsi+4]	;konwersja y1 do floata

	movss	xmm6, xmm4	;y = y0
	mulss	xmm6, xmm3	;y = y0 * (1 - t) 

	movss 	xmm7, xmm5	;tmp = y1
	mulss	xmm7, xmm0	;tmp = y1 * t

	addss	xmm6, xmm7	;y = y0 * (1 - t) + y1 * t 

	cvtss2si	rbx, xmm6	;konwersja y do inta

draw_line:

	imul	rbx, 800	;bajty w rzędzie = y * szerokość
	add		rax, rbx	;pozycja pixela = bajty w rzedzie + x
	imul	rax, 3		;pierwszy bajt pixela = pozycja pixela * 3

	add		rax, r9 	;adres pixela

	mov		[rax], word 0
	mov		[rax+2], byte 255

next_line_points:


	addss	xmm0, xmm2	;licznik + t
	cmpss	xmm1, xmm0, 2	
	movq	rax, xmm1
	cmp		rax, 0
	je		line_loop

check_if_line_cond:

	add		rdi, 4
	add		rsi, 4
	dec 	r11
	jmp		line_cond

points:

	mov		r11, rcx
	imul	r11, 4
	sub		rdi, r11
	sub		rsi, r11

	movss	xmm0, [zero]	;licznik

	cmp		rcx, 0
	je		end	

	cmp		rcx, 1
	je		two_loop

	cmp		rcx, 2
	je		three_loop

	cmp		rcx, 3
	je		four_loop

	cmp		rcx, 4
	je		five_loop

two_loop:

	movss	xmm1, dword [one]	;przypisanie 1
	movss	xmm3, xmm1
	subss	xmm3, xmm0	;przypisanie (1 - t)

	cvtsi2ss	xmm4, [rdi]		;konwersja x0 do floata	
	cvtsi2ss	xmm5, [rdi+4] 	;konwersja x1 do floata

	movss	xmm6, xmm4	;x = x0
	mulss	xmm6, xmm3	;x = x0 * (1 - t) 

	movss 	xmm7, xmm5	;tmp = x1
	mulss	xmm7, xmm0	;tmp = x1 * t

	addss	xmm6, xmm7	;x = x0 * (1 - t) + x1 * t 

	cvtss2si	rax, xmm6	;konwersja x do inta
	
	cvtsi2ss	xmm4, [rsi]		;konwersja y0 do floata
	cvtsi2ss	xmm5, [rsi+4]	;konwersja y1 do floata

	movss	xmm6, xmm4	;y = y0
	mulss	xmm6, xmm3	;y = y0 * (1 - t) 

	movss 	xmm7, xmm5	;tmp = y1
	mulss	xmm7, xmm0	;tmp = y1 * t

	addss	xmm6, xmm7	;y = y0 * (1 - t) + y1 * t 

	cvtss2si	rbx, xmm6	;konwersja y do inta

	imul	rbx, 800	;bajty w rzędzie = y * szerokość
	add		rax, rbx	;pozycja pixela = bajty w rzedzie + x
	imul	rax, 3		;pierwszy bajt pixela = pozycja pixela * 3

	add		rax, r9 	;adres pixela

	mov		[rax], word 0
	mov		[rax+2], byte 0

	addss	xmm0, xmm2	;licznik + t
	addss	xmm0, xmm2		;licznik + t
	cmpss	xmm1, xmm0, 2	;sprawdzenie czy 1 < licznika (jeśli prawda ustaw xmm1 na 1 jeśli fałsz ustaw na 0)	
	cvtss2si	rax, xmm1	;ustaw rax na wartość xmm1
	cmp		rax, 0			;porównaj rax z 0 (jeśli prawda skocz na początek pętli)
	je		two_loop
	jmp 	end	

three_loop:

	movss	xmm1, [one]		;przypisanie 1
	movss	xmm3, xmm1
	subss	xmm3, xmm0		;przypisanie (1 - t)

	cvtsi2ss	xmm4, [rdi]		;konwersja x0 do floata
	cvtsi2ss	xmm5, [rdi+4]	;konwersja x1 do floata
	cvtsi2ss	xmm6, [rdi+8]	;konwersja x2 do floata	

	movss	xmm7, xmm4		;x = x0
	movss	xmm8, xmm3		;tmp = (1 - t)
	mulss	xmm8, xmm3		;tmp = (1 - t) ^ 2
	mulss	xmm7, xmm8		;x = x0 * (1 - t) ^ 2

	movss	xmm8, xmm3		;tmp = (1 - t)
	mulss	xmm8, [two]		;tmp = 2 * (1 - t)
	mulss	xmm8, xmm0		;tmp = 2 * (1 - t) * t
	mulss	xmm8, xmm5		;tmp = 2 * (1 - t) * t * x1
	addss	xmm7, xmm8		;x = x0 * (1 - t) ^ 2 + 2 * (1 - t) * t * x1

	movss	xmm8, xmm0		;tmp = t
	mulss	xmm8, xmm0		;tmp = t ^ 2
	mulss	xmm8, xmm6		;tmp = t ^ 2 * x2
	addss	xmm7, xmm8		;x = x0 * (1 - t) ^ 2 + 2 * (1 - t) * t * x1 + t ^ 2 * x2 

	cvtss2si	rax, xmm7

	cvtsi2ss	xmm4, [rsi]		;konwersja y0 do floata
	cvtsi2ss	xmm5, [rsi+4]	;konwersja y1 do floata
	cvtsi2ss	xmm6, [rsi+8]	;konwersja y2 do floata	

	movss	xmm7, xmm4		;y = y0
	movss	xmm8, xmm3		;tmp = (1 - t)
	mulss	xmm8, xmm3		;tmp = (1 - t) ^ 2
	mulss	xmm7, xmm8		;y = y0 * (1 - t) ^ 2

	movss	xmm8, xmm3		;tmp = (1 - t)
	mulss	xmm8, [two]		;tmp = 2 * (1 - t)
	mulss	xmm8, xmm0		;tmp = 2 * (1 - t) * t
	mulss	xmm8, xmm5		;tmp = 2 * (1 - t) * t * y1
	addss	xmm7, xmm8		;y = y0 * (1 - t) ^ 2 + 2 * (1 - t) * t * y1

	movss	xmm8, xmm0		;tmp = t
	mulss	xmm8, xmm0		;tmp = t ^ 2
	mulss	xmm8, xmm6		;tmp = t ^ 2 * y2
	addss	xmm7, xmm8		;y = y0 * (1 - t) ^ 2 + 2 * (1 - t) * t * y1 + t ^ 2 * y2 

	cvtss2si	rbx, xmm7	;konwersja y do inta
	
	imul	rbx, 800	;bajty w rzędzie = y * szerokość
	add		rax, rbx	;pozycja pixela = bajty w rzedzie + x
	imul	rax, 3		;pierwszy bajt pixela = pozycja pixela * 3

	add		rax, r9 	;adres pixela

	mov		[rax], word 0
	mov		[rax+2], byte 0	;zapis koloru


	addss	xmm0, xmm2	;licznik + t
	addss	xmm0, xmm2		;licznik + t
	cmpss	xmm1, xmm0, 2	;sprawdzenie czy 1 < licznika (jeśli prawda ustaw xmm1 na 1 jeśli fałsz ustaw na 0)	
	cvtss2si	rax, xmm1	;ustaw rax na wartość xmm1
	cmp		rax, 0			;porównaj rax z 0 (jeśli prawda skocz na początek pętli)
	je 		three_loop
	jmp		end

four_loop:

	movss	xmm1, [one]		;przypisanie 1
	movss	xmm3, xmm1
	subss	xmm3, xmm0		;przypisanie (1 - t)

	cvtsi2ss xmm4, [rdi]	;konwersja x0 do floata
	cvtsi2ss xmm5, [rdi+4]	;konwersja x1 do floata
	cvtsi2ss xmm6, [rdi+8]	;konwersja x2 do floata
	cvtsi2ss xmm7, [rdi+12]	;konwersja x3 do floata

	movss	xmm8, xmm4		;x = x0
	movss	xmm9, xmm3		;tmp = (1 - t)
	mulss	xmm9, xmm3		;tmp = (1 - t) ^ 2
	mulss	xmm9, xmm3 		;tmp = (1 - t) ^ 3
	mulss	xmm8, xmm9		;x = x0 * (1 - t) ^ 3

	movss	xmm9, xmm3		;tmp = (1 - t)
	mulss	xmm9, xmm3		;tmp = (1 - t) ^ 2
	mulss	xmm9, xmm0		;tmp = (1 - t) ^ 2 * t
	mulss	xmm9, xmm5		;tmp = (1 - t) ^ 2 * t * x1
	mulss	xmm9, [three]	;tmp = 3 * (1 - t) ^ 2 * t * x1
	addss	xmm8, xmm9		;x = x0 * (1 - t) ^ 3 + 3 * (1 - t) ^ 2 * t * x1

	movss	xmm9, xmm3		;tmp = (1 - t)
	mulss	xmm9, xmm0		;tmp = (1 - t) * t
	mulss	xmm9, xmm0		;tmp = (1 - t) * t ^ 2
	mulss	xmm9, xmm6		;tmp = (1 - t) * t ^ 2 * x2
	mulss	xmm9, [three]	;tmp = 3 * (1 - t) * t ^ 2 * x2
	addss	xmm8, xmm9		;x = x0 * (1 - t) ^ 3 + 3 * (1 - t) ^ 2 * t * x1 + 3 * (1 - t) * t ^ 2 * x2
	
	movss	xmm9, xmm0		;tmp = t
	mulss	xmm9, xmm0		;tmp = t ^ 2
	mulss	xmm9, xmm0		;tmp = t ^ 3
	mulss	xmm9, xmm7		;tmp = t ^ 3 * x3
	addss	xmm8, xmm9		;x = x0 * (1 - t) ^ 3 + 3 * (1 - t) ^ 2 * t * x1 + 3 * (1 - t) * t ^ 2 * x2 + t ^ 3 * x3

	cvtss2si rax, xmm8		;konwersja x do inta

	cvtsi2ss xmm4, [rsi]	;konwersja y0 do floata
	cvtsi2ss xmm5, [rsi+4]	;konwersja y1 do floata
	cvtsi2ss xmm6, [rsi+8]	;konwersja y2 do floata
	cvtsi2ss xmm7, [rsi+12]	;konwersja y3 do floata

	movss	xmm8, xmm4		;y = y0
	movss	xmm9, xmm3		;tmp = (1 - t)
	mulss	xmm9, xmm3		;tmp = (1 - t) ^ 2
	mulss	xmm9, xmm3 		;tmp = (1 - t) ^ 3
	mulss	xmm8, xmm9		;y = y0 * (1 - t) ^ 3

	movss	xmm9, xmm3		;tmp = (1 - t)
	mulss	xmm9, xmm3		;tmp = (1 - t) ^ 2
	mulss	xmm9, xmm0		;tmp = (1 - t) ^ 2 * t
	mulss	xmm9, xmm5		;tmp = (1 - t) ^ 2 * t * y1
	mulss	xmm9, [three]	;tmp = 3 * (1 - t) ^ 2 * t * y1
	addss	xmm8, xmm9		;y = y0 * (1 - t) ^ 3 + 3 * (1 - t) ^ 2 * t * y1

	movss	xmm9, xmm3		;tmp = (1 - t)
	mulss	xmm9, xmm0		;tmp = (1 - t) * t
	mulss	xmm9, xmm0		;tmp = (1 - t) * t ^ 2
	mulss	xmm9, xmm6		;tmp = (1 - t) * t ^ 2 * y2
	mulss	xmm9, [three]	;tmp = 3 * (1 - t) * t ^ 2 * y2
	addss	xmm8, xmm9		;y = y0 * (1 - t) ^ 3 + 3 * (1 - t) ^ 2 * t * y1 + 3 * (1 - t) * t ^ 2 * y2
	
	movss	xmm9, xmm0		;tmp = t
	mulss	xmm9, xmm0		;tmp = t ^ 2
	mulss	xmm9, xmm0		;tmp = t ^ 3
	mulss	xmm9, xmm7		;tmp = t ^ 3 * y3
	addss	xmm8, xmm9		;y = y0 * (1 - t) ^ 3 + 3 * (1 - t) ^ 2 * t * y1 + 3 * (1 - t) * t ^ 2 * y2 + t ^ 3 * y3

	cvtss2si rbx, xmm8		;konwersja y do inta

	imul	rbx, 800		;bajty w rzędzie = y * szerokość
	add		rax, rbx		;pozycja pixela = bajty w rzedzie + x
	imul	rax, 3			;pierwszy bajt pixela = pozycja pixela * 3

	add		rax, r9 		;adres pixela

	mov		[rax], word 0
	mov		[rax+2], byte 0	;zapis koloru

	addss	xmm0, xmm2		;licznik + t
	addss	xmm0, xmm2		;licznik + t
	cmpss	xmm1, xmm0, 2	;sprawdzenie czy 1 < licznika (jeśli prawda ustaw xmm1 na 1 jeśli fałsz ustaw na 0)	
	cvtss2si	rax, xmm1	;ustaw rax na wartość xmm1
	cmp		rax, 0			;porównaj rax z 0 (jeśli prawda skocz na początek pętli)
	je 		four_loop
	jmp		end

five_loop:

	movss	xmm1, [one]		;przypisanie 1
	movss	xmm3, xmm1
	subss	xmm3, xmm0		;przypisanie (1 - t)

	cvtsi2ss xmm4, [rdi]	;konwersja x0 do floata
	cvtsi2ss xmm5, [rdi+4]	;konwersja x1 do floata
	cvtsi2ss xmm6, [rdi+8]	;konwersja x2 do floata
	cvtsi2ss xmm7, [rdi+12]	;konwersja x3 do floata
	cvtsi2ss xmm8, [rdi+16]	;konwersja x4 do floata

	movss	xmm9, xmm4		;x = x0
	movss	xmm10, xmm3		;tmp = (1 - t)
	mulss	xmm10, xmm3 	;tmp = (1 - t) ^ 2
	mulss	xmm10, xmm10	;tmp = (1 - t) ^ 4
	mulss	xmm9, xmm10		;x = (1 - t) ^ 4 * x0

	movss	xmm10, xmm3		;tmp = (1 - t)
	mulss	xmm10, xmm3		;tmp = (1 - t) ^ 2
	mulss	xmm10, xmm3		;tmp = (1 - t) ^ 3
	mulss	xmm10, xmm0		;tmp = (1 - t) ^ 3 * t
	mulss	xmm10, xmm5		;tmp = (1 - t) ^ 3 * t * x1
	mulss	xmm10, [four]	;tmp = 4 * (1 - t) ^ 3 * t * x1
	addss	xmm9, xmm10		;x = (1 - t) ^ 4 * x0 + 4 * (1 - t) ^ 3 * t * x1

	movss	xmm10, xmm3		;tmp = (1 - t)
	mulss	xmm10, xmm3		;tmp = (1 - t) ^ 2
	mulss	xmm10, xmm0		;tmp = (1 - t) ^ 2 * t
	mulss	xmm10, xmm0		;tmp = (1 - t) ^ 2 * t ^ 2
	mulss	xmm10, xmm6		;tmp = (1 - t) ^ 2 * t ^ 2 * x2
	mulss	xmm10, [six]	;tmp = 6 * (1 - t) ^ 2 * t ^ 2 * x2
	addss	xmm9, xmm10		;x = (1 - t) ^ 4 * x0 + 4 * (1 - t) ^ 3 * t * x1 + 6 * (1 - t) ^ 2 * t ^ 2 * x2

	movss	xmm10, xmm3		;tmp = (1 - t)
	mulss	xmm10, xmm0		;tmp = (1 - t) * t
	mulss	xmm10, xmm0		;tmp = (1 - t) * t ^ 2
	mulss	xmm10, xmm0		;tmp = (1 - t) * t ^ 3
	mulss	xmm10, xmm7		;tmp = (1 - t) * t ^ 3 * x3
	mulss	xmm10, [four]	;tmp = 4 * (1 - t) * t ^ 3 * x3
	addss	xmm9, xmm10		;x = (1 - t) ^ 4 * x0 + 4 * (1 - t) ^ 3 * t * x1 + 6 * (1 - t) ^ 2 * t ^ 2 * x2 + 4 * (1 - t) * t ^ 3 * x3

	movss	xmm10, xmm0		;tmp = t
	mulss	xmm10, xmm0		;tmp = t ^ 2
	mulss	xmm10, xmm10	;tmp = t ^ 4
	mulss	xmm10, xmm8		;tmp = t ^ 4 * x4
	addss	xmm9, xmm10		;x = (1 - t) ^ 4 * x0 + 4 * (1 - t) ^ 3 * t * x1 + 6 * (1 - t) ^ 2 * t ^ 2 * x2 + 4 * (1 - t) * t ^ 3 * x3 + t ^ 4 * x4

	cvtss2si	rax, xmm9	;konwersja x do inta

	cvtsi2ss xmm4, [rsi]	;konwersja y0 do floata
	cvtsi2ss xmm5, [rsi+4]	;konwersja y1 do floata
	cvtsi2ss xmm6, [rsi+8]	;konwersja y2 do floata
	cvtsi2ss xmm7, [rsi+12]	;konwersja y3 do floata
	cvtsi2ss xmm8, [rsi+16]	;konwersja y4 do floata

	movss	xmm9, xmm4		;y = y0
	movss	xmm10, xmm3		;tmp = (1 - t)
	mulss	xmm10, xmm3 	;tmp = (1 - t) ^ 2
	mulss	xmm10, xmm10	;tmp = (1 - t) ^ 4
	mulss	xmm9, xmm10		;y = (1 - t) ^ 4 * y0

	movss	xmm10, xmm3		;tmp = (1 - t)
	mulss	xmm10, xmm3		;tmp = (1 - t) ^ 2
	mulss	xmm10, xmm3		;tmp = (1 - t) ^ 3
	mulss	xmm10, xmm0		;tmp = (1 - t) ^ 3 * t
	mulss	xmm10, xmm5		;tmp = (1 - t) ^ 3 * t * y1
	mulss	xmm10, [four]	;tmp = 4 * (1 - t) ^ 3 * t * y1
	addss	xmm9, xmm10		;y = (1 - t) ^ 4 * y0 + 4 * (1 - t) ^ 3 * t * y1

	movss	xmm10, xmm3		;tmp = (1 - t)
	mulss	xmm10, xmm3		;tmp = (1 - t) ^ 2
	mulss	xmm10, xmm0		;tmp = (1 - t) ^ 2 * t
	mulss	xmm10, xmm0		;tmp = (1 - t) ^ 2 * t ^ 2
	mulss	xmm10, xmm6		;tmp = (1 - t) ^ 2 * t ^ 2 * y2
	mulss	xmm10, [six]	;tmp = 6 * (1 - t) ^ 2 * t ^ 2 * y2
	addss	xmm9, xmm10		;y = (1 - t) ^ 4 * y0 + 4 * (1 - t) ^ 3 * t * y1 + 6 * (1 - t) ^ 2 * t ^ 2 * y2

	movss	xmm10, xmm3		;tmp = (1 - t)
	mulss	xmm10, xmm0		;tmp = (1 - t) * t
	mulss	xmm10, xmm0		;tmp = (1 - t) * t ^ 2
	mulss	xmm10, xmm0		;tmp = (1 - t) * t ^ 3
	mulss	xmm10, xmm7		;tmp = (1 - t) * t ^ 3 * y3
	mulss	xmm10, [four]	;tmp = 4 * (1 - t) * t ^ 3 * y3
	addss	xmm9, xmm10		;y = (1 - t) ^ 4 * y0 + 4 * (1 - t) ^ 3 * t * y1 + 6 * (1 - t) ^ 2 * t ^ 2 * y2 + 4 * (1 - t) * t ^ 3 * y3

	movss	xmm10, xmm0		;tmp = t
	mulss	xmm10, xmm0		;tmp = t ^ 2
	mulss	xmm10, xmm10	;tmp = t ^ 4
	mulss	xmm10, xmm8		;tmp = t ^ 4 * y4
	addss	xmm9, xmm10		;y = (1 - t) ^ 4 * y0 + 4 * (1 - t) ^ 3 * t * y1 + 6 * (1 - t) ^ 2 * t ^ 2 * y2 + 4 * (1 - t) * t ^ 3 * y3 + t ^ 4 * y4

	cvtss2si	rbx, xmm9	;konwersja y do inta

	imul	rbx, 800	;bajty w rzędzie = y * szerokość
	add		rax, rbx	;pozycja pixela = bajty w rzedzie + x
	imul	rax, 3		;pierwszy bajt pixela = pozycja pixela * 3

	add		rax, r9 	;adres pixela

	mov		[rax], word 0
	mov		[rax+2], byte 0	;zapis koloru

	addss	xmm0, xmm2		;licznik + t
	cmpss	xmm1, xmm0, 2	;sprawdzenie czy 1 < licznika (jeśli prawda ustaw xmm1 na 1 jeśli fałsz ustaw na 0)	
	cvtss2si	rax, xmm1	;ustaw rax na wartość xmm1
	cmp		rax, 0			;porównaj rax z 0 (jeśli prawda skocz na początek pętli)
	je		five_loop	

end:
	mov		rsp, rbp
	pop		rbp
	ret