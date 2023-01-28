/* ***********************

JOINS

Udviklet af Thomas Lange & Mick Ahlmann Brun

Mere info: https://github.com/M1ckB/T-SQL

Version 1.0 2023-01-08

Laboratoriet kræver:

- En understøttet version af SQL Server
- En Stack Overflow database: https://www.BrentOzar.com/go/querystack (medium)

Læs mere om joins i Microsofts T-SQL reference:

- https://learn.microsoft.com/en-us/sql/t-sql/queries/from-transact-sql?view=sql-server-ver16
- https://learn.microsoft.com/en-us/sql/relational-databases/performance/joins?view=sql-server-ver16

Du kan finde løsninger og svar på opgaverne nederst i scriptet.

*********************** */

USE StackOverflow2013;
GO

/* ***********************

ØVELSER

*********************** */

/*

OPGAVE 1: Hvilke spørgsmål kan vi besvare med et CROSS JOIN?

*/

/*

OPGAVE 2: Lav en query som returnerer alle kombinationer af indlægs- og stemmetyper.

- Tabeller involveret: dbo.PostTypes, dbo.VoteTypes
- Ønsket output:
Type      Name
Question	AcceptedByOriginator
Question	UpMod
Question	DownMod
...
(120 rows)

*/

/*

OPGAVE 3: Returner brugere fra USA og deres indlæg.

- Tabeller involveret: dbo.Users, dbo.Posts
- Ønsket output:
Id      Displayname       Location  PostTypeId  CreationDate
65393	  Instance Hunter	  USA       2	          2009-02-12 12.51.08.890
65393	  Instance Hunter	  USA	      1           2009-02-13 13.49.09.740
65393	  Instance Hunter	  USA	      2           2009-02-16 20.35.06.343
...
(196.184 rows)

*/

/*

OPGAVE 4 (valgfri): Kan du opnå samme resultat som i forrige opgave ved at bruge et CROSS JOIN?

*/

/*

OPGAVE 5: Returner unikke brugere som har fået badget "Teacher", sorteret aftagende på baggrund af omdømme.

- Tabeller involveret: dbo.Badges, dbo.Users
- Ønsket output:
Id	    DisplayName	    Reputation
22656	  Jon Skeet	      1047863
157882	BalusC	        818687
29407	  Darin Dimitrov	814505
...
(535.840 rows)

*/

/*

OPGAVE 6: Returner brugere fra USA og deres indlæg, inklusiv brugere som ingen indlæg har lavet.

- Tabeller involveret: dbo.Users, dbo.Posts
- Ønsket output:
Id	  DisplayName	    Location	PostTypeId	CreationDate
65393	Instance Hunter	USA	      1	          2009-03-04 03.09.41.437
65393	Instance Hunter	USA	      2	          2009-03-04 03.33.02.627
76840	aikeru	        USA	      1	          2009-03-11 19.14.55.487
...
(25.348 rows)

*/

/*

OPGAVE 7: Returner brugere som ingen indlæg har lavet.

- Tabeller involveret: dbo.Users, dbo.Posts
- Ønsket output:
Id	    DisplayName	            Reputation
2901047	user2901047	            1
2474029	user2474029	            1
2740827	Said Falukatif Bakalli	1
...
(1.030.987 rows)

*/

/* ***********************

LØSNINGER

*********************** */

/* OPGAVE 1 */

/* Et CROSS JOIN bruges til at populere alle kombinationer af to tabeller. Eksempelvis er dette relevant hvis
  man ønsker at skifte granularitet fra en tidsenhed til en anden, fx fra år til måneder */

/* OPGAVE 2 */

SELECT
  p.[Type],
  v.Name
FROM dbo.PostTypes AS p
CROSS JOIN dbo.VoteTypes AS v;

/* OPGAVE 3 */

/* Bemærk at brugere fra USA uden indlæg ikke indgår */

SELECT
  u.Id,
  u.DisplayName,
  u.[Location],
  p.PostTypeId,
  p.CreationDate
FROM dbo.Users AS u
INNER JOIN dbo.Posts AS p
  ON p.OwnerUserId = u.Id
WHERE u.[Location] = 'USA';
-- WHERE u.[Location] LIKE '%USA%';

/* OPGAVE 4 */

SELECT
  u.Id,
  u.DisplayName,
  u.[Location],
  p.PostTypeId,
  p.CreationDate
FROM dbo.Users AS u
CROSS JOIN dbo.Posts AS p
WHERE p.OwnerUserId = u.Id
AND u.[Location] = 'USA';

/* OPGAVE 5 */

/* Bemærk at badge-filteret kan placeres både som en JOIN- og en WHERE-betingelse. Prøv at diskutere med din
  sidemakker hvad der er mest hensigtsmæssigt */

SELECT DISTINCT
  u.Id,
  u.DisplayName,
  u.Reputation
FROM dbo.Users AS u
INNER JOIN dbo.Badges AS b
  ON b.UserId = u.Id
--  AND b.Name = 'Teacher'
WHERE b.Name = 'Teacher'
ORDER BY u.Reputation DESC;

/* OPGAVE 6 */

SELECT
  u.Id,
  u.DisplayName,
  u.[Location],
  p.PostTypeId,
  p.CreationDate
FROM dbo.Users AS u
LEFT OUTER JOIN dbo.Posts AS p
  ON p.OwnerUserId = u.Id
WHERE u.[Location] = 'USA';

/* OPGAVE 7 */

SELECT
  u.Id,
  u.DisplayName,
  u.Reputation
FROM dbo.Users AS u
LEFT OUTER JOIN dbo.Posts AS p
  ON p.OwnerUserId = u.Id
WHERE p.Id IS NULL;

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
