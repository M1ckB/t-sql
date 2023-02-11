/* ***********************

DERIVED TABLES

Udviklet af Thomas Lange & Mick Ahlmann Brun

Mere info: https://github.com/M1ckB/T-SQL

Version 1.0 2023-02-02

Laboratoriet kræver:

- En understøttet version af SQL Server
- En Stack Overflow database: https://www.BrentOzar.com/go/querystack (medium)

Læs mere om derived tables i Microsofts T-SQL reference:

- https://learn.microsoft.com/en-us/sql/relational-databases/performance/subqueries?view=sql-server-ver16

Du kan finde løsninger og svar på opgaverne nederst i scriptet.

*********************** */

USE StackOverflow2013;
GO

/* ***********************

ØVELSER

*********************** */

/* 

OPGAVE 1.1: Find for hver bruger tidspunktet for dennes seneste indlæg.

- Tabeller involveret: dbo.Posts
- Ønsket output:
OwnerUserId	MaxCreationDate
162876	    2012-12-28 16.44.38.307
188346	    2011-07-26 07.28.20.437
154386	    2011-09-19 23.07.58.170
...
(1.435.072 rows)

*/

/*

OPGAVE 1.2: Byg videre på forrige opgave. Indpak forespørgslen i en derived table og sammenkæd denne med
  indlægstabellen for at finde oplysninger om de seneste indlæg for hver bruger.

- Tabeller involveret: dbo.Posts
- Ønsket output:
Id	OwnerUserId	CreationDate	          PostTypeId	Title
4	  8	          2008-07-31 21.42.52.667	1	          Convert Decimal to Double?
14	11	        2008-08-01 00.59.11.177	1	          Difference between Math.Floor() and Math.Truncate()
391	134	        2008-08-02 09.51.00.883	2	          NULL
...
(1.436.125 rows)

*/

/* 

OPGAVE 2.1: Find for hvert spørgsmål den højeste score som er givet til et af svarene på spørgsmålet.

- Tabeller involveret: dbo.Posts
- Ønsket output:
ParentId	MaxScore
19333761	0
19519062	1
2926445	  3
...
(5.618.800 rows)

*/

/*

OPGAVE 2.2: Byg videre på forrige opgave. Indpak forespørgslen i en derived table og sammenkæd denne med
  indlægstabellen for at finde oplysninger om svaret (eller svarene) med den højeste score for et
  spørgsmål.

- Tabeller involveret: dbo.Posts
- Ønsket output:
Id	PostTypeId  Score	ParentId
7	  2	          401	  4
26	2	          131	  17
31	2	          132	  6
...
(6.437.324 rows)

*/

/* ***********************

LØSNINGER

*********************** */

/* OPGAVE 1.1 */

SELECT
  OwnerUserId,
  MAX(CreationDate) AS MaxCreationDate
FROM dbo.Posts
GROUP BY OwnerUserId;

/* OPGAVE 1.2 */

/* Bemærk at en bruger godt kan have lavet flere indlæg på samme tidspunkt hvorfor antallet af rækker
  returneret i resultattabellen og den underliggende derived table ikke nødvendigvis er ens */

SELECT
  p.Id,
  p.OwnerUserId,
  p.CreationDate,
  p.PostTypeId,
  p.Title
FROM dbo.Posts AS p
INNER JOIN (
  SELECT
    OwnerUserId,
    MAX(CreationDate) AS MaxCreationDate
  FROM dbo.Posts
  GROUP BY OwnerUserId
) AS d
  ON d.OwnerUserId = p.OwnerUserId
  AND d.MaxCreationDate = p.CreationDate;

/* OPGAVE 2.1 */

SELECT
  ParentId,
  MAX(Score) AS MaxScore
FROM dbo.Posts
WHERE PostTypeId = 2 /* Answer */
GROUP BY ParentId;

/* OPGAVE 2.2 */

/* Bemærk igen at det samme svar godt kan have den samme score hvorfor antallet af rækker
  returneret i resultattabellen og den underliggende derived table ikke nødvendigvis er ens */

SELECT
  p.Id,
  p.PostTypeId,
  p.Score,
  p.ParentId
FROM dbo.Posts AS p
INNER JOIN (
  SELECT
    ParentId,
    MAX(Score) AS MaxScore
  FROM dbo.Posts
  WHERE PostTypeId = 2 /* Answer */
  GROUP BY ParentId
) AS d
  ON d.ParentId = p.ParentId
  AND d.MaxScore = p.Score;

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