/* Demo-blinky raudalle atmega 808

Yksinkertainen testi, vedetään jokainen "normaaleista" pinneistä
yksi kerrallaan ylös, niin voidaan skoopilla katsoa että onhan siru
kolvaantunut kunnolla: ei ole tassuja ilmassa (pulssia ei näy)
tai kolvautunut kiinni toisiinsa (pulssi on tuplasti pidempi kuin pitäisi
tai muuten vain oudon näköinen).
 */
#include <avr/io.h>

int main(void){
	/*
    Portit ulostuloiksi.
    Fiinimpi versio olisi että laitetaan pinni kerrallaan ulostuloksi
    ja olisi muutoin sisääntulo, jolloin saadaan varmemmin bongattua
    oikosulut: ei käy niin että yksi pinni ajaa toista ylös ja se toinen
    vetää itseään samaan tahtiin alas.
    */
    // PORT A: 8 kpl normaaleja pinnejä
    PORTA.DIR = 0xFF;
    // PORT B: Ei ole 32-pinnisessä
    // PORT C: Neljä pinniä
	PORTC.DIR = 0x0F;
    // PORT D: 8 kpl analogipinnejä
	PORTD.DIR = 0xFF;
    // PORT E: Ei ole 32-pinnisessä
    // PORT F: 0-5 enemmän tai vähemmän normaaleja, 6 on ~RESET
    PORTF.DIR = 0x1F;

    // Ikuinen looppi, käydään pinni kerrallaan lävitte että toimii varmasti.
    while(1){
        // PORTA-pinnit yksi kerrallaan ylös
        /* (knoppitieto: jos loopissa käyttää char sijaan int eikä laita kääntäjäflageja
        kuntoon, looppimuuttuja on 16 bit eli kasibittisellä arkkitehtuurilla kasvattaminen
        vaatii kaksivaiheisen ADDIW-ynnäyksen nopean INC sijaan)
        */
        for(char i=0; i<8; i++){
			PORTA.OUT = 1<<i;
        }
        // Vika alasvienti, muuten jää korkealle
        PORTA.OUT = 0;
        // Vastaavasti PORTC
        for(char i=0; i<4; i++){
            PORTC.OUT = 1<<i;
        }
        PORTC.OUT = 0;
        // PORTD
        for(char i=0; i<8; i++){
            PORTD.OUT = 1<<i;
        }
        PORTD.OUT = 0;
        // PORTF
        for(char i=0; i<6; i++){
            PORTF.OUT = 1<<i;
        }
        PORTF.OUT = 0;
    }
	return(0);
}
