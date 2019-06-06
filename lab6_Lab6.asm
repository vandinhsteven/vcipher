# Steven Van Dinh
# svandinh
# 1593184
# lab 6: vigenere cipher
.text
	EncryptChar:
		#ASSUME A0 IS OUR PLAINTEXT CHARACTER
		#ASSUME A1 IS OUR KEY ASCII CHARACTER
		#WE WANT CIPHERED CHARACTER INTO V0
		move	 $t5, $s0	 #to store whatever was in $s before subroutine call
		move	 $t6, $s1	 #to store whatever was in $s before subroutine call
		move	 $t7, $s2	 #to store whatever was in $s before subroutine call
		move	 $t8, $s3	 #to store whatever was in $s before subroutine call
		
		move	 $s0, $a0	 #s0 will have plaintext character
		
		#if character is not in alphabet, just return it without ciphering 
		blt	 $s0, 65, __dontCipher #if char is less than A
		bgt	 $s0, 122, __dontCipher #if char is greater than z
		blt	 $s0, 97, __checkAgain #if char is less than a, check if it is also greater than Z
		j	 __cipher
		__checkAgain:
			bgt	 $s0, 90, __dontCipher
			
		__cipher:
		###############################
		move	 $s1, $a1	#s1 will have key ASCII character
		
		bgt	 $s0, 96, __lowercase_cipher	 #if plaintext character is greater than 96, that means it is lowercase
		##############################
		subi	 $s2, $s1, 65			#this will be the amount we will add to the plaintext
		add	 $s3, $s0, $s2
		bgt	 $s3, 90, __looparound		#s3 is now our ciphered character
		##############################
		move	 $v0, $s3			#we want v0 to be our ciphered character
		move	 $s0, $t5			#moving whatever was in s0 before the function call back into s0
		move	 $s1, $t6
		move	 $s2, $t7
		move	 $s3, $t8
		j	 __endEncrypt
		#############################
		__looparound:
			add	 $s3, $s2, 64
			move	 $v0, $s3		#s3 will have the CIPHER CHAR, move it to v0 to return
			move	 $s0, $t5		#moving whatever was in s0 before the function call back into s0
			move	 $s1, $t6
			move	 $s2, $t7
			move	 $s3, $t8
			j	 __endEncrypt
		#############################	
		__lowercase_cipher:
			subi	 $s2, $s1, 65	 
			add	 $s3, $s0, $s2
			bgt	 $s3, 122, __looparound2
			
			move	 $v0, $s3		#s3 will have the CIPHER CHAR, move it to v0 to return
			move	 $s0, $t5		#moving whatever was in s0 before the function call back into s0
			move	 $s1, $t6
			move	 $s2, $t7
			move	 $s3, $t8
			j	 __endEncrypt
		#############################	
		__looparound2:
			add	 $s3, $s2, 96
			move	 $v0, $s3		#s3 will have the CIPHER CHAR, move it to v0 to return
			move	 $s0, $t5		#moving whatever was in s0 before the function call back into s0
			move	 $s1, $t6
			move	 $s2, $t7
			move	 $s3, $t8
			j	__endEncrypt
		#############################	
		__dontCipher:
			move	 $v0, $s0	
			j	 __endEncrypt
		__endEncrypt:
			jr	 $ra			#it should return v0 which is our ciphered character
#####################################################################################################
	EncryptString:
		#ASSUME A0 IS OUR PLAINTEXT STRING
		#ASSUME A1 IS OUR KEY ASCII STRING
		#WE WANT CIPHERED STRING STORED IN A2
		move	 $t0, $a0	#t0 has our whole plaintext string
		move	 $t1, $a1	#t1 has our whole KEY string
		move	 $t6, $s1	#storing whatever was in s1 before subroutine call
		move	 $s1, $a1	#copy of key string into s1
		addi	 $sp, $sp, -4
		sw	 $ra, 0 ($sp)
		li	 $t2, 0


		__ESloop:
			beqz	 $a0, __end_loop_string
			beqz	 $v0, __end_loop_string
			
			lb	 $a0, 0($t0)	#loading plaintext character into a0
			lb	 $a1, 0($t1)	#loading key character into a1
			
			#if key hits null, loop back to beginning of key
			beqz	 $a1, firstKey
			j	 __inner
			firstKey:
				 move	 $t1, $s1	#reseting t1 to s1 which is the original a1
				 lb	 $a1, 0($t1)
				 j	 __inner
			__inner:
			jal	 EncryptChar
			sb	 $v0, 0($a2)
			addi	 $a2, $a2, 1 #store character and increment next store location
			addi	 $t0, $t0, 1 #point to next text character
			addi	 $t1, $t1, 1 #point to next key character
			addi	 $t2, $t2, 1 #to make sure we don't go over 30 characters
			beq	 $t2, 30, __end_loop_string
			j	 __ESloop
		
				
		__end_loop_string:		
			move	 $v0, $a2	#moving a2 into v0 for return call
			move	 $s1, $t6	#moving whatever was in s1 before subroutine back into s1
			lw	 $ra, 0($sp)	
			addi	 $sp, $sp, 4	#popping ra off stack
			jr	 $ra		#it should return a2 which is our ciphered string
########################################################################################################
	DecryptChar:
		#ASSUME A0 IS PLAINTEXT TO DECRYPT
		#ASSUME A1 IS KEY CHAR
		#V0 WILL BE THE DECIPHERED CHARACTER
		move	 $t5, $s0	 #to store whatever was in $s before subroutine call
		move	 $t6, $s1	 #to store whatever was in $s before subroutine call
		move	 $t7, $s2	 #to store whatever was in $s before subroutine call
		move	 $t8, $s3	 #to store whatever was in $s before subroutine call
		
		
		move	 $s0, $a0	 #s0 will have our character to decipher
		blt	 $s0, 65, __dontCipherDE	#check if charcter is not in the alphabet, if its not, skip the cipher
		bgt	 $s0, 122, __dontCipherDE	#check if charcter is not in the alphabet, if its not, skip the cipher
		blt	 $s0, 97, __checkAgainDE	#check if charcter is not in the alphabet, if its not, skip the cipher
		j	 __cipherDE
		__checkAgainDE:
			bgt	 $s0, 90, __dontCipherDE
			
		__cipherDE:
		
		
		move	 $s1, $a1	 #s1 will have our key character
		bgt	 $s0, 96, __lowercase_decipher	 #if plaintext character is greater than 96, that means it is lowercase
		##############################
		subi	 $s2, $s1, 65
		sub	 $s3, $s0, $s2
		blt	 $s3, 65, __looparoundDE		#s3 is now our ciphered character
		##############################
		move	 $v0, $s3			#we want v0 to be our ciphered character
		move	 $s0, $t5		#moving whatever was in s0 before the function call back into s0
		move	 $s1, $t6
		move	 $s2, $t7
		move	 $s3, $t8
		j	 __enddecrypt
		#############################
		__looparoundDE:
			li	 $s4, 91
			sub	 $s3, $s4, $s2
			move	 $v0, $s3		#s3 will have the CIPHER CHAR, move it to v0 to return
			move	 $s0, $t5		#moving whatever was in s0 before the function call back into s0
			move	 $s1, $t6		#moving whatever was in s1 before the function call back into s1
			move	 $s2, $t7		#moving whatever was in s2 before the function call back into s2
			move	 $s3, $t8		#moving whatever was in s3 before the function call back into s3
			j	 __enddecrypt
		#############################	
		__lowercase_decipher:
			subi	 $s2, $s1, 65	 
			sub	 $s3, $s0, $s2
			blt	 $s3, 97, __looparoundDE2
			
			move	 $v0, $s3		#s3 will have the CIPHER CHAR, move it to v0 to return
			move	 $s0, $t5		#moving whatever was in s0 before the function call back into s0
			move	 $s1, $t6		#moving whatever was in s1 before the function call back into s1
			move	 $s2, $t7		#moving whatever was in s2 before the function call back into s2
			move	 $s3, $t8		#moving whatever was in s3 before the function call back into s3
			j	 __enddecrypt
		#############################	
		__looparoundDE2:
			li	 $s4, 91
			sub	 $s3, $s4, $s2
			move	 $v0, $s3		#s3 will have the CIPHER CHAR, move it to v0 to return
			move	 $s0, $t5		#moving whatever was in s0 before the function call back into s0
			move	 $s1, $t6		#moving whatever was in s1 before the function call back into s1
			move	 $s2, $t7		#moving whatever was in s2 before the function call back into s2
			move	 $s3, $t8		#moving whatever was in s3 before the function call back into s3
			j	__enddecrypt
		#############################
		__dontCipherDE:
			move	 $v0, $s0	
			j	 __enddecrypt
		__enddecrypt:
			jr	 $ra			#it should return v0 which is our deciphered text
#####################################################################################################
	#ASSUME A0 IS PLAINTEXT STRING
	#ASSUME A1 IS KEY STRING
	#A2 SHOULD CONTAIN DECIPHERED STRING
	DecryptString:
		#ASSUME A0 IS OUR PLAINTEXT STRING
		#ASSUME A1 IS OUR KEY ASCII STRING
		#WE WANT CIPHERED STRING STORED IN A2
		move	 $t0, $a0	#t0 has our whole plaintext string
		move	 $t1, $a1	#t1 has our whole KEY string
		move	 $t6, $s1	#storing whatever was in s1 before subroutine
		move	 $s1, $a1	#another copy of key string
		addi	 $sp, $sp, -4
		sw	 $ra, 0 ($sp)
		li	 $t2, 0
		__DSloop:
			lb	 $a0, 0($t0)	#loading plaintext character into a0
			lb	 $a1, 0($t1)	#loading key character into a1
			#if key hits null, loop back to beginning of key
			beqz	 $a1, firstKeyDE
			j	 __innerDE
			firstKeyDE:
				 move	 $t1, $s1	#reset t1 back to s1 which is the original a1
				 lb	 $a1, 0($t1)
				 j	 __innerDE
			__innerDE:
	
			jal	 DecryptChar
			sb	 $v0, 0($a2)			 #storing deciphered character one by one
			beqz	 $v0, __end_loop_stringDE
			addi	 $a2, $a2, 1
			beqz	 $a0, __end_loop_stringDE
			addi	 $t0, $t0, 1 #point to next text character
			addi	 $t1, $t1, 1 #point to next key character
			addi	 $t2, $t2, 1 #to make sure we don't go over 30 characters
			beq	 $t2, 30, __end_loop_stringDE
			j	 __DSloop
				
		__end_loop_stringDE:		
			move	 $v0, $a2	 #moving a2, our deciphered string, to v0 
			move	 $s1, $t6	 #storing whatever was in s1 before subroutine back into s1
			lw	 $ra, 0($sp)
			addi	 $sp, $sp, 4
			jr	 $ra			#it should return a2 which is our deciphered character
