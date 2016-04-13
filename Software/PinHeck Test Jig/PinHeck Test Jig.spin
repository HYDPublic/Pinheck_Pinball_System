{Object_Title_and_Purpose}


CON
        _clkmode  = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq  = 6_000_000

        PWR_ON    = 0
        
        RST_PIC32 = 8
        TX_PIC32  = 9
        RX_PIC32  = 10
        
        RST_PROP  = 11
        TX_PROP   = 12
        RX_PROP   = 13

        CLK_165   = 16
        LAT_165  = 17
        DAT_165  = 18

        CLK_595   = 19
        LAT_595   = 20
        DAT_595   = 21

VAR
  byte str_test[32]
  byte opcode[32]
  byte ostr[32]

  byte inputs[14]

  byte PICcode[128]

  byte shiftin

  byte ERROR

  byte temp_char

  word temp_word

  word output 
   
OBJ

  PST : "Parallax Serial Terminal"
  PIC : "Parallax Serial Terminal"
  PRP : "Parallax Serial Terminal"

  ADC : "MAX11613"
  
                       
PUB MAIN | i,j

  DIRA[RST_PIC32]~
  'OUTA[RST_PIC32]~~

  DIRA[CLK_165]~~
  DIRA[LAT_165]~~
  DIRA[DAT_165]~

  DIRA[CLK_595]~~
  DIRA[LAT_595]~~
  DIRA[DAT_595]~~

  OUTA[LAT_595]~
  OUTA[CLK_595]~
  OUTA[DAT_595]~ 

  OUTA[PWR_ON] := FALSE 
  DIRA[PWR_ON]~~
  
  
  ADC.Init(28)

  PST.Start(115200)

  PST.Str(STRING("STARTING PinHeck Test Jig."))
  PST.Newline
  PST.Str(STRING("STARTING PIC32 COM."))
  PST.Newline
  
  if(PIC.StartRxTx(TX_PIC32, RX_PIC32, 0, 115200))
    PST.Str(STRING("PIC32 COM Success."))
    PST.Newline
  else
    PST.Str(STRING("PIC32 COM FAIL."))
    PST.Newline
  
  PST.Str(STRING("STARTING PROP COM."))
  PST.Newline
  
  if(PRP.StartRxTx(RX_PROP, TX_PROP, 0, 115200))
    PST.Str(STRING("PROP COM Success."))
    PST.Newline
  else
    PST.Str(STRING("PROP COM FAIL."))
    PST.Newline

  'READY?!

  PST.Str(STRING("Ready."))
  PST.Newline
  PST.Str(STRING("Enter y to PWR board."))
  PST.NewLine

  repeat                                    
    PST.StrIn(@str_test)
    Parse(@str_test, @opcode, 0,5)
    
    if StrCount(STRING("y"),@opcode)
      QUIT
    else
      PST.Str(STRING("WRONG CMD"))
      PST.Newline

  PST.Str(STRING("Turn on PWR. Please wait..."))
  PST.Newline  

  OUTA[PWR_ON] := TRUE

  repeat i from 1 to 5
    waitcnt(clkfreq + cnt)
    PST.Dec(i)
    PST.Str(STRING("..."))
    PST.Newline  

  PST.Str(STRING("PWR on..."))
  PST.NewLine

  PST.Str(STRING("Program PIC32 with the PICKIT3 and then enter y."))
  PST.NewLine

  repeat                                    
    PST.StrIn(@str_test)
    Parse(@str_test, @opcode, 0,5)
    
    if StrCount(STRING("y"),@opcode)
      QUIT
    else
      PST.Str(STRING("WRONG CMD"))
      PST.Newline

  PST.Str(STRING("Reseting PIC32...PWR OFF"))
  PST.NewLine

  OUTA[PWR_ON] := FALSE

  repeat i from 1 to 5
    waitcnt(clkfreq + cnt)
    PST.Dec(i)
    PST.Str(STRING("..."))
    PST.Newline

  PST.Str(STRING("Turn on PWR. Please wait..."))
  PST.Newline  

  OUTA[PWR_ON] := TRUE


  repeat i from 1 to 5
    waitcnt(clkfreq + cnt)
    PST.Dec(i)
    PST.Str(STRING("..."))
    PST.Newline
    
  PST.Str(STRING("Starting Test..."))
  PST.Newline
  PST.Newline 

  PST.Str(STRING("Watch Doge LED ON? Enter y if yes. Enter n if no."))
  PST.NewLine

  repeat                                    
    PST.StrIn(@str_test)
    Parse(@str_test, @opcode, 0,5)
    
    if StrCount(STRING("y"),@opcode)
      QUIT
    elseif StrCount(STRING("n"),@opcode)
      PST.NewLine
      PST.Str(STRING("WATCHDOGE OR PIC32 CODE NOT RUNNING"))
      PST.NewLine
      TURNOFF
    else
      PST.Str(STRING("WRONG CMD"))
      PST.Newline
 
  'Test Solenoids

  PST.NewLine
  PST.STR(STRING("SOLENOID TESTING..."))
  PST.NewLine

  PIC.RxFlush
  
  repeat i from 0 to 23
    PIC.Str(STRING("[a"))

    if (solPins[i] < 10)
      PIC.Dec(0)
      PIC.Dec(solPins[i])
    else
      PIC.Dec(solPins[i])
    PIC.Dec(1)
    PIC.Str(STRING("]"))
    PIC.StrIn(@PICcode)
    
    waitcnt((clkfreq>>4) + cnt)

    GetIO
    if(solignore[i] == 1)
      PST.STR(STRING("SOLENOID SKIP: "))
      PST.Dec(i)
      PST.NewLine    
    elseif (inputs[5] <> solcheck0[i])
      PST.STR(STRING("ERROR SOLENOID: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine 
    elseif (inputs[4] <> solcheck1[i]) 
      PST.STR(STRING("ERROR SOLENOID: "))
      ERROR++ 
      PST.DEC(i)
      PST.NewLine
    elseif (inputs[3] <> solcheck2[i]) 
      PST.STR(STRING("ERROR SOLENOID: "))
      ERROR++ 
      PST.DEC(i)
      PST.NewLine
    else
      PST.STR(STRING("SOLENOID PASS: "))
      PST.DEC(i)
      PST.NewLine

    PIC.Str(STRING("[a"))

    if (solPins[i] < 10)
      PIC.Dec(0)
      PIC.Dec(solPins[i])
    else
      PIC.Dec(solPins[i])
    PIC.Dec(0)
    PIC.Str(STRING("]"))
    PIC.StrIn(@PICcode)
    
    waitcnt((clkfreq>>4) + cnt)
    
  'Test GI
  
  PST.NewLine
  PST.STR(STRING("GI TESTING..."))
  PST.NewLine

  PIC.RxFlush

  repeat i from 0 to 15
   
    PIC.Str(STRING("[b"))
    PIC.Char(giPins[i*2])
    PIC.Char(giPins[(i*2)+1])
    PIC.Str(STRING("Z]"))
    PIC.StrIn(@PICcode)
    
    waitcnt((clkfreq>>4) + cnt)  
   
    GetIO
   
    if(giignore[i] == 1)
      PST.STR(STRING("GI SKIP: "))
      PST.Dec(i)
      PST.NewLine    
    elseif (inputs[1] <> gicheck0[i])
      PST.STR(STRING("ERROR GI: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine 
    elseif (inputs[2] <> gicheck1[i]) 
      PST.STR(STRING("ERROR GI: "))
      ERROR++ 
      PST.DEC(i)
      PST.NewLine
    else
      PST.STR(STRING("GI PASS: "))
      PST.DEC(i)
      PST.NewLine

  'Test Light Matrix Row

  PST.NewLine
  PST.STR(STRING("LIGHT MATRIX ROW TESTING..."))
  PST.NewLine

  PIC.RxFlush
  repeat i from 0 to 7
   
    PIC.Str(STRING("[c"))
    PIC.Char(lrPins[i])
    PIC.Char(%0000_0000)
    PIC.Str(STRING("Z]"))
    PIC.StrIn(@PICcode)
    
    waitcnt((clkfreq>>4) + cnt)
   
    GetIO
    
    if (inputs[7] <> lrcheck0[i])
      PST.STR(STRING("ERROR LIGHT ROW: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine 
    else
      PST.STR(STRING("LIGHT ROW PASS: "))
      PST.DEC(i)
      PST.NewLine    
      
  'Test Light Matrix Column

  PST.NewLine
  PST.STR(STRING("LIGHT MATRIX COLUMN TESTING..."))
  PST.NewLine

  PIC.RxFlush

  repeat i from 0 to 7
   
    PIC.Str(STRING("[c"))
    PIC.Char(%0000_0000)
    PIC.Char(lcPins[i])
    PIC.Str(STRING("Z]"))
    PIC.StrIn(@PICcode)
    
    waitcnt((clkfreq>>4) + cnt)

    GetIO
    
    if (inputs[8] <> lccheck0[i])
      PST.STR(STRING("ERROR LIGHT COLUMN: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine 
    else
      PST.STR(STRING("LIGHT COLUMN PASS: "))
      PST.DEC(i)
      PST.NewLine

  'Test Switch Row

  PST.NewLine
  PST.STR(STRING("SWITCH MATRIX ROW TESTING..."))
  PST.NewLine

  PIC.RxFlush

  repeat i from 0 to 7
    PIC.RxFlush

    output := sroutput[i]
  
    PushIO 
  
    waitcnt((clkfreq>>4) + cnt)
   
    PIC.Str(STRING("[nZZZ]"))
    PIC.CharIn
    PIC.CharIn
    temp_char := PIC.CharIn
     
    if(temp_char <> srcheck0[i])
      PST.STR(STRING("ERROR SWITCH ROW: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine 
    else
      PST.STR(STRING("SWITCH ROW PASS: "))
      PST.DEC(i)
      PST.NewLine

  'Test Switch Column

  PST.NewLine
  PST.STR(STRING("SWITCH MATRIX COLUMN TESTING..."))
  PST.NewLine

  PIC.RxFlush

  repeat i from 0 to 7
   
    PIC.Str(STRING("[d"))
    PIC.Char(scPins[i])
    PIC.Str(STRING("ZZ]"))
    PIC.StrIn(@PICcode)
    
    waitcnt((clkfreq>>4) + cnt)

    GetIO
    
    if (inputs[6] <> sccheck0[i])
      PST.STR(STRING("ERROR SWITCH COLUMN: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine 
    else
      PST.STR(STRING("SWITCH COLUMN PASS: "))
      PST.DEC(i)
      PST.NewLine


  'Test On Board RGB

  PST.NewLine
  PST.STR(STRING("RGB ON BOARD TESTING..."))
  PST.NewLine

  'PIC.RxFlush

  repeat i from 0 to 2
   
    PIC.Str(STRING("[e"))
    PIC.Char(rgbobR[i])
    PIC.Char(rgbobG[i])
    PIC.Char(rgbobB[i])  
    PIC.Str(STRING("]"))
    PIC.StrIn(@PICcode)

    waitcnt((clkfreq>>4) + cnt)

    GetIO

    if (inputs[12] <> rgbcheck0[i])
      PST.STR(STRING("ERROR RGB ONBOARD: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine
    elseif (inputs[11] <> rgbcheck1[i])
      PST.STR(STRING("ERROR RGB ONBOARD: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine
    else
      PST.STR(STRING("RGB ONBOARD PASS: "))
      PST.DEC(i)
      PST.NewLine 

  'Test Servos

  PST.NewLine
  PST.STR(STRING("SERVO TESTING..."))
  PST.NewLine

  'PIC.RxFlush

  repeat i from 0 to 4
    PIC.Str(STRING("[a"))

    if (servoPins[i] < 10)
      PIC.Dec(0)
      PIC.Dec(servoPins[i])
    else
      PIC.Dec(servoPins[i])
    PIC.Dec(0)
    PIC.Str(STRING("]"))
    PIC.StrIn(@PICcode)
    
    waitcnt((clkfreq>>4) + cnt)

    GetIO

    if ((inputs[10] & %00011111) <> servocheck0[i])
      PST.STR(STRING("ERROR SERVO: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine 
    else
      PST.STR(STRING("SERVO PASS: "))
      PST.DEC(i)
      PST.NewLine

    PIC.Str(STRING("[a"))

    if (servoPins[i] < 10)
      PIC.Dec(0)
      PIC.Dec(servoPins[i])
    else
      PIC.Dec(servoPins[i])
    PIC.Dec(1)
    PIC.Str(STRING("]"))
    PIC.StrIn(@PICcode)
    
    waitcnt((clkfreq>>4) + cnt)

  'Test Cabinet I/O

  PST.NewLine
  PST.STR(STRING("CABINET I/O TESTING..."))
  PST.NewLine

  repeat i from 0 to 7
    PIC.RxFlush

    output := caboutput[i]

    PushIO 
  
    waitcnt((clkfreq>>4) + cnt)            
   
    PIC.Str(STRING("[mZZZ]"))
    PIC.CharIn
    PIC.CharIn
    temp_char := PIC.CharIn
    temp_word := temp_char
    temp_word := temp_word << 8
    temp_char :=  PIC.CharIn
    temp_word := temp_word + temp_char
    
    if(temp_word <> cabcheck0[i])
      PST.STR(STRING("ERROR CABINET I/O: "))
      ERROR++
      PST.DEC(i)
      PST.NewLine 
    else
      PST.STR(STRING("CABINET I/O PASS: "))
      PST.DEC(i)
      PST.NewLine 
               
  PST.NewLine
  PST.STR(STRING("TEST COMPLETED."))
  PST.NewLine

  if(ERROR > 0)
    PST.STR(STRING("ERROR COUNT: "))
    PST.DEC(ERROR)
    PST.NewLine
    PST.STR(STRING("PLEASE CHECK LOG ABOVE FOR ERRORS."))
  else
    PST.STR(STRING("NO ERRORS FOUND!"))

  PST.NewLine
  PST.NewLine

  TURNOFF

PRI TURNOFF | i

  PST.Str(STRING("Turn off PWR."))
  PST.NewLine
  OUTA[PWR_ON] := FALSE

  repeat i from 1 to 5
    waitcnt(clkfreq + cnt)
    PST.Dec(i)
    PST.Str(STRING("..."))
    PST.Newline

  PST.Str(STRING("Safe to remove PINHECK."))
  PST.NewLine
  PST.NewLine

  PST.Str(STRING("Enter y to START again."))
  PST.NewLine

  repeat                                    
    PST.StrIn(@str_test)
    Parse(@str_test, @opcode, 0,5)
    
    if StrCount(STRING("y"),@opcode)
      QUIT
    else
      PST.Str(STRING("WRONG CMD"))
      PST.Newline

  REBOOT

PRI GetIO | i

  OUTA[LAT_165]~
  OUTA[LAT_165]~~
  
  waitcnt(clkfreq/1000 + cnt)

  repeat i from 0 to 13
    repeat 8
      OUTA[CLK_165]~
      shiftin := shiftin << 1 + INA[DAT_165]
      OUTA[CLK_165]~~
      waitcnt(clkfreq/1000 + cnt)

    inputs[i] := shiftin

  OUTA[CLK_165]~~
  OUTA[LAT_165]~~

  return

PRI PushIO 

  repeat 16
    OUTA[DAT_595] := output
    waitcnt(clkfreq/1000 + cnt)
    output := output >> 1
    OUTA[CLK_595]~
    OUTA[CLK_595]~~
    OUTA[CLK_595]~
    waitcnt(clkfreq/1000 + cnt)

  OUTA[LAT_595]~~
  OUTA[LAT_595]~

  OUTA[CLK_595]~~

  return

PRI Parse (strAddr, parAddr, start, count) | j

  repeat j from 0 to (count - 1)

    byte[parAddr + j] := byte[strAddr + j + start]
    
  byte[parAddr + (count)] := 0                                                    ' terminate string
  
  return parAddr

PRI StrCount (strAddr, searchAddr) : count | size, searchsize, pos, loc

  size := strsize(strAddr) + 1              
  searchsize := strsize(searchAddr)   

  count := pos := 0     
  REPEAT WHILE ((loc := StrPos(strAddr, searchAddr, pos)) <> -1)                ' while a search string exists
    count++
    pos := loc + searchsize

PRI StrPos (strAddr, searchAddr, offset) | size, searchsize

  size := strsize(strAddr) + 1
  searchsize := strsize(searchAddr)

  REPEAT UNTIL (offset + searchsize > size)
    IF (strcomp(StrParse(strAddr, offset++, searchsize), searchAddr))           ' if string search found
      RETURN offset - 1                                                         ' return byte location
  RETURN -1

PRI StrParse (strAddr, start, count)

  count <#= constant(31)
  bytemove(@ostr, strAddr + start, count)                                       ' just move the selected section

  ostr[count] := 0                                                              ' terminate string
  RETURN @ostr

DAT

     solPins   BYTE 22, 23, 32, 25, 31, 30, 2, 4, 7, 11, 12, 70, 71, 72, 73, 75, 78, 79, 80, 81, 82, 83, 84, 85

     solcheck0 BYTE %01111111, %10111111, %11011111, %11101111, %11110111, %11111011, %11111101, %11111110, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111   
     solcheck1 BYTE %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %01111111, %10111111, %11011111, %11101111, %11110111, %11111011, %11111101, %11111110, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
     solcheck2 BYTE %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %01111111, %10111111, %11011111, %11101111, %11110111, %11111011, %11111101, %11111110

     solignore BYTE 0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1

     giPins    BYTE %10000000, %00000000, %01000000, %00000000, %00100000, %00000000, %00010000, %00000000, %00001000, %00000000, %00000100, %00000000, %00000010, %00000000, %00000001, %00000000, %00000000, %10000000, %00000000, %01000000, %00000000, %00100000, %00000000, %00010000, %00000000, %00001000, %00000000, %00000100, %00000000, %00000010, %00000000, %00000001

     gicheck0  BYTE %01111111, %10111111, %11011111, %11101111, %11110111, %11111011, %11111101, %11111110, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
     gicheck1  BYTE %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %01111111, %10111111, %11011111, %11101111, %11110111, %11111011, %11111101, %11111110

     giignore  BYTE 1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0

     lrPins    BYTE %00000001, %00000010, %00000100, %00001000, %00010000, %00100000, %01000000, %10000000

     lrcheck0  BYTE %01111111, %10111111, %11011111, %11101111, %11110111, %11111011, %11111101, %11111110

     lcPins    BYTE %00000001, %00000010, %00000100, %00001000, %00010000, %00100000, %01000000, %10000000

     lccheck0  BYTE %10000000, %01000000, %00100000, %00010000, %00001000, %00000100, %00000010, %00000001

     sroutput  WORD %00000000_00000001, %00000000_00000010, %00000000_00000100, %00000000_00001000, %00000000_00010000, %00000000_00100000, %00000000_01000000, %00000000_10000000

     srcheck0  BYTE %11111110, %11111101, %11111011, %11110111, %11101111, %11011111, %10111111, %01111111     

     scPins    BYTE %00000001, %00000010, %00000100, %00001000, %00010000, %00100000, %01000000, %10000000

     sccheck0  BYTE %00000001, %00000010, %00000100, %00001000, %00010000, %00100000, %01000000, %10000000

     rgbobR    BYTE %11111111, %00000000, %00000000

     rgbobG    BYTE %00000000, %11111111, %00000000

     rgbobB    BYTE %00000000, %00000000, %11111111

     rgbcheck0 BYTE %00000011, %00000010, %00000001

     rgbcheck1 BYTE %01100001, %11010001, %10110001

     servoPins BYTE 46, 44, 17, 34, 33

     servocheck0 BYTE %00011110, %00011101, %00011011, %00010111, %00001111

     caboutput WORD %11111110_00000000, %11111101_00000000, %11111011_00000000, %11110111_00000000, %11101111_00000000, %11011111_00000000, %10111111_00000000, %01111111_00000000

     cabcheck0 WORD %11101110_00001001, %11101110_00000101, %11101110_00000011, %11101110_00100001, %11101110_01000001, %11101110_10000001, %11101111_00000001, %11101110_00010001

