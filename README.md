2025-02-23
# Atmega808 blinky

## Yksinkertainen demo Atmega808-sirun paljaan raudan ohjelmointiin

Ostin taannoin kasan Atmega808-siruja, mutten saanut niitä ohjelmoitua. Tein kehityskortin ja opettelin ohjelmoimaan siruja UPDI:llä. Tässä tiivistelmä prosessista.

## PCB
Kehityskortti on yksinkertainen, käytännössä pelkkä pinout sirun pinneille. Sirun lähellä on käyttökelpoiset portit jaoteltuna (PORTA, PORTC, PORTD, PORTF). Portin eka pinni on portin nimen päädyssä, korostettuna.
Kortin reunalla on ei-GPIO:t ominaisuudet, lähinnä virransyöttö- ja ohjelmointipinnit. Vin on ohjattu jänniteregulaattorin sisääntuloon ja 3.3 regulaattorin ulostuloon, joka myös yhteydessä sirun VDD:hen. Toisin sanottuna sirua voi ajaa myös syöttämällä virtaa suoraan 3.3-pinniin. Samannimiset pinnit on yhteydessä toisiinsa.
Kortin gerberit on pcb-kansion alla, ymmärtääkseni niillä saa tilattua suoraan PCBWayltä tai vastaavasta mestasta.

<img src="img/piirilevy.png" width="700"></img>

## Sirun ohjelmointi
Sirun ohjelmointirajapinta on UPDI. Se on siitä näppärä, että se on käytännössä sarjaporttiprotokolla, mutta yhdellä pinnillä. Toisin sanottuna on ohjelmia joilla sirun kanssa voi jutella standardilla sarjaportilla, esim. Raspberry pin sarjaporttipinneillä, kunhan kytkee TX ja RX väliin diodin (saadaan yhdestä pinnistä kaksisuuntaista kommunikointia).
Käytin Microchipin virallista(?) Python-pohjaista `pymcuprog`: https://github.com/microchip-pic-avr-tools/pymcuprog
Se on erittäin helppokäyttöinen, kunhan muistaa kirjoittaessa laittaa mukaan flagin `--erase`, eli

`pymcuprog write --erase -d atmega808 -t uart -u /dev/ttyAMA0 -c 115200 -f ulostulo.hex`

Käytin vähän turhan monta tuntia debuggaamiseen kun koodi näytti kääntyvän ja siru ohjelmoituvan, mutta mitään ei näkynyt skoopissa...
Kytkentäkaavio on esitetty alla.

<img src="img/kytkenta_raspi.png" width="700"></img>

Piirilevy peittää osan, mutta sen alla 3.3-pinni on kytketty raspin 3.3 V ulostuloon ja GND maahan.
Raspin TX- ja RX-pinnien välissä on diodi, katodi TX-pinniin (P8) päin ja anodi RX-pinniin (P10). En vieläkään ihan hiffaa miksi se toimii näin päin (eikö pitäisi olla just toiste päin..?), mutta kerta se pelittää ja toiste päin ei pelitä niin en tähän koske.

## Koodin kääntäminen
Kääntäminen on tosi helppoa jos käyttää Windowsia ja Microchip Studiota, ja aika mutkaista raspilla. AVR-GCC on jotenkin tosi jäljessä kaikesta mitä Microchip puuhastelee, eikä Atmega808 ole suoraan tuettu arkkitehtuuri.
Käytännössä ongelma on se, että GCC:n kirjastoissa ei ole sirulle oikeita headereita, eli ei voi esim. `#include <avr/io.h>` mikä hidastaa hommailua aika tosi tehokkaasti. Itse arkkitehtuuri on toki tuettu (`avrxmega3` IIRC), eli VOI vaan tehdä omat headerit ja kirjoitella rekistereihin suoraan näiden muistiosotteiden perusteella.
Microchipin omat määritelmät on onneksi netissä vapaasti ladattavissa, eli ne voi sieltä kiskoa. <a href="https://www.avrfreaks.net/s/topic/a5C3l000000UZmfEAG/t151347">Tässä ketjussa</a> kuvattu koko asennusketju kivasti, mutta kokosin homman myös `Makefile` puolelle.

Esimerkiksi väsäsin "laajennetun blinkyn", joka vetää GPIO-pinneistä kunkin vuorollaan ylös. Kortti kun on käsin kolvattu niin hyvä keino skoopilla tarkistaa että onhan kaikki kontaktit kunnossa.
Kunhan on `avr-gcc` tarpeeksi uutena versiona asennettuna, pitäisi `make` hoitaa homma loppuun: se
- Kiskoo Microchipin sivuilta Atmega808 määritykset (device-spec, io-headerit ymv)
- Tuuppaa speksitiedostot paikalleen GCC:n librakansioon
- Kääntää koodin käyttäen include-kansion sisältöä tukena
Katso Makefilen sisältä yksityiskohdat, ja tarkista että kansiot ja avr-gcc-kutsu on oikein.
Bonuksena mukana on send-vaihtoehto, eli `make send` kääntää ja lähettää käännetyn koodin sirulle.
Jos koodi toimii, skoopilta kun katsoo kahden vierekkäisen pinnin signaalia niin pitäisi näyttää suunnilleen tältä

<img src="img/kytkenta_raspi.png" width="700"></img>
