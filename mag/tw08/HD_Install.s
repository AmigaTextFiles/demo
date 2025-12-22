Resident C:Assign
Resident C:Copy
Failat 21

Echo "*n             -------------------------------"
Echo "              `The Word' issue 8 HD Install "
Echo "             -------------------------------*n"

Ask "Proceed with Install (y/n)?"

If NOT WARN
    Echo "Bye Bye dude..."
    EndCLI >Nil:
Endif
Echo "Installing `The Word' to your Harddrive..."
Echo "This script will create it's own drawer called `Word8'"
Ask  "Press >Return< to set destination for `Word' drawer."

;---------------------------------------------- Get Location for drawer.
Echo >Env:Word.temp0 "Assign WORD: " NOLINE
RequestFile >>Env:Word.temp0 DRAWER "SYS:" TITLE "Word Drawer Destination..." DRAWERSONLY
Execute >Nil: Env:Word.temp0
Delete >Nil: Env:Word.temp0

;---------------------------------------------- Create drawer & icon.
MakeDir WORD:Word8
If Exists SYS:Prefs/Env-Archive/Sys/def_drawer.info
    Copy SYS:Prefs/Env-Archive/Sys/def_drawer.info WORD:Word8.info
Else
    Copy NFA-TW8a:Files_1.info WORD:Word8.info
Endif

;---------------------------------------------- Copy files to WORD:
Echo "*nCopying main file..."
Copy >Nil: NFA-TW8a:TW8.exe#? WORD:Word8/
Echo "Copying Articles from Disk 1..."
Copy NFA-TW8a:Files_1#? ALL WORD:Word8/ QUIET

;---------------------------------------------- Copy Fonts if necessary
Echo "Checking Fonts..."

If Exists FONTS:WindsorDemi/60
    Echo "  WindsorDemi font already found..."
Else
    Makedir FONTS:WindsorDemi
    Copy >Nil: NFA-TW8a:Fonts/WindsorDemi#? FONTS: ALL
    Echo "  Added WindsorDemi 60 font..."
Endif

If Exists FONTS:Coop/24
    Echo "  Coop font already found..."
Else
    Makedir FONTS:Coop
    Copy >Nil: NFA-TW8a:Fonts/Coop#? FONTS: ALL
    Echo "  Added Coop 24 font..."
Endif

;---------------------------------------------- Files from Disk 2
Assign >Nil: NFA-TW8b: EXISTS
If WARN
    Echo "Insert disk 2 in any drive..."
Endif
;------------------ Wait for disk
lab DISK2
Assign >Nil: NFA-TW8b: EXISTS
If WARN
    Skip DISK2 BACK
Endif

Echo "Copying Articles from Disk 2..."
Copy NFA-TW8b:Files_2#? ALL WORD:Word8/ QUIET

;---------------------------------------------- Decrunch main file?
If Exists C:XLD
    Echo "You appear to have XLD in your C: directory, do you"
    Ask  "want to try and decrunch the main file (y/n)?"
    If WARN
        Echo "Starting XLD..."
        C:XLD WORD:Word8/TW8.exe
    Endif
Else
    If Exists C:DLD
        Echo "You appear to have DLD in your C: directory, do you"
        Ask  "want to try and decrunch the main file (y/n)?"
        If WARN
            Echo "Starting DLD..."
            C:DLD WORD:Word8/TW8.exe
        Endif
    Else
        Echo "No Decrunchers Found..."
    Endif
Endif

Assign WORD: DISMOUNT
Resident Assign REMOVE
Resident Copy REMOVE
Echo "Installation Complete!"
