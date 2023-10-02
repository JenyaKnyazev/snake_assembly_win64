option casemap:none
WriteConsoleA proto
Sleep proto
SetConsoleCursorPosition proto
ExitProcess proto
GetKeyState proto
GetStdHandle proto
GetTickCount proto
.data
	snake_head DB 'S',0
	snake_body DB 'o',0
	space_string DB ' ',0
	food_string DB 'F',0
	handle_output QWORD ?
	chars_written QWORD ?
	XY QWORD 30 DUP(0)
	index_XY QWORD 32
	direction DB 0
	FOOD QWORD ?
	new_cell_snake QWORD ?
	cell_to_remove QWORD ?
	is_touch_food DB 0
.code
	main proc
		mov rcx, -11
		call GetStdHandle
		mov handle_output,rax
		mov rcx,handle_output
		call play
		mov rcx,0
		call ExitProcess
	main endp

	print_snake proc
		pop r14
		mov rsi,offset XY
		mov r15,index_XY
		sub r15,8
		add rsi,r15
		mov rdx,[rsi]
		mov rcx,handle_output
		call SetConsoleCursorPosition
		mov rcx,handle_output
		mov rdx,offset snake_head
		mov r8,1
		mov r9,offset chars_written
		push 0h
		call WriteConsoleA
		pop rcx
		cmp r15,0
		je end_print_snake
		run_print_snake:
			sub r15,8
			sub rsi,8
			mov rcx,handle_output
			mov rdx,[rsi]
			call SetConsoleCursorPosition
			mov rcx,handle_output
			mov rdx,offset snake_body
			mov r8,1
			mov r9,offset chars_written
			push 0h
			call WriteConsoleA
			pop rcx
			xor r15,0
			jnz run_print_snake
		end_print_snake:
		push r14
		ret
	print_snake endp
		
	init_cell_snake proc
		mov rsi,offset XY
		add rsi,index_XY
		sub rsi,8
		mov rdx,[rsi]
		mov r11,rdx
		mov rbx,rdx
		mov cl,16
		and r11,0FFH
		shr rbx,cl
		cmp direction,0
		je right_cell_init
		cmp direction,1
		je down_cell_init
		cmp direction,2
		je left_cell_init
		dec rbx
		jmp end_move_snake
		right_cell_init:
		inc r11
		jmp end_move_snake
		down_cell_init:
		inc rbx
		jmp end_move_snake
		left_cell_init:
		dec r11
		end_move_snake:
		cmp rbx,0
		jge next_cell_init
		mov rbx,25
		next_cell_init:
		cmp rbx,25
		jle next_cell_init2
		mov rbx,0
		next_cell_init2:
		cmp r11,0
		jge next_cell_init3
		mov r11,50
		next_cell_init3:
		cmp r11,50
		jle next_cell_init4
		mov r11,0
		next_cell_init4:
		mov cl,16
		shl rbx,cl
		or rbx,r11
		mov new_cell_snake,rbx
		ret
	init_cell_snake endp

	calc_snake proc
		call indicate_touching_food
		mov al,is_touch_food
		cmp al,1
		je calc_snake_p1
		mov rsi,offset XY
		mov rdi,offset XY
		add rdi,8
		mov rdx,[rsi]
		mov cell_to_remove,rdx
		mov rbx,8
		cmp rbx,index_XY
		je skip_loop
		run_calc_snake:
			mov rdx,[rdi]
			mov [rsi],rdx
			add rsi,8
			add rdi,8
			add rbx,8
			cmp rbx,index_XY
			jne run_calc_snake
		skip_loop:
		mov rdx,new_cell_snake
		mov [rsi],rdx
		jmp end_calc_snake
		calc_snake_p1:
		mov rsi,offset XY
		add rsi,index_XY
		mov rdx,new_cell_snake
		mov [rsi],rdx
		add index_XY,8
		end_calc_snake:
		ret
	calc_snake endp

	indicate_touching_food proc
		call init_cell_snake
		mov is_touch_food,0
		mov rdx,new_cell_snake
		cmp rdx,FOOD
		jne end_indicate
		mov is_touch_food,1
		call generate_food
		end_indicate:
		ret
	indicate_touching_food endp

	remove_cell proc
		pop r14
		cmp is_touch_food,1
		je end_remove_cell
		mov rdx,cell_to_remove
		mov rcx,handle_output
		call SetConsoleCursorPosition
		mov rcx,handle_output
		mov rdx,offset space_string
		mov r8,1
		mov r9,offset chars_written
		push 0h
		call WriteConsoleA
		end_remove_cell:
		pop rcx
		push r14
		ret
	remove_cell endp

	user_press_keys proc
		pop r14
		mov rcx,0
		mov cl,'1'
		call GetKeyState
		and ax,8000H
		jnz left_press
		mov rcx,0
		mov cl,'2'
		call GetKeyState
		and ax,8000H
		jnz right_press
		jmp end_user_press
		right_press:
		mov rcx,150
		call Sleep
		mov rcx,0
		mov cl,'2'
		call GetKeyState
		and ax,8000H
		jnz end_user_press
		inc direction
		jmp check_dir
		left_press:
		mov rcx,150
		call Sleep
		mov rcx,0
		mov cl,'1'
		call GetKeyState
		and ax,8000H
		jnz end_user_press
		dec direction
		check_dir:
		cmp direction,0
		jl dir_neg
		cmp direction,4
		je dir_too_much
		jmp end_user_press
		dir_too_much:
		mov direction,0
		jmp end_user_press
		dir_neg:
		mov direction,3
		end_user_press:
		push r14
		ret
	user_press_keys endp

	generate_food proc
		pop r15
		call GetTickCount
		mov rdx,0
		mov rbx,50
		div rbx
		mov r13,rdx
		mov rdx,0
		call GetTickCount
		mov rbx,25
		div rbx
		mov r14,rdx
		mov cl,16
		shl r14,cl
		or r14,r13
		mov FOOD,r14
		mov rdx,FOOD
		mov rcx,handle_output
		call SetConsoleCursorPosition
		mov rcx,handle_output
		mov rdx,offset food_string
		mov r8,1
		mov r9,offset chars_written
		push 0h
		call WriteConsoleA
		pop rcx
		push r15
		ret
	generate_food endp

	play proc
		pop r15
		call generate_food
		run_play:
			call user_press_keys
			call calc_snake
			call print_snake
			call remove_cell
			mov rcx,150
			call Sleep
			cmp index_XY,240
			jne run_play
		push r15
		ret
	play endp
end
