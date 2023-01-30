/* ***********************

SUBQUERIES

Udviklet af Thomas Lange & Mick Ahlmann Brun

Mere info: https://github.com/M1ckB/T-SQL

Version 1.0 2023-01-25

Laboratoriet kræver:

- En understøttet version af SQL Server
- En Stack Overflow database: https://www.BrentOzar.com/go/querystack (medium)

Læs mere om subqueries i Microsofts T-SQL reference:

- https://learn.microsoft.com/en-us/sql/relational-databases/performance/subqueries?view=sql-server-ver16

Du kan finde løsninger og svar på opgaverne nederst i scriptet.

*********************** */

USE StackOverflow2013;
GO

/* ***********************

ØVELSER

*********************** */

/* 

OPGAVE 1: Find spørgsmål der blev oprettet den sidste dag hvor der er blevet lavet indlæg.

- Tabeller involveret: dbo.Posts
- Ønsket output:
Id	      CreationDate	          Title
20849618	2013-12-31 00.00.16.283	Windows 8 Tortoise SVN connection issue
20849622	2013-12-31 00.00.28.357	Python: Executing other files
20849623	2013-12-31 00.00.47.340	Django Tastypie 'All_WITH_RELATIONS' is not defined
...
(4.234 rows)

*/

/*

OPGAVE 2: Find brugere som ikke har oprettet nogle indlæg fra 2013 og frem.

- Tabeller involveret: dbo.Users og dbo.Posts
- Ønsket output:
Id	  DisplayName	    Location
45095	David DeHaven	  United States
45097	Gyuri           United States
45114	Michael Bishop	Northampton, MA
...
(1.691.092 rows)

*/

/*

OPGAVE 3: Find ud af hvor mange spørgsmål der ingen kommentarer har.

- Tabeller involveret: dbo.Posts og dbo.Comments
- Ønsket output:
CountQuestionsWithNoComments
2901362
(1 row)

*/

/*

OPGAVE 4: Find for hver bruger indlæg fra den sidste dag hvor brugeren har lavet indlæg.
- Tabeller involveret: dbo.Posts
- Ønsket output:
Id	  OwnerUserId	CreationDate	          Title
9932	1217	      2008-08-13 15.16.50.713	What is a good way...
17870	2116	      2008-08-20 12.58.51.513	Select ..... where...
16402	652	        2008-08-19 15.26.40.287	Easy installation ...
...
(923.499 rows)

*/

/*

OPGAVE 5: Find brugere som har besvaret spørgsmål, men ikke har stillet nogle selv.

- Tabeller involveret: dbo.Users og dbo.Posts
- Ønsket output:
Id	    DisplayName	  Location
378304	Jim C         San Francisco, CA
1935106	Adam Wheeler	NYC
2731815	manas kumar	  Bhubaneswar,
...
(347.297 rows)

*/

/* OPGAVE 6: Forklar forskellen på IN og EXISTS. */

/* ***********************

LØSNINGER

*********************** */

/* OPGAVE 1 */

SELECT
  Id,
  CreationDate,
  Title
FROM dbo.Posts
WHERE PostTypeId = 1 /* Question */
AND CAST(CreationDate AS date) = (
  SELECT CAST(MAX(CreationDate) AS date)
  FROM dbo.Posts
);

/* OPGAVE 2 */

SELECT
  Id,
  DisplayName,
  [Location]
FROM dbo.Users
WHERE Id NOT IN (
  SELECT OwnerUserId
  FROM dbo.Posts
  WHERE CreationDate >= CAST('2013-01-01' AS datetime)
);

/* OPGAVE 3 */

SELECT
  COUNT(*) AS CountQuestionsWithNoComments
FROM dbo.Posts
WHERE PostTypeId = 1 /* Question */
AND Id NOT IN (
  SELECT PostId
  FROM dbo.Comments
);

/* OPGAVE 4 */

SELECT
  Id,
  OwnerUserId,
  CreationDate,
  Title
FROM dbo.Posts AS p1
WHERE CAST(CreationDate AS date) = (
  SELECT CAST(MAX(CreationDate) AS date)
  FROM dbo.Posts AS p2
  WHERE p2.OwnerUserId = p1.OwnerUserId
);

/* OPGAVE 5 */

SELECT
  Id,
  DisplayName,
  [Location]
FROM dbo.Users AS u
WHERE EXISTS (
  /* Answers provided */
  SELECT *
  FROM dbo.Posts AS p
  WHERE p.OwnerUserId = u.Id
  AND p.PostTypeId = 2
)
AND NOT EXISTS (
  /*  Questions asked */
  SELECT *
  FROM dbo.Posts AS p
  WHERE p.OwnerUserId = u.Id
  AND p.PostTypeId = 1
);

/* OPGAVE 6 */

/*

IN-prædikatet benytter tre logiske værdier (SANDT, FALSKT og UKENDT), mens EXISTS-prædikatet benytter to
  logiske værdier (SANDT og FALSKT). Hvis der ikke optræder nogle NULL-værdier, så giver de to prædikater
  det samme resultat. Hvis der optræder NULL-værdier, så giver de to prædikater det samme resultat i deres
  positive form, mens de giver forskellige resultater i deres negative form (med NOT). 

*/

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