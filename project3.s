.data
    reply: .space 1000			#Space for 1000 characters has been allocated, and the main program has been started.
    not_valid: .asciiz "NaN"
.text
         main:
	    li $v0, 8			#Taking the user input for strings
            la $a0, reply
            li $a1, 1001
            syscall
					#Loading the input to a regsiter for conversion to decimal
            la $s0, reply
            li $s1, 0 			#start pointer to make sure that we collect only 4 characters and a comma.
            li $s2, 0			#end pointer to make sure what characters we have collected and read.
	list:
	    la $s1, ($s2)		#content of s2 has been passed as data of s1 to make sure iterate through the string, from start pointer to end pointer.
	substring:
	    add $t1, $s0, $s2 	        #iterator taking the pointers sum
            lb $t2, 0($t1) 		#loading the current character
	    beq $t2, 0, end_of_substring #a few criteron to exit the loop while iterating through the substrings
            beq $t2, 10, end_of_substring
            beq $t2, 44, end_of_substring
 	    add $s2, $s2, 1     #Increasing the count of the iterator pointer so that we move through the string.
            j substring
	end_of_substring:	#now we reach at the end of substring, it will contain subprogram calls and stack operation.      			
            la $a0, ($s1)	#loading arguments to make a subprogram_B call
            la $a1, ($s2)

            			#calling subprogram_A after passing the contents from a0 and a1
            jal subprogram_A
	    jal subprogram_B

            			#the return values of the subprogram_B stays in the stack which is used by the subprogram_B

            			#ending the strings with end character and newline character
            beq $t2, 0, end_wl
            beq $t2, 10, end_wl

            addi $s2, $s2, 1 	#incrementing the iterator
	    li $v0, 11		#formatting the print values returned from subprogram C with comma and ending the program
            li $a0, 44
            syscall
            j list
	     end_wl:
        			#This following set of lines is to end the program after calling all the subprograms.
            li $v0, 10
            syscall
	    subprogram_A:
            la $s7, ($ra)	#loading the value from $ra to register $s7
            la $t9, ($a0)	#loading the value from $a0 to register $t9

            addi $t8, $a1, 0 	#storing the end address
            la $t7, reply  	#loading the first address of the user input
  	    space_front:
                beq $t9, $t8, end_deletion  #This will check for the empty substrings or exit the loop after spotting one.
                add $t6, $t7, $t9
                lb $t5, ($t6)		    #loading the first word from the substring
		beq $t5, 32, add_for_loop  #checks for loop continuation
                beq $t5, 9, add_for_loop
                j back #Checking the space at back
	   add_for_loop:	#code for iterating through the string
                addi $t9, $t9, 1
                j space_front
	    back:		#checking if there is space at the back of the string
                beq $t9, $t8, end_deletion #if ends meet the begining, we end the process
                add $t6, $t7, $t8
                addi $t6, $t6, -1
                lb $t5, ($t6)
 		beq $t5, 32, down #moving down the list and moving through each word until 4*8 characters are processed
                beq $t5, 9, down
                j end_deletion
            down:
                addi $t8, $t8, -1
                j back
	   end_deletion:
                beq $t9, $t8, not_a_number #When the string is empty , then print NaN
                li $t4, 0
                li $s6, 0 				  #checks length of the string
  	   convert:
                beq $t9, $t8, end_convert #here using the subprogram, converting the characters using subprogramC and returned in $v0 and $v1
                add $t6, $t7, $t9
                lb $t5, ($t6)
                la $a0, ($t5)
	        jal sub_programC	#will check if the number is valid in our base system and then converts using subprogram.
                bne $v0, 0, continue
                j not_a_number
 	   continue:             #converting the string  to decimal             
                mul $t4, $t4, 35  #Multiplying by 35 as I have the base 35
                sub $t6, $t5, $v1
                add $t4, $t4, $t6
                addi $s6, $s6, 1	#incrementing s6 after processing each character
		addi $t9, $t9, 1	#incrementing character count after processing each character
                j convert
	   end_convert:
                bgt $s6, 4, large_num	#if length of a valid string is greater than 4, then it's TOO large to deal with
                li $v0, 1
                j end_string
	   large_num:
                                       #Printing NaN for string larger than 4 characters
                li $v0, 0
                la $t4, not_valid
                j end_string
 	   not_a_number:
           			       #throwing a message for invalid character
                li $v0, 0
                la $t4, not_valid
	   end_string:
            #loading the stack with return values
                addi $sp, $sp, -4
                sw $t4, ($sp)
                addi $sp, $sp, -4
	        sw $v0, ($sp)
                la $ra, ($s7)
                jr $ra
	  sub_programC:
   				blt $a0, 48, invalid 	#invaild if ascii value is less than 48, ascii value of 0 is 48
   				addi $v1, $0, 48 	#storing the ascii value to $v1
   				blt $a0, 58, valid 	#Value 0-9 is valid
							#this will check the valid characters
   				blt $a0, 65, invalid #invalid if the character is less than "A" in the ascii table
   				addi $v1, $0, 55
   				ble $a0, 89, valid #The last valid character is Y
   				blt $a0, 97, invalid
				addi $v1, $0, 87
				ble $a0, 121, valid #The last valid character is y
				bgt $a0, 121, invalid #invalid if ascii character is greater than 'y'


			valid:			
           			li $v0, 1  #loading the number for valid and invalid
   				jr $ra
   			invalid:
   				li $v0, 0
   				jr $ra
	
	subprogram_B:					#Will check overflow and process each substring
   		        	lw $t8, ($sp)  #loading the arguments from the stack
	   			addi $sp, $sp, 4
	   			lw $t7, ($sp)
	   			beq $t8, 0, not_okay #if $t8 equals 0, the string is not valid
				li $t6, 10	#unsigned division by 10 to avoid overflow
   				divu $t7, $t6
   				li $v0, 1
   				mflo $a0
   				beq $a0, 0, overflow_flag #not ready to print
   				syscall
	
	
        overflow_flag:					#changing the value of a0 to specify it not being ready to print
   				mfhi $a0
   				syscall
   				j exit

	not_okay:
   		#block of code for invalid string
   			li $v0, 4
   			la $a0, ($t7)
   			syscall
	exit:
		jr $ra



