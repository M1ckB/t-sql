/* ***********************

TEMPORARY TABLES

Udviklet af Thomas Lange & Mick Ahlmann Brun

Mere info: https://github.com/M1ckB/T-SQL

Version 1.0 2023-02-09

Laboratoriet kræver:

- En understøttet version af SQL Server
- En Stack Overflow database: https://www.BrentOzar.com/go/querystack (medium)

Læs mere om temporary tables i Microsofts T-SQL reference:

- https://learn.microsoft.com/en-us/sql/t-sql/statements/create-table-transact-sql?view=sql-server-ver16

Du kan finde løsninger og svar på opgaverne nederst i scriptet.

*********************** */

USE StackOverflow2013;
GO

/* ***********************

ØVELSER

*********************** */

/* 

OPGAVE 1.1: Find Id for de tre brugere med det højeste omdømme og
  gem resultatet som en midlertidig tabel.

- Tabeller involveret: dbo.Users
- Ønsket output:
Id
22656
157882
29407

*/

/* 

OPGAVE 1.2: Byg videre på forrige opgave. Indhent oplysninger om brugerne
  listet i den midlertidige tabel.

- Tabeller involveret: dbo.Users
- Ønsket output:
Id	    DisplayName	    Location	              CreationDate
22656	  Jon Skeet	      Reading, United Kingdom	2008-09-26 12.05.05.150
29407	  Darin Dimitrov	Sofia, Bulgaria	        2008-10-19 16.07.47.823
157882	BalusC	        Willemstad, Curaçao	    2009-08-17 16.42.02.403

*/

/*

OPGAVE 1.3: Slet din midlertidige tabel.

*/

/* ***********************

LØSNINGER

*********************** */

/* OPGAVE 1.1 */

SELECT TOP (3)
  Id
INTO #UsersWithHighRep
FROM dbo.Users
ORDER BY Reputation DESC;

SELECT * FROM #UsersWithHighRep;

/* OPGAVE 1.2 */

SELECT
  Id,
  DisplayName,
  [Location],
  CreationDate
FROM dbo.Users
WHERE Id IN (SELECT Id FROM #UsersWithHighRep);

/* OPGAVE 1.3 */

DROP TABLE #UsersWithHighRep;

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