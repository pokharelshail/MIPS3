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
