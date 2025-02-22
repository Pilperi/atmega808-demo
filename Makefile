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
ATPACK_URL=http://packs.download.atmel.com/Atmel.ATmega_DFP.2.2.509.atpack

# C-kääntäjä ja sen vaatimat vakiargumentit (suorittimen tyyppi ymv)
COMP=avr-gcc-5.4.0
COMPFLAGS=-mmcu=$(MCU) -B $(ATPACK_FOLDER)/gcc/dev/$(MCU) -isystem $(ATPACK_FOLDER)/include

# elffistä hexiksi
BINCOPY=avr-objcopy
BINFLAGS=-O ihex
KOHDEKANSIO=build

# Käännä koodi ja muunna heksaksi
.PHONY all: $(KOHDEKANSIO) $(KOHDEKANSIO)/ulostulo.hex

# Lähetä lopputuote sirulle
.PHONY send: all
	pymcuprog write --erase -d $(MCU) -t uart -u $(SERPORT) -c 115200 -f $(KOHDEKANSIO)/ulostulo.hex

# Poista välivaihetiedostot
.PHONY clean:
	rm build/*.elf

# Käännä main.c main.o:ksi
$(KOHDEKANSIO)/ulostulo.elf: $(DEVICE_SPECS)/specs-$(MCU) $(ATPACK_FOLDER) src/main.c
	$(COMP) $(COMPFLAGS) -o build/ulostulo.elf src/main.c

# ulostulo.hex tuotto tarvitsee build/ulostulo.elf, luodaan kopiointiohjelmalla
$(KOHDEKANSIO)/ulostulo.hex: $(KOHDEKANSIO)/ulostulo.elf
	$(BINCOPY) $(BINFLAGS) $(KOHDEKANSIO)/ulostulo.elf $(KOHDEKANSIO)/ulostulo.hex

# Kopioi device spec, sörkkii arkoja /lib-kansioita niin vaatii sudon
$(DEVICE_SPECS)/specs-$(MCU): $(ATPACK_FOLDER)
	sudo bash xfer-pack.sh $(ATPACK_FOLDER) $(LIB_AVRGCC)

# Build-kansion luonti jos uupuu
$(KOHDEKANSIO):
	mkdir -p $(KOHDEKANSIO)

# Atpack-include, lataa arkisto ja pura kansioon. Poista pakattu versio.
$(ATPACK_FOLDER): include
	curl -o Atmel.ATautomotive_DFP.2.0.214.atpack $(ATPACK_URL)
	mkdir $(ATPACK_FOLDER)
	unzip Atmel.ATautomotive_DFP.2.0.214.atpack -d $(ATPACK_FOLDER)
	rm Atmel.ATautomotive_DFP.2.0.214.atpack

include:
	mkdir include
