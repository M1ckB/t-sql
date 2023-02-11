/* ***********************

PIVOT OG UNPIVOT

Udviklet af Thomas Lange & Mick Ahlmann Brun

Mere info: https://github.com/M1ckB/T-SQL
 
Version 1.0 2023-01-17

Laboratoriet kræver:

- En understøttet version af SQL Server
- En Stack Overflow database: https://www.BrentOzar.com/go/querystack (medium)

Læs mere om set-operatorerne i Microsofts T-SQL reference:

- https://learn.microsoft.com/en-us/sql/t-sql/queries/from-using-pivot-and-unpivot?view=sql-server-ver16

Du kan finde løsninger og svar på opgaverne nederst i scriptet.

*********************** */

USE StackOverflow2013;
GO

/* ***********************

ØVELSER

*********************** */

/*Nedenstående script danner en temporær tabel,  #postbyusertype,  som indeholder fire kolonner for poster,  som er lukkede:
  PostClosedYear = Året hvor posten i dbo.Posts lukkedes
  UserType = 'Superuser' hvis Reputation i dbo.Users >= 10.000; 'User' ellers
  ViewCount = Antal visninger af posten i dbo.Posts 

SELECT YEAR(p.ClosedDate) AS PostClosedYear,  CASE WHEN u.Reputation>=10000 THEN 'Superuser' ELSE 'User' END AS UserType,  p.ViewCount
INTO #viewsbyusertypes
FROM dbo.Posts p 
INNER JOIN dbo.Users u ON u.Id=p.OwnerUserId
WHERE p.ClosedDate IS NOT NULL;

OPGAVE 1: Du skal optælle det gennemsnitlige antal visninger for Users og Superusers fordelt på antal
  år med brug af PIVOT-operatoren...

  Før du får lov at skrive et script,  skal du svare på,  hvad der er:
  Grupperingselementet?
  Spredningselementet? 
  Aggregeringselementet? 
  Aggregeringsfunktionen?

*/


/*

OPGAVE 2: Skriv en forespørgsel med brug af PIVOT-operatoren,  som danner det ønskede output.

- Tabeller involveret: #postsbyusertype (eller,  om vil dbo.Posts og dbo.Users)
- Ønsket output:
PostClosedYear	User	Superuser
2008	          7895	5460
2009	          9876	13478
2010	          4934	11035
...
(11 rows)
*/


/*

OPGAVE 3: Dream-data med utroligt mange kolonner....

Kør først dette script for at danne en Dream-data mockup. Når du har kørt scriptet, har du en temporær tabel, #DreamData, som indeholder et CPRNR, samt 12 kolonner for ARBSTED i hver måned i 2008. 
I virkeligheden indeholder DREAM-data 180 kolonner med ARBSTED, nemlig én for hver måned i årene 2008-2022... 

SELECT CPRNR, ARBSTED_2008_01, ARBSTED_2008_02, ARBSTED_2008_03, ARBSTED_2008_04, ARBSTED_2008_05, ARBSTED_2008_06, ARBSTED_2008_07, ARBSTED_2008_08, ARBSTED_2008_09, ARBSTED_2008_10, ARBSTED_2008_11, ARBSTED_2008_12
INTO #DreamData
FROM (VALUES(1234567890, 000, 000, 000, 000, 511, 511, 511, 511, 912, 912, 912, 912)
          , (1234567891, 700, 700, 700, 700, 700, 703, 703, 703, 703, 703, 703, 723)
          , (1234567892, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 000)
          , (1234567893, 000, 000, 111, 11, 511, 511, 511, 511, 912, 912, 730, 730)) AS DREAM(CPRNR, ARBSTED_2008_01, ARBSTED_2008_02, ARBSTED_2008_03, ARBSTED_2008_04, ARBSTED_2008_05, ARBSTED_2008_06, ARBSTED_2008_07, ARBSTED_2008_08, ARBSTED_2008_09, ARBSTED_2008_10, ARBSTED_2008_11, ARBSTED_2008_12);


3.a Skriv nu et script, som roterer data, så det kommer på denne form:
CPRNR	      ARBSTED_YYYY_MM	ARBSTED
1234567890	ARBSTED_2008_01	0
1234567890	ARBSTED_2008_02	0
1234567890	ARBSTED_2008_03	0
(48 rows)

3.b Modificer dit script, så tabellen kommer på denne form:
CPRNR	      YYYY	MM	ARBSTED
1234567890	2008	01	0
1234567890	2008	02	0
1234567890	2008	03	0
(48 rows)

*/

/* ***********************

LØSNINGER

*********************** */

/* Bemærk hvorledes forskellige metoder kan bruges til at opnå det samme resultat,  men at
  nogle metoder er mere effektive og kompakte */

SELECT YEAR(p.ClosedDate) AS PostClosedYear,  CASE WHEN u.Reputation>=10000 THEN 'Superuser' ELSE 'User' END AS UserType,  p.ViewCount
INTO #viewsbyusertypes
FROM dbo.Posts p 
INNER JOIN dbo.Users u ON u.Id=p.OwnerUserId
WHERE p.ClosedDate IS NOT NULL;

/* OPGAVE 1 */
/*
Grupperingselementet   = PostClosedYear
Spredningselementet    = UserType
Aggregeringselementet  = ViewCount
Aggregeringsfunktionen = AVG()
*/



/* OPGAVE 2 */

SELECT PostClosedYear,  [User],  [Superuser]
FROM #viewsbyusertypes
PIVOT(AVG(ViewCount) FOR UserType IN ([User], [Superuser])) p;

DROP TABLE #viewsbyusertypes;

/* OPGAVE 3 */

SELECT CPRNR, ARBSTED_2008_01, ARBSTED_2008_02, ARBSTED_2008_03, ARBSTED_2008_04, ARBSTED_2008_05, ARBSTED_2008_06, ARBSTED_2008_07, ARBSTED_2008_08, ARBSTED_2008_09, ARBSTED_2008_10, ARBSTED_2008_11, ARBSTED_2008_12
INTO #DreamData
FROM (VALUES(1234567890, 000, 000, 000, 000, 511, 511, 511, 511, 912, 912, 912, 912)
          , (1234567891, 700, 700, 700, 700, 700, 703, 703, 703, 703, 703, 703, 723)
          , (1234567892, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 000)
          , (1234567893, 000, 000, 111, 11, 511, 511, 511, 511, 912, 912, 730, 730)) AS DREAM(CPRNR, ARBSTED_2008_01, ARBSTED_2008_02, ARBSTED_2008_03, ARBSTED_2008_04, ARBSTED_2008_05, ARBSTED_2008_06, ARBSTED_2008_07, ARBSTED_2008_08, ARBSTED_2008_09, ARBSTED_2008_10, ARBSTED_2008_11, ARBSTED_2008_12);

SELECT * FROM #DreamData;

--3.a
SELECT CPRNR, ARBSTED_YYYY_MM, [ARBSTED]
FROM #DreamData 
UNPIVOT ([ARBSTED] FOR ARBSTED_YYYY_MM IN (ARBSTED_2008_01, ARBSTED_2008_02, ARBSTED_2008_03, ARBSTED_2008_04, ARBSTED_2008_05, ARBSTED_2008_06, ARBSTED_2008_07, ARBSTED_2008_08, ARBSTED_2008_09, ARBSTED_2008_10, ARBSTED_2008_11, ARBSTED_2008_12)) d;

--3.b
SELECT CPRNR, SUBSTRING(ARBSTED_YYYY_MM, 9 ,4) AS YYYY, RIGHT(ARBSTED_YYYY_MM,2) AS MM, [ARBSTED]
FROM #DreamData 
UNPIVOT ([ARBSTED] FOR ARBSTED_YYYY_MM IN (ARBSTED_2008_01, ARBSTED_2008_02, ARBSTED_2008_03, ARBSTED_2008_04, ARBSTED_2008_05, ARBSTED_2008_06, ARBSTED_2008_07, ARBSTED_2008_08, ARBSTED_2008_09, ARBSTED_2008_10, ARBSTED_2008_11, ARBSTED_2008_12)) d;

DROP TABLE #DreamData; 

/* ***********************

LICENS

Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)

Mere info: https://creativecommons.org/licenses/by-sa/4.0/

Du kan frit:

- Dele: kopiere og distribuere materialet via ethvert medium og i ethvert format
- Tilpasse: remixe,  redigere og bygge på materialet til ethvert formål,  selv erhvervsmæssigt

Under følgende betingelser:

- Kreditering: Du skal kreditere,  dele et link til licensen og indikere om der er lavet ændringer.
- Del på samme vilkår: Hvis du remixer,  redigerer eller bygger på materialet,  så skal dine bidrag
  distribueres under samme licens som den originale.

*********************** */