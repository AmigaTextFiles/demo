;"absolon" start script.
stack 500000
setpatch QUIET
assign env: envarc:
assign t: ram:
assign libs: libs/ add

copy .prefs envarc:va3d.prefs
!absolon!.elf
