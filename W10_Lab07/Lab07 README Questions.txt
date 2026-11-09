Shea Fuller
11/8/26


**1. Why TODO 1 does not need an AND.**
TODO 1 extracts the mode with two instructions:

    mov  eax, flags4      ; EAX = 0000 0035h  =  ... 0000 0000 0011 0101
    shr  eax, 4

Notice there is no `and` to isolate bits 7..4 before the shift.

   a. Write the low 8 bits of EAX **before** the shift and **after** the shift.
   b. After the shift, where did the original bits 7..4 (the mode, `0011`) land?
   
a. Before: 00110101
   After: 00000011
   
b. The original bits moved down into bits 3..0 after shifting to the right by 4 places.
   The higher bits were already zero and an AND instruction wasn't needed to isolate.

**2. Forcing the mode to a specific value.**
TODO 3 changed the mode from SAFE (3) to IDLE (0) with `xor eax, 30h`. That only worked because we already knew the mode was 3: XOR flips the bits that are there, so the result depends on the starting value.

New requirement: mission control wants the mode set to **SCIENCE (2)**, and the code must work no matter what the current mode is (0, 1, 2, or 3). Bits 3..0 must not change.

   a. In one or two sentences, explain why one `xor` instruction cannot meet this requirement.
   
a. One single XOR cannot guarantee the mode becomes SCIENCE (2) because XOR flips bits instead of setting them to a specific value.
   The result depends on the modes original value so the mode bits would need to be cleared first and then set to 0010 without changing bits 3..0.   