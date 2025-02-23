# Käännä src/main.c, ei ole ihan maailman suoraviivaisin kun juttuja yleensä puuttuu välistä.
# Voi samaan syssyyn myös lähettää sarjaportilla sirulle.
# Pitäisi toimia suht suoraan, kunhan avr-gcc on asennettu ja riittävän moderni.
# ks. lisätietoja
# https://www.avrfreaks.net/s/topic/a5C3l000000UZmfEAG/t151347

# Suoritin jolle käännetään
MCU=atmega808

# Sarjaportti jolla kirjoitetaan (jos kirjoitetaan)
SERPORT=/dev/ttyAMA0

# Atmega808 device-specs (avr-gcc)
# (tämä riippuu systeemistä, tarkista missä oman avr-gcc:n librat sijaitsee)
LIB_AVRGCC=/lib/gcc/avr/5.4.0
DEVICE_SPECS=$(LIB_AVRGCC)/device-specs
ATPACK_FOLDER=$(shell pwd)/include/Atmel.ATmega_DFP.2.2.509
ATPACK_FILE=Atmel.ATmega_DFP.2.2.509.atpack
ATPACK_URL=http://packs.download.atmel.com/$(ATPACK_FILE)

# C-kääntäjä ja sen vaatimat vakiargumentit (suorittimen tyyppi ymv)
COMP=avr-gcc
COMPFLAGS=-mmcu=$(MCU) -B $(ATPACK_FOLDER)/gcc/dev/$(MCU) -isystem $(ATPACK_FOLDER)/include

# elffistä hexiksi
BINCOPY=avr-objcopy
BINFLAGS=-O ihex
KOHDEKANSIO=build
# Lopullinen tiedosto joka sirulle kirjoitetaan
HEKSATIEDOSTO=main.hex

# Käännä koodi ja muunna heksaksi
.PHONY all: $(KOHDEKANSIO) $(KOHDEKANSIO)/$(HEKSATIEDOSTO)

# Lähetä lopputuote sirulle
.PHONY send: all
	pymcuprog write --erase -d $(MCU) -t uart -u $(SERPORT) -c 115200 -f $(KOHDEKANSIO)/$(HEKSATIEDOSTO)

# Poista välivaihetiedostot
.PHONY clean:
	rm build/*.elf

# Käännä main.c main.elfiksi
$(KOHDEKANSIO)/main.elf: $(DEVICE_SPECS)/specs-$(MCU) $(ATPACK_FOLDER) src/main.c
	$(COMP) $(COMPFLAGS) -o $(KOHDEKANSIO)/main.elf src/main.c

# ulostulo.hex tuotto tarvitsee build/ulostulo.elf, luodaan kopiointiohjelmalla
$(KOHDEKANSIO)/$(HEKSATIEDOSTO): $(KOHDEKANSIO)/main.elf
	$(BINCOPY) $(BINFLAGS) $(KOHDEKANSIO)/main.elf $(KOHDEKANSIO)/$(HEKSATIEDOSTO)

# Kopioi device spec, sörkkii arkoja /lib-kansioita niin vaatii sudon
$(DEVICE_SPECS)/specs-$(MCU): $(ATPACK_FOLDER)
	sudo bash xfer-pack.sh $(ATPACK_FOLDER) $(LIB_AVRGCC)

# Build-kansion luonti jos uupuu
$(KOHDEKANSIO):
	mkdir -p $(KOHDEKANSIO)

# Atpack-include, lataa arkisto ja pura kansioon. Poista pakattu versio.
$(ATPACK_FOLDER): include
	curl -o $(ATPACK_FILE) $(ATPACK_URL)
	mkdir $(ATPACK_FOLDER)
	unzip $(ATPACK_FILE) -d $(ATPACK_FOLDER)
	rm $(ATPACK_FILE)

include:
	mkdir include
