1. What did the missing `CDQ` do, and why? (What was in EDX when `IDIV` ran?)

	The CDQ sign extends EAX into EDX:EAX, which prepares the dividend for signed division.
	Without it EDX contained whatever value was left from previous operations, possibly causing an incorrect qoutient or divide error.

2. TODO 3 says multiply first, then divide. Compute `−14 / 5 * 9 + 320` in integer math by hand, in that (wrong) order. What do you get, and where did the precision go?

	-14 / 5 = -2
	-2 * 9 = -18
	-18 + 320 = 302

	Final answer would be 302,the fraction from the division was discarded during the integer division losing percision before multiplying.

3. The demo prints 300000 × 20000 as a strange number and overflow flag = 1.
What are the low 32 bits of 6,000,000,000 in hex, and why doesn't the CPU stop the program?

	Hex: 0x65A0BC00
	The CPU doesn't stop because the 32-bit result keeps only the lowest 32 bits of the product.
	The IMUL instruction sets the OF when the signed result cannot fit in the 32 bits, but it doesn't automatically stop the execution.
	The program can check the flag and keep running.
