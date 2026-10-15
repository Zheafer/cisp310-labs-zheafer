1. Why does `minTemp` start at 7FFFFFFFh instead of 0? What goes wrong with 0 on tonight's data?
	It starts at the higheest possible signed 32-bit integer so the first temperature can replace it.
	Starting at 0 gives an incorrect minimum is all temperatures are positive.

2. TODO 2 sums into `AL` — no `AND 0FFh` anywhere. Where is the mod-256?
	AL is 8 bits so overflow automatically discards any higher bits, effectively performing the mod-256.
	
3. The outer loop uses `INC/CMP/JL` while the inner uses `LOOP`. Why would using `LOOP` for both be dangerous?
	Both loops would modify ECX, potentially corrupting the outer loops counter and causing incorrect iterations.