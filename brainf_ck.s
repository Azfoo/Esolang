.data
	# file buffer
	filebuffer: .skip	1000000
	# character buffer
	charbuffer:	.skip 	1
	# data tape
	tape:		.skip	1000000
	# variable to hold length of active filebuffer
	jump_count:	.quad 	0
	# errors message
	message:	.asciz	"Invalid File"
.text
	fileformat: .asciz	"r"
	Formatstr:	.asciz 	"%s\n"     # normal string format
	decimal:	.asciz	"%ld\n"
	chrtr:		.asciz	" %c"
	ch:			.asciz  "%c"
.global main # implementation of the main

main:							# the program starts here
	pushq	%rbp				# Prologue: push old base pointer
	movq	%rsp, %rbp 			# Copy stack pointer to base pointer

 	                            # argv[1] == Memory[stack_ptr[24] + 8]
	movq	24(%rsp), %rsi      # load stack_ptr[24]
	movq	8(%rsi), %rsi       # load Memory[stack_ptr[24]+8]
	movq	%rsi, %rdi	    	# store in the filename variable
	movq    $0, %rax

	call 	file_error          # if a file without .b extension entered the program exits

	movq	$filebuffer, %rsi   # read the file
	call 	ReadFile

	movq    $filebuffer, %rdi   # interpret the file buffer
	call    interpret

	jmp		End 				# Go to end of the program

ReadFile: 						# ReadFile(char* filename, char* filebuffer)
								# functions reads the file, skip comments, store the relavent data to filebuffer
	pushq	%rbp				# Prologue: push old base pointer
	movq	%rsp, %rbp 			# Copy stack pointer to base pointer
	pushq	%rcx				# function uses this reg so save it first
	pushq	%rdx                # function uses this reg so save it first
	pushq   %rbx

	movq	$0, %rax
	movq	$fileformat, %rsi 	# file opened in read format
	call    fopen				# file pointer in %rax
	movq	%rax, %rbx          # file pointer move to %rbx

	pushq 	%rdi

	movq 	$filebuffer, %r12   # file buffer pointer
	movq	$0, %r13			# file buffer address counter
read_loop:
	movq	$0, %rax            # clear %rax
	movq	$charbuffer, %rdi   # character to be read in %rdi
	movq	$1, %rsi            # read data chunk size 1
	movq	$1, %rdx            # read chunk size 1
	movq	%rbx, %rcx			# file pointer
	call 	fread
	movb	charbuffer, %dil

	cmp		$0,	%rax            # break the loop on EOF
	je		loop_break

	call 	char_valid			# identify charcater
	cmp		$0, %rax			# if comments skip it
	je 		skip
	
	movb	%al, (%r12,%r13,1)  # store in file buffer
	incq	%r13				# increment address counter
skip:
	jmp		read_loop			# loop until EOF

loop_break:
	popq	%rdi

	movq	$0, %rax
	movq	%rbx, %rdi 			# file pointer
	call 	fclose

	popq	%rbx
	popq 	%rdx                # restore
	popq	%rcx                # restore
	movq 	%rbp, %rsp 		    # Epilogue: clear local vars from stack
	popq 	%rbp			    # Restore caller's base pointer
	ret

char_valid:						# char_valid(char c) 
								# return (1: >)(2: <)(3: +)(4: -)(5: .)(6: ,)(7: [)(8: ])(0: else)
	pushq	%rbp				# Prologue: push old base pointer
	movq	%rsp, %rbp 			# Copy stack pointer to base pointer
	pushq	%rcx				# function uses this reg so save it first
	pushq	%rdx                # function uses this reg so save it first
	pushq   %rbx

								# switch(input character)
	cmp		$'>, %dil           # case(>)
	je 		char_1

	cmp		$'<, %dil 			# case(<)
	je 		char_2

	cmp	    $'+, %dil 			# case(+)
	je 		char_3

	cmp 	$'-, %dil 			# case(-)
	je 		char_4

	cmp		$'., %dil 			# case(.)
	je 		char_5

	cmp 	$',, %dil 			# case(,)
	je 		char_6

	cmp 	$'[, %dil 			# case([)
	je 		char_7

	cmp 	$'], %dil 			# case(])
	je 		char_8

	movq	$0, %rax            # default return 0
	jmp 	quit

char_1:							# case(1)
	movq	$1, %rax			# return 1
	jmp 	quit
char_2:
	movq	$2, %rax            # case(2)
	jmp 	quit                # return 2
char_3:
	movq	$3, %rax            # case(3)
	jmp 	quit				# return 3
char_4:
	movq	$4, %rax            # case(4)
	jmp 	quit				# return 4
char_5:
	movq	$5, %rax            # case(5)
	jmp 	quit				# return 5
char_6:
	movq	$6, %rax            # case(6)
	jmp 	quit				# return 6
char_7:
	movq	$7, %rax            # case(7)
	jmp 	quit				# return 7
char_8:
	movq	$8, %rax            # case(8)
	jmp 	quit				# return 8

quit:
	popq	%rbx
	popq 	%rdx                # restore
	popq	%rcx                # restore
	movq 	%rbp, %rsp 		    # Epilogue: clear local vars from stack
	popq 	%rbp			    # Restore caller's base pointer
	ret

interpret:                      # interpret(char* filebuffer)
	pushq	%rbp				# Prologue: push old base pointer
	movq	%rsp, %rbp 			# Copy stack pointer to base pointer
	pushq	%rcx				# function uses this reg so save it first
	pushq	%rdx                # function uses this reg so save it first
	pushq   %rbx	

	
	movq	$tape, %rsi 		# data stream or tape

interpretor_loop:
	movzb	(%rdi), %rdx


								# switch(input character)
	cmp		$1, %dl             # case(>)
	je 		case_1

	cmp		$2, %dl 			# case(<)
	je 		case_2

	cmp	    $3, %dl 			# case(+)
	je 		case_3

	cmp 	$4, %dl 			# case(-)
	je 		case_4

	cmp		$5, %dl 			# case(.)
	je 		case_5

	cmp 	$6, %dl 			# case(,)
	je 		case_6

	cmp 	$7, %dl 			# case([)
	je 		case_7

	cmp 	$8, %dl 			# case(])
	je 		case_8

	movq	$0, %rax            # default return 0
	jmp 	break

case_1:	
	cmp		$0, jump_count		# if loop instruction has counter = zero ignore instructions in loop 
	jne		break				
	incq	%rsi	    		# case 1 -> increment tape pointer
	jmp 	break
case_2:
	cmp		$0, jump_count      # if loop instruction has counter = zero ignore instructions in loop 
	jne		break
	decq	%rsi                # case 2 -> decrement tape pointer
	jmp 	break               
case_3:
	cmp		$0, jump_count      # if loop instruction has counter = zero ignore instructions in loop 
	jne		break
	movzb	(%rsi), %rbx
	incq	%rbx
	movb    %bl, (%rsi)			# case 3 -> increment value at the tape pointer
	jmp 	break				
case_4:
	cmp		$0, jump_count      # if loop instruction has counter = zero ignore instructions in loop 
	jne		break
	movzb	(%rsi), %rbx
	decq	%rbx
	movb    %bl, (%rsi)			# case 4 -> decrement value at the tape pointer
	jmp 	break				
case_5:
	cmp		$0, jump_count		# if loop instruction has counter = zero ignore instructions in loop 
	jne		break
	pushq	%rax				
	pushq	%rdi
	pushq 	%rsi
	movq	$0, %rax
	movq	$ch, %rdi 			# print the value at the tape pointer
	movzb	(%rsi), %rsi
	call    printf
	popq	%rsi
	popq	%rdi
	popq	%rax    	       
	jmp 	break				
case_6:
	cmp		$0, jump_count		# if loop instruction has counter = zero ignore instructions in loop 
	jne		break
	pushq	%rdi
	call 	getchar 			# scan the character from stdin and store at tape pointer
	movb 	%al,(%rsi)
	popq	%rdi
	jmp 	break				
case_7:
	cmpb	$0, (%rsi) 			# If the value under tape pointer is zero
	jne 	flow1
	addq	$1, jump_count      # increment the jump count
	jmp 	break
	flow1:
	pushq	%rdi 				# else push the address on stack
	jmp 	break				
case_8:
	cmp		$0, jump_count      # if jump count is non zero
	je		flow2
	subq	$1, jump_count 		# decrement it
	jmp 	break
	flow2:
	movzb   (%rsi),%rax         # else pop back the address
	popq 	%rbx
	cmp     $0,%rax            
	je 		break
	movq    %rbx,%rdi
	subq    $1,%rdi		

break:
	
	incq	%rdi	
	movzb	(%rdi),%rax
	cmp 	$0, %rax
	jne 	interpretor_loop

	popq	%rbx
	popq 	%rdx                # restore
	popq	%rcx                # restore
	movq 	%rbp, %rsp 		    # Epilogue: clear local vars from stack
	popq 	%rbp			    # Restore caller's base pointer
	ret 

file_error:                     # file_error(char* filenmae)
	pushq	%rbp				# Prologue: push old base pointer
	movq	%rsp, %rbp 			# Copy stack pointer to base pointer
	pushq	%rcx				# Save %rcx on stack
	pushq	%rax
	call 	Strlen	 			# %rax has the length of filename string
	cmp 	$0, %rax			# check if string length is zero
	je 		fail
	decq	%rax				# decrement length for index of last character
	cmpb	$'b, (%rdi,%rax,1)  # cmpare if last character is 'b'
	jne		fail
	decq	%rax
	cmpb	$'., (%rdi,%rax,1)	# compare if second last character is a dot
	jne		fail

	popq	%rax
	popq	%rcx				# Restore %rcx
	movq 	%rbp, %rsp 		    # Epilogue: clear local vars from stack
	popq 	%rbp			    # Restore caller's base pointer
	ret 
fail:
	movq	$0, %rax
	movq	$Formatstr, %rdi
	movq	$message, %rsi
	call    printf
	popq	%rax
	popq	%rcx				# Restore %rcx
	movq 	%rbp, %rsp 		    # Epilogue: clear local vars from stack
	popq 	%rbp			    # Restore caller's base pointer
	movq 	%rbp, %rsp 		    # Epilogue: clear local vars from stack
	popq 	%rbp			    # Restore caller's base pointer
	movq	$0, %rdi 			
	call	exit 

Strlen:							# Strlen(char* str) return length of string
	pushq	%rbp				# Prologue: push old base pointer
	movq	%rsp, %rbp 			# Copy stack pointer to base pointer
	pushq	%rcx				# Save %rcx on stack

	movq	$-1, %rcx			# initialize counter to -1 	
Loop1:
	inc 	%rcx				# increment counter
	cmpb	$0,(%rdi,%rcx,1)	# compare zero with memory location [%rdi + (%rcx * 1)] i.e string
	jne		Loop1 				# loop until null character found

	movq	%rcx, %rax          # store the result in output register (%rax)

	popq	%rcx				# Restore %rcx
	movq 	%rbp, %rsp 		    # Epilogue: clear local vars from stack
	popq 	%rbp			    # Restore caller's base pointer
	ret 


End:							# Label ran when the program should end
	movq 	%rbp, %rsp 		    # Epilogue: clear local vars from stack
	popq 	%rbp			    # Restore caller's base pointer
	movq	$0, %rdi 			
	call	exit 				# Exit the program
