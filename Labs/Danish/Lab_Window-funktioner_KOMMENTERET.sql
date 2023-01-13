/* ***********************

Kursus: SQL Basis 2
Emne: Window-funktioner
Version: 1.0
Dato: 2023-01-11

Laboratoriet kræver:

- En understøttet version af SQL Server
- En Stack Overflow database: https://www.BrentOzar.com/go/querystack

Agenda:

- Introduktion til konceptet om window-funktioner, deres opbygning og delsætninger
- Introduktion til forskellige familier af window-funktioner
- Eksempler på løsningsmønstre med window-funktioner

Læs mere om window funktioner i Microsofts T-SQL reference:

- https://learn.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql?view=sql-server-ver16

*/

USE StackOverflow2013;
GO

/* ***********************

Introduktion til window-funktioner:

- Windowing bruges som et effektivt og fleksibelt værktøj til analytiske formål
- Window-funktioner er, i sin essens, nogle funktioner som for hver række laver en beregning over en mængde
    af rækker relateret til den aktuelle række
- Mængden af rækker som der laves en beregning henover, kaldes et vindue ("window")
- Modsat vores grupperede forespørgsler, så kan vi med window-funktioner bevare detaljen. Derudover
    kan man også definere en orden i sin beregning

*/

/* [
    - Vis eksempler som illustrerer hvordan window-funktioner fungerer vis-a-vis grupperede forespørgsler
    - Brug annoteringsværktøj til at tegne selve vinduet og evt. ordenen for en forespørgsel
   ]
*/

/* [Mockup] */

/* [Stack Overflow] */

/*

Opgave X:

- Tabeller involveret:  
- Ønsket output:        

*/

/* ***********************

Opbygningen af window-funktioner:

Window-funktioner er overordnet opbygget af to elementer:
    1. Funktionen, eller beregningen, som ønskes foretaget, fx COUNT, RANK eller FIRST_VALUE
    2. Specifikationen af selve vinduet i OVER-delsætningen

SELECT
    <funktion> OVER (
        PARTITION BY <opdelingskolonner>
        ORDER BY <sorteringskolonner>
        ROWS/RANGE BETWEEN <øvre grænse> AND <nedre grænse>
    ) AS Beregning

OVER-delsætningen giver følgende muligheder for at specificere vinduet:

- Partitioning: Bruges til at opdele forespørgslen i grupper, eller vinduer, som beregningen foretages for.
    Hvis ikke denne angives, så laves beregningen for hele forespørgslen
- Ordering: Bruges til at bestemme ordenen som rækker evalueres i inden for en window-frame
- Framing: Bruges til udvælge en delmængde af rækker inden for en window-partiton

Bemærk, at ikke alle muligheder kan tages i brug for alle funktioner.

*/

/* [Med udgangspunkt i det samme eksempel ændres specifikationen af vinduet og konsekvenserne noteres] */

/* [Mockup] */

/* [Stack Overflow] */

/*

Opgave X:

- Tabeller involveret:  
- Ønsket output:        

*/

/* ***********************

Logisk processering af window-funktioner i forespørgsel:

I vores logiske processering af en forespørgsel evalueres window-funktioner på følgende trin (markeret
    med X):

1. FROM
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT
    5.1 Evaluering af udtryk (X)
    5.2 Fjernelse af dubletter
6. ORDER BY (X)
7. OFFSET-FETCH/TOP

Dvs. i udgangspunktet understøttes window-funktioner udelukkende i SELECT- og ORDER BY-delsætningerne.
    Denne begrænsning skal sikre entydighed omkring hvilken underliggende tabel der laves beregninger på.

Hvis vi ønsker at bruge window-funktioner i andre delsætninger, så bliver vi nødt til at lave beregninger
    trinvist.

*/

/* [
    - Med udgangspunkt i det samme eksempel flyttes window-funktionen til forskellige delsætninger for at
        undersøge hvor den virker
    - Vis eksempel på hvordan tolkningen af window-funktioner ikke er entydig hvis den blev evalueret logisk
        i en anden fase
    - Vis eksempel på window-funktioner og samspillet med DISTINCT
    - Vis eksempel på hvordan window-funktioner alligevel kan tages i brug i andre delsætninger, fx via
        en CTE
    ] */

/* [Mockup] */

/* [Stack Overflow] */

/*

Opgave X:

- Tabeller involveret:  
- Ønsket output:        

*/

/* ***********************

Introduktion til familier af window-funktioner:

Der findes forskellige familier af window-funktioner:

- Ranking
- Offset
- Aggregering
- (Statistik)

*/

/* [
    - Vis et eksempel med hver af de tre første familier af funktioner og nævn blot den sidste
    - Læg vægt på:
        1. De forskellige beregningsmuligheder
        2. Hvilke vinduesspecifikationer som understøttes
    ] */

/* [Mockup] */

/* [Stack Overflow] */

/*

Opgave X:

- Tabeller involveret:  
- Ønsket output:        

*/

/* ***********************

Løsningsmønstre med window-funktioner:

Window-funktioner kan bruges til at løse mange forskellige typer af opgaver. Nedenfor er gennemgået et par
    eksempler til løsning af klassiske udfordringer:

- TOP N per gruppe
- Kumulative værdier
- Huller og øer

*/

/* [Kommentar] */

/* [Mockup] */

/* [Stack Overflow] */

/*

Opgave X:

- Tabeller involveret:  
- Ønsket output:        

*/

/* ***********************

Hovedpointer:

- Window-funktioner er et uundværligt værktøj til analytikeren
- Window-funktioner laver, for hver række, en beregning over en mængde af rækker relateret til den
    aktuelle række
- En window-funktion består af følgende elementer:
    1. En funktion, fx COUNT, RANK eller FIRST_VALUE
    2. En specifikation af et vindue i OVER-delsætningen via Partitioning, Odering og Framing
- Window-funktioner evalueres logisk i SELECT- og ORDER BY-delsætningerne
- Der findes forskellige typer af window-funktioner, herunder funktioner til ranking, offset,
    aggregeringer og statistik

*/
