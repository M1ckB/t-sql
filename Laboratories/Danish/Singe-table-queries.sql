/* ***********************

SINGLE TABLE-QUERIES

Udviklet af Thomas Lange & Mick Ahlmann Brun

Mere info: https://github.com/M1ckB/T-SQL

Version 1.0 2023-02-09

Laboratoriet kræver:

- En understøttet version af SQL Server
- En Stack Overflow database: https://www.BrentOzar.com/go/querystack (medium)

Læs mere om single table-queries i Microsofts T-SQL reference:

- https://learn.microsoft.com/en-us/sql/t-sql/queries/select-transact-sql?view=sql-server-ver16

Du kan finde løsninger og svar på opgaverne nederst i scriptet.

*********************** */

USE StackOverflow2013;
GO

/* ***********************

ØVELSER

*********************** */

/* 

OPGAVE 1: Find brugere fra Californien ('California'),

- Tabeller involveret: dbo.Users
- Ønsket output:
Id	  DisplayName	Location
23961	humble_guru	California
23970	Shishiree	  California
23973	willc2	    California
...
(2.878 rows)

*/

/*

OPGAVE 2.1: Find antallet af brugere for hver lokation. Sorter resultattabellen aftagende i forhold til antallet af brugere.

- Tabeller involveret: dbo.Users
- Ønsket output:
Location	CountOfUsers
NULL	    1876207
	        17144
India	    15472
...
(44.881 rows)

*/

/* OPGAVE 2.2: Byg videre på forrige opgave. Frasorter nu ukendte (NULL) og tomme lokationer ('') fra resultattabellen.

- Tabeller involveret: dbo.Users
- Ønsket output:
Location	              CountOfUsers
India	                  15472
London, United Kingdom	8753
United States	          8704
...
(44.879 rows)

*/

/* OPGAVE 2.3: Byg videre på forrige opgave. Frasorter nu lokationer med færre end 5.000 brugere fra resultattabellen.

- Tabeller involveret: dbo.Users
- Ønsket output:
Location	              CountOfUsers
India	                  15472
London, United Kingdom	8753
United States	          8704
...
(6 rows)

*/

/* OPGAVE 3: Hvad er forskellen på betingelser i WHERE- og HAVING-delsætningerne? */

/* OPGAVE 4.1: Find brugere hvis displaynavn starter med 'Jes'.

- Tabeller involveret: dbo.Users
- Ønsket output:
Id	  DisplayName
49609	jessemiel
53571	Jesse
54184	Jesse
...
(2.750 rows)

*/


/* OPGAVE 4.2: Byg videre på forrige opgave. Den fjerde karakter i displaynavnet skal være enten 't' eller 'u'.

- Tabeller involveret: dbo.Users
- Ønsket output:
Id	    DisplayName
88501	  Jesus Jimenez
255868	Jesus
271783	jester
...
(419 rows)

*/

/* 

OPGAVE 5: Find brugere som er oprettet i januar 2012.

- Tabeller involveret: dbo.Users
- Ønsket output:
Id	    DisplayName	Location	        CreationDate
1124759	essbek	    NULL	            2012-01-01 00.00.17.010
1124761	Freon	      NULL	            2012-01-01 00.04.48.293
1124764	LONGMAN     Tbilisi, Georgia	2012-01-01 00.08.14.500
...
(35.158 rows)

*/

/*

OPGAVE 6: Find brugere som er oprettet den sidste dag i en måned.

- Tabeller involveret: dbo.Users
- Ønsket output:
Id	  DisplayName	    CreationDate
23864	Tooony	        2008-09-30 17.41.28.537
23866	Keith Twombley	2008-09-30 17.50.57.003
23869	regex	          2008-09-30 17.55.05.760
...
(77.881)

*/

/* OPGAVE 7: Find de tre posts der har de højeste scores på hele Stack Overflow. 

- Tabeller involveret: dbo.Posts 
- Ønsket output:
Id	      Title	                                                              Score
11227809	Why is it faster to process a sorted array than an unsorted array?	21775
927358	  How to undo the most recent commits in Git?	                        17970
2003505	  How do I delete a Git branch both locally and remotely?	            13957
(3 rows)

*/

/* OPGAVE 8: Beregn for hver bruger en ny kolonne som fortæller om brugeren har været aktiv baseret
  på brugerens omdømme. Såfremt brugeren har et omdømme større end 1, så betragtes denne som værende
  aktiv ('Yes') og ellers ikke aktiv ('No').

- Tabeller involveret: dbo.Users
- Ønsket output:  
Id	DisplayName	  Reputation	IsUserActive
-1	Community	    1	          No
1	  Jeff Atwood	  44300	      Yes
2	  Geoff Dalgas	3491	      Yes
...
(2.465.713 rows)  

*/

/* ***********************

LØSNINGER

*********************** */

/* OPGAVE 1 */

SELECT
  Id,
  [DisplayName],
  [Location]
FROM dbo.Users
WHERE [Location] = 'California';

/* OPGAVE 2.1 */

SELECT
  [Location],
  COUNT(*) AS CountOfUsers
FROM dbo.Users
GROUP BY [Location]
ORDER BY CountOfUsers DESC;

/* OPGAVE 2.2 */

SELECT
  [Location],
  COUNT(*) AS CountOfUsers
FROM dbo.Users
WHERE [Location] IS NOT NULL AND [Location] <> ''
GROUP BY [Location]
ORDER BY CountOfUsers DESC;

/* OPGAVE 2.3 */

SELECT
  [Location],
  COUNT(*) AS CountOfUsers
FROM dbo.Users
WHERE [Location] IS NOT NULL AND [Location] <> ''
GROUP BY [Location]
HAVING COUNT(*) > 5000
ORDER BY CountOfUsers DESC;

/* OPGAVE 3 */

/* WHERE-delsætningen er et rækkefilter, mens HAVING-delsætningen er et gruppefilter i en forespørgsel. */

/* OPGAVE 4.1 */

SELECT
  Id,
  DisplayName
FROM dbo.Users
WHERE DisplayName LIKE 'Jes%';

/* OPGAVE 4.2 */

SELECT
  Id,
  DisplayName
FROM dbo.Users
WHERE DisplayName LIKE 'Jes[tu]%';

/* OPGAVE 5 */

/* Bemærk at YEAR- og MONTH-funktionerne også kan benyttes til at løse problemet, men at disse hindrer brugen af eventuelle indeks. Man siger at
  et udtryk ikke er sargable (Search ARGument Able), dvs. at Query Optimizeren ikke kan gøre brug af en ordnet struktur, fx et indeks, til hurtigere
  eksekvering af en forespørgsel. Et par Stack Overflow-brugere giver gode eksempler på dette: https://stackoverflow.com/questions/799584 */

SELECT
  Id,
  DisplayName,
  [Location],
  CreationDate
FROM dbo.Users
WHERE CreationDate >= '20120101'
AND CreationDate < '20120201';

/* OPGAVE 6 */

/* Bemærk at der er mismatch i datatyperne. Når dette sker vil SQL Server selv forsøge at autokonvertere
  hvor dette er nødvendigt for at kunne lave sammenligninger. For at kunne løse opgaven bliver vi nødt
  til at typecaste CreationDate til datatypen date i stedet for datetime. */

SELECT
  Id,
  DisplayName,
  CreationDate
FROM dbo.Users
WHERE CAST(CreationDate AS date) = EOMONTH(CreationDate);

/* OPGAVE 7 */

SELECT TOP (3)
  Id,
  Title,
  Score
FROM dbo.Posts
WHERE PostTypeId = 1
ORDER BY Score DESC;

/* OPGAVE 8 */

SELECT
  Id,
  DisplayName,
  Reputation,
  CASE
    WHEN Reputation > 1 THEN 'Yes'
    ELSE 'No'
  END AS IsUserActive
FROM dbo.Users;

/* ***********************

LICENS

Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)

Mere info: https://creativecommons.org/licenses/by-sa/4.0/

Du kan frit:

- Dele: kopiere og distribuere materialet via ethvert medium og i ethvert format
- Tilpasse: remixe, redigere og bygge på materialet til ethvert formål, selv erhvervsmæssigt

Under følgende betingelser:

- Kreditering: Du skal kreditere, dele et link til licensen og indikere om der er lavet ændringer.
- Del på samme vilkår: Hvis du remixer, redigerer eller bygger på materialet, så skal dine bidrag
  distribueres under samme licens som den originale.

*********************** */