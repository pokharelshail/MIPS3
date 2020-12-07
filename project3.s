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
	    subprogram_B:
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

    

