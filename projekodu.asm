;------------------------------------------
;	K�T�PHANELER? FELAN EKLEME KISMI
;------------------------------------------
	
LIST P=16F84A	; kullan?ca??m pic i belirttim	
INCLUDE "P16F84A.INC" ; pic in k�t�phanesini ekledim i�indeki registerlar? kullanabilmek i�in
__CONFIG _WDT_OFF &_XT_OSC &_PWRTE_ON &_CP_OFF ; configuratio bitsleri ekledim

;-----------------------------------------------
	; KULLANACAgIM VARIABLEARIN TANIMINI YAPMA ISLEMI
;-----------------------------------------------
	
LSB	EQU	H'0021' 
MSB	EQU	H'0022'
BIR	EQU	H'0023'  ; H'0023' adresindeki degeri Sayi1 e ata
ON	EQU	H'0024'
YUZ	EQU	H'0025'
BIN	EQU	H'0026'
RAKAM	EQU	H'0027'

; hat?rlatma ama�l?	
W	EQU	0
F	EQU	1
	
	
;---------------------------------------------
;	TEMIZLEME ISLEMLERI VE GE�IS ISLEMLERI
;---------------------------------------------	
	
BASLA
	CLRF	 MSB ; MSB'nin b�t�n bitlerini 0 yap 
	CLRF	 LSB ; LSB'nin b�t�n bitlerini 0 yap
	BSF	 STATUS,5 ; Bank 1 e ge�?g?n
	MOVLW 	 B'11110000' ; w ye 11110000 degerini ata
	MOVWF    TRISA ; porta nin ilk 4 unu giris yap
	MOVLW 	 B'10000000' ; w ye 10000000 degerini ata
	MOVWF	 TRISB ; portb nin ilki haric hepsini cikis yap
	BCF	 STATUS,5 ; bank 0 a gec
	;bi ihtimal hafizada bir ?ey varsa onlari temizle 
	CLRF	PORTB ; POrtB y? �?k?s yap
	CLRF	PORTA; POrtA y? �?k?s yap
	;baslangic rakam degerlerini temizleme islemi
	CLRF	BIR ;G�stergeye yaz?lacak say?ya yer ay?rd?k
	CLRF	ON  ;G�stergeye yaz?lacak say?ya yer ay?rd?k
	CLRF	YUZ ;G�stergeye yaz?lacak say?ya yer ay?rd?k
	CLRF	BIN ;G�stergeye yaz?lacak say?ya yer ay?rd?k
	CLRF    RAKAM ;G�stergeye yaz?lacak say?ya yer ay?rd?k
	GOTO	ANA ;G�stergeye yaz?lacak say?ya yer ay?rd?k
	
;-----------------------------
; ARTTIRMA ISLEMI I�IN GER�EKLESECEK ISLEMLER
;-----------------------------
	
ART 
	;birle ile toplama islemi
	INCF	BIR,F ;bir=bir+1, ba?lang?�ta ff di art?rd?k 00 oldu
	MOVLW	.10
	SUBWF	BIR,W ; 
	BTFSS	STATUS,Z ; registerdeki biti test et cikarma snucu sifirsa yani 1 ise bir sonraki komuta atla
	GOTO	ASON
	CLRF	BIR
	
	;on ile toplama islemi
	INCF	ON,F ; f saklay?c?s?n?n i�erisindeki de?eri 1 artt?r sonucu ona e yaz
	MOVLW	.10
	SUBWF	ON,W
	BTFSS	STATUS,Z ; statusun �n zero bitini test et
	GOTO	ASON
	CLRF	ON
	
	;yuz ile toplama i?lemi
	INCF	YUZ,F ; 
	MOVLW	.10
	SUBWF	YUZ,W
	BTFSS	STATUS,Z ;Z=0 ise alt sat?r? atlay?p SAYI
	GOTO	ASON
	CLRF	YUZ
	
	;y�zler ile toplama i?lemi
	INCF	BIN,F
	MOVLW	.10
	SUBWF	BIN,W
	BTFSS	STATUS,Z ; ta?ma var m? ? diye kontorl ediyorum ona g�re di?er basama?a ge�icem
	GOTO	ASON
	CLRF	BIN
ASON
	CALL	EKRAN
	BTFSS	PORTB,7 ; PORTB'nin 7 bitine bas?ld? m? ? yani 1 mi ?
	GOTO	ASON ;Evetse a?a?? ge� yani bunu yap
	GOTO	ANA; ba?a d�n
	
;------------------------------------------
;   AZALTMA ISLEMI GER�EKLESTIRMEK I�IN YAPILACAK ISLEMLER
;------------------------------------------
AZAL
	;Birler �ikartma islemi
	MOVLW	.1 ; W'ye 
	SUBWF	BIR,F ; bir-w yap sonucu bilgiye at
	BTFSC	STATUS,C; �ikarma sonucu s?f?rsa yani C=1 ise bir komut atla
	GOTO	ESON ; Eson a git
	CLRF	BIR
	;Onlar �ikartma islemi
	MOVLW	.1
	SUBWF	ON,F
	BTFSC	STATUS,C
	GOTO	BIR9
	CLRF	ON
	;Y�zler �ikartma islemi
	MOVLW	.1
	SUBWF	YUZ,F
	BTFSC	STATUS,C
	GOTO	ON9
	CLRF	YUZ
	;Binler �ikartma islemi
	MOVLW	.1
	SUBWF	BIN,F 
	BTFSC	STATUS,C
	GOTO	YUZ9
	CLRF	BIN
ESON	
	CALL	EKRAN ; Ekran fonksiyonunu �a??r
	BTFSS	PORTA,4;PortA 'n?n 4 �n bitine bas?ld? m? ?  yani 1 mi?
	GOTO	ESON;Evetse alta ge�ip bu i?lemi yap
	GOTO	ANA ; ba?a d�n

	
	
;----------
YUZ9
	MOVLW	.9
	MOVWF	YUZ
ON9
	MOVLW	.9
	MOVWF	ON
BIR9
	MOVLW	.9
	MOVWF	BIR

;-----------
ANA
	CALL	EKRAN ; Ekran fonksiyonunu �a??r
	BTFSS	PORTA,4; PortA 'n?n 4 �n bitine bas?ld? m? ?  yani 1 mi?
	GOTO	AZAL ; Evetse a?a??daki i?lemi yap
	BTFSS	PORTB,7 ; PORTB'nin 7 bitine bas?ld? m? ? yani 1 mi ?
	GOTO	ART ; Evetse artt?rma i?lemini yap
	GOTO	ANA ; d�ng�ne d�n s�rekli
;----------

	
	
	
	
EKRAN
	MOVLW	.5
	MOVWF	RAKAM
	CLRF	PORTB
	MOVLW	.255
	MOVWF	PORTA

;------------------------------------
;	   EKRANDA G�STERME ??LEMELER?
;------------------------------------	
	
GOSTER
	BCF	PORTA,0 ;0. biti 0 la 
	BSF	PORTA,1 ;1. biti set et
	BSF	PORTA,2 ;2. biti set et
	BSF	PORTA,3 ;3. biti set et
	MOVF    BIR,W
        CALL	TABLO ; her �a??r?ld???nda 1 artt?rarak geliyor ki nerde kald???n? bilsin W register?na at?yor retlf ile
	MOVWF   PORTB ; o da PORTB ye at?yor yani display kodunu buraya at?yor
	CALL	GECIKME ; belli bir s�re bekle
	CALL	GECIKME ; belli bir s�re bekle [Buray? koymam??t?m asl?nda ama bunsuz da �al??m?yor]
	CLRF	PORTB ; PORTB yi komple 0 yap bitlerini
	
	BSF	PORTA,0 ;0. biti set et
	BCF	PORTA,1 ;1. biti 0 la
	BSF	PORTA,2 ;2. biti set et
	BSF	PORTA,3 ;3. biti set et
	MOVF    ON,W
        CALL	TABLO ; her �a??r?ld???nda 1 artt?rarak geliyor ki nerde kald???n? bilsin W register?na at?yor retlf ile
	MOVWF   PORTB ; o da PORTB ye at?yor yani display kodunu buraya at?yor
	CALL	GECIKME ; belli bir s�re bekle
	CLRF	PORTB
	
	BSF	PORTA,0 ;0. biti set et
	BSF	PORTA,1 ;1. biti set et
	BCF	PORTA,2 ;2. biti 0 la
	BSF	PORTA,3 ;3. biti set et
	MOVF    YUZ,W
        CALL	TABLO ; her �a??r?ld???nda 1 artt?rarak geliyor ki nerde kald???n? bilsin W register?na at?yor retlf ile
	MOVWF   PORTB ; o da PORTB ye at?yor yani display kodunu buraya at?yor
	CALL	GECIKME ; belli bir s�re bekle
	CLRF	PORTB
	
	BSF	PORTA,0 ; 0. biti set et
	BSF	PORTA,1 ; 1. biti set et
	BSF	PORTA,2 ; 2. biti set et
	BCF	PORTA,3 ; 3. biti 0 la
	MOVF    BIN,W ; 
        CALL	TABLO ; ; her �agirildiginda 1 artt?rarak geliyor ki nerde kaldigini bilsin W registerina atiyor retlf ile
	MOVWF   PORTB ; o da PORTB ye at?yor yani display kodunu buraya at?yor
	CALL	GECIKME ; belli bir s�re bekle
	DECFSZ	RAKAM,F ;Rakam degerini 1 azalt sonucu file regist?r?na yaz
	GOTO	GOSTER ; donguye sok
	RETURN

	
;Tek d�ng�l� geceikme program?yla olu?an max gecikme az geldi ondan dolay? i�i i�e 2 tane yapt?m	
;---------------------------------------------------
;	    Gecikme alt programi
;---------------------------------------------------
	
GECIKME
	MOVLW	.5 ; 5 decimal say?s?n? w ye atad?m
	MOVWF	MSB ; w de?erini msb ye atad?m ve saya� olarak kullan?yorum MSB'yi
D11	
	MOVLW	.5 ; 5 decimal say?s?n? w ye atad?m
	MOVWF	LSB; w de?erini lsb ye atad?m ve saya� olarak kullan?yorum LSB
D22
	DECFSZ	LSB,F ; LSB'nin de?erini bir azalt sonucu F ye yaz
	GOTO	D22 ; e?er saya�(LSB) 0 de?il ise d22 ye git e?er 0 ise bir sonraki komuttan devam et
	DECFSZ	MSB,F ; MSB'nin de?erini bir azalt sonucu F ye yaz
	GOTO	D11 ; D11 e git
	RETURN ; de?er d�nd�rm�yor sadece �a??rd??? yere geliyor

;----------------------------------------------
;   KATOT D?SPLAY TABLOSU
;----------------------------------------------
TABLO
	ADDWF	PCL,F ;PCL=PCL+W  
		      ; Display kod d�n�s�m alt programi
		      ; Program sayisi verilen kod kadar arttir/azaltir. B�ylece o sat?rdaki de?eri d�nd�r�r
	RETLW	h'3F' ; alt programdan w ye bir say? ekle ve onu geri d�nd�r. 
	RETLW	h'06'
	RETLW	h'5B'
	RETLW	h'4F'
	RETLW	h'66'
	RETLW	h'6D'
	RETLW	h'7D'
	RETLW	h'07'
	RETLW	h'7F'
	RETLW	h'6F'
	RETLW	h'77'
	RETLW	h'7C'
	RETLW	h'39'
	RETLW	h'5E'
	RETLW	h'79'
	RETLW	h'71'
	RETLW	h'80'

;-------------------------------------------------------------------

	END ; Programin sonu


