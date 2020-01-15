start0:
eeprom 0,(20)
init:
suspend 1
symbol ruutu = b.5
pwmout b.3,25,1	; start pwm


pullup %11011100
pullup on
symbol vlamp = b.6
symbol slamp = b.7
symbol klamp = b.4
symbol plamp = b.2
symbol vbut = pinc.1
symbol sbut = pinc.0
symbol kbut = pinc.5
symbol pbut = pinc.2
input c.1, c.0, c.2, c.5
output b.6, b.7, b.4, b.2, b.1, c.3

symbol arvonta1 = b2
symbol arvonta2 = b3
symbol arvonta3 = b4
symbol arvonta4 = b5
symbol painettu = b6
symbol seuraava = b7
symbol kokonaistulos = b8
symbol oikeanumero = b9
symbol arvottu = b10
symbol arvottued = b11
symbol viive = w6 ;b12 b13
symbol seurpaino = b14
symbol oikeapaino = b15
symbol nappi = b16
symbol kierto = b17
symbol peli = b18
symbol arvotut = b19
symbol arvotutjatulos = b20
symbol highscore = b21
symbol reaktio = b22
symbol jarjestys = b23

read 0,highscore

let seurpaino = 0
let kokonaistulos = 0
gosub arvonta
pause 500
serout ruutu, n2400,(254,1)
pause 500

let viive = 860
let seuraava = -1
let peli = 0

low klamp
low slamp
low vlamp
low plamp


alkuvalikko:
high slamp
let arvotut = 0
serout ruutu, n2400,(254,1)
pause 30
serout ruutu, n2400,(254,128, "aloita paina", 254,192, "sinista")
do
if sbut = 1 then
	low slamp
	serout ruutu, n2400,(254,1)
	pause 1000
	gosub NYT
	serout ruutu, n2400,(254,128, "tulos: ", #kokonaistulos)
	pause 500
	resume 1
	goto main
endif
loop

NYT:
serout ruutu, n2400, (254,128, "Peli alkaa...", 254,192, "N...")
	pause 600
	serout ruutu, n2400, (254,192, "Y")
	pause 600
	serout ruutu, n2400, (254,192, "T")
	pause 600
	serout ruutu, n2400, (254,1)
	pause 30
	serout ruutu, n2400, (254,128, "NYT!!!")
	pause 600
	return

main:
gosub arvonta
gosub oikearivi
do
	
gosub arvonta
gosub oikearivi
gosub lamppu
pause viive

loop while peli = 0
goto gameover

arvonta:

DO
RANDOM w0
arvottu = w0 / 199 // 4
LOOP UNTIL arvottu <> arvottued
let arvottued = arvottu
return


oikearivi:
inc seuraava
if seuraava = 0 then 
	let reaktio = 3
else 
	let reaktio = seuraava - 1
endif
inc arvotut
select case seuraava
case 0
	let arvonta1 = arvottu
case 1
	let arvonta2 = arvottu
case 2
	let arvonta3 = arvottu
case 3
	let arvonta4 = arvottu
	let seuraava = -1
endselect
return	
#macro sammutus
low klamp
low slamp
low vlamp
low plamp
#endmacro

lamppu:
sammutus
lookup reaktio,(arvonta1,arvonta2,arvonta3,arvonta4), jarjestys
on jarjestys gosub L1,L2,L3,L4
return



L1:
high klamp
return
L2:
high vlamp
return
L3:
high plamp
return
L4:
high slamp
return

gameover:
suspend 1
pwmout b.3,off
pause 1000
low b.1
sammutus

if kokonaistulos > highscore then
	goto ennatys
else
	serout ruutu, n2400,(254,1)
	pause 30
	for kierto = 0 to 3
	high klamp,vlamp,plamp,slamp
	serout ruutu, n2400,(254,128, "kokonaistulos ", #kokonaistulos)
	serout ruutu, n2400,(254,192, "gameoevr")
	pause 600
	low klamp,vlamp,plamp,slamp
	serout ruutu, n2400,(254,1)
	pause 300
next kierto
goto init
endif

ennatys:
high b.3
on arvonta1 gosub L1,L2,L3,L4
serout b.5, n2400, (254,1)
pause 30
serout b.5, n2400, (254,128, "**HIGHSCORE!!!**")

high klamp
tune c.3, 5, ($7B,$79,$3B,$34,$3C,$7C)

toggle klamp, plamp, slamp, vlamp
tune c.3, 5, ($40,$7B,$40,$7B,$39,$3C)
toggle klamp, plamp, slamp, vlamp
tune c.3, 5, ($7C,$40,$7B,$00,$34,$3C)
toggle klamp, plamp, slamp, vlamp
tune c.3, 5, ($7C,$79,$77,$79,$77,$76)
toggle klamp, plamp, slamp, vlamp
tune c.3, 5, ($79,$37,$76,$77,$39,$77)
toggle klamp, plamp, slamp, vlamp
tune c.3, 5, ($79,$7B,$79,$77,$76,$34)
toggle klamp, plamp, slamp, vlamp
tune c.3, 5, ($00,$FB,$7B,$40,$7B,$79,$BB)


serout b.5, n2400, (254,128, "Vanha           ",254,192,"enn?tys: ", #highscore)
pause 5000
serout b.5, n2400, (254,128, "****  Uusi  ****",254,192,"enn?tys:*  ", #kokonaistulos,254,207, "*" )
pause 4000
let highscore = kokonaistulos
write 0,highscore
low b.3
goto init


start1:
ykkonen:
	serout ruutu, n2400,(254,192, "highscore: ", #highscore)
do
	button c.5, 1, 254, 199, nappi, 1, tarkista0
	button c.1, 1, 254, 199, nappi, 1, tarkista1
	button c.2, 1, 254, 199, nappi, 1, tarkista2
	button c.0, 1, 254, 199, nappi, 1, tarkista3
	
	

	let arvotutjatulos = arvotut - kokonaistulos
	if arvotutjatulos > 3 then
		let peli = 1
		high b.1
	endif
	
loop

tarkista0:
let painettu = 0
goto tarkista
tarkista1:
let painettu = 1
goto tarkista
tarkista2:
let painettu = 2
goto tarkista
tarkista3:
let painettu = 3
goto tarkista

tarkista:
pause 70
if seurpaino = reaktio then
		setint %00000000, %00000001
		endif
lookup seurpaino,(arvonta1,arvonta2,arvonta3,arvonta4), oikeapaino
if oikeapaino = painettu then
	inc kokonaistulos
	
	if kokonaistulos = 8 or kokonaistulos = 16 or kokonaistulos = 24 then
		let viive = viive - 100
	endif
	if kokonaistulos = 32 or kokonaistulos = 40 or kokonaistulos = 50 or kokonaistulos = 60 then
		let viive = viive - 50
		
	endif
	if kokonaistulos = 70 or kokonaistulos = 80 or kokonaistulos = 90 then
		let viive = viive - 40
		endif
	serout ruutu, n2400,(254,128, "tulos: ", #kokonaistulos)
	pwmduty b.3,kokonaistulos
	if seurpaino = 3 then
		let seurpaino = 0
	else
		inc seurpaino
	endif
else 
	let peli = 1
	high b.1
endif
goto ykkonen

interrupt:
return
