/* ***********************

Emne: Joins
Version: 1.1
Dato: 2023-01-08

Laboratoriet kræver:

- En understøttet version af SQL Server
- En Stack Overflow database: https://www.BrentOzar.com/go/querystack

Agenda:

- Introduktion til JOIN-tabeloperatoren
- Introduktion til forskellige typer af joins og deres faser

Læs mere om joins i Microsofts T-SQL reference:

- https://learn.microsoft.com/en-us/sql/t-sql/queries/from-transact-sql?view=sql-server-ver16
- https://learn.microsoft.com/en-us/sql/relational-databases/performance/joins?view=sql-server-ver16

*/

USE StackOverflow2013;
GO

/* ***********************

JOIN-tabeloperatoren:

- FROM-delsætningen er det første som logisk processeres i en forespørgsel
- I FROM-delsætningen beskrives den eller de tabeller som der skal læses fra i en forespørgsel
- Når der skal læses fra flere tabeller, så skal det specificeres hvordan disse hænger sammen. Dette gøres
  via tabeloperatorer
- JOIN-tabeloperatoren tager to tabeller som input, udfører nogle logiske processeringsfaser og returnerer
  en tabel som resultat

/* ***********************

Use case(s):

- Kombination af oplysninger fra to eller flere tabeller

*/

/* [Vis, uden at gå i detaljer med tabeloperatorens udformning, hvordan oplysninger fra to forskellige
  tabeller kædes sammen og bliver til en ny tabel] */

/* [Mockup] */

CREATE TABLE #TableA (
  Id int NOT NULL,
  TableB_Id int NOT NULL
);

INSERT INTO #TableA (Id, TableB_Id)
VALUES
(1, 5), 
(2, 6);

CREATE TABLE #TableB (
  Id int NOT NULL,
  Col nvarchar(100) NULL
);

INSERT INTO #TableB (Id, Col)
VALUES
(5, 'Info from table B');

SELECT
  *
FROM #TableA;

SELECT
  *
FROM #TableB;

SELECT
  a.Id,
  a.TableB_Id,
  b.Col
FROM #TableA AS a
JOIN #TableB AS b
  ON b.Id = a.TableB_Id;

DROP TABLE #TableA;
DROP TABLE #TableB;

/* [Stack Overflow] */

SELECT TOP (1000)
  Id,
  Title,
  CreationDate,
  OwnerUserId
FROM dbo.Posts;

SELECT TOP (1000)
  Id,
  DisplayName
FROM dbo.Users;

SELECT TOP (1000)
  p.Id,
  p.Title,
  p.CreationDate,
  p.OwnerUserId,
  u.DisplayName
FROM dbo.Posts AS p
JOIN dbo.Users AS u
  ON u.Id = p.OwnerUserId;

/* ***********************

CROSS join:

- Et cross join er den simpleste form for join
- Et cross join benytter kun en logisk fase: Kartesisk Produkt
- Tabeloperatoren tager to tabeller som input og matcher hver række i den ene tabel med alle rækker
  i den anden tabel
- Et cross join har formen:

SELECT
  <kolonner>
FROM <tabel1>
CROSS JOIN <tabel2>;

*/

/* [Vis hvordan et indlæg bliver dubleret svarende til antallet af indlægstyper ved et CROSS JOIN] */

/* [Mockup] */

CREATE TABLE #TableA (
  [Year] int NOT NULL
);

INSERT INTO #TableA ([Year])
VALUES
(2020), (2021), (2022);

CREATE TABLE #TableB (
  [Month] int NOT NULL,
  MonthName nvarchar(100) NOT NULL
);

INSERT INTO #TableB ([Month], MonthName)
VALUES
(1, 'Jan'), (2, 'Feb'), (3, 'Mar'), (4, 'Apr'), (5, 'May'), (6, 'Jun'),
(7, 'Jul'), (8, 'Aug'), (9, 'Sep'), (10, 'Oct'), (11, 'Nov'), (12, 'Dec');

SELECT
  *
FROM #TableA;

SELECT
  *
FROM #TableB;

SELECT
  a.[Year],
  b.MonthName
FROM #TableA AS a
CROSS JOIN #TableB AS b
ORDER BY a.[Year], b.[Month];

DROP TABLE #TableA;
DROP TABLE #TableB;

/* [Stack Overflow] */

SELECT
  Id,
  Title,
  CreationDate,
  OwnerUserId
FROM dbo.Posts
WHERE Id = 4;

SELECT
  Id,
  Type
FROM dbo.PostTypes;

SELECT
  p.Id,
  p.Title,
  p.CreationDate,
  p.OwnerUserId,
  pt.Type
FROM dbo.Posts AS p
CROSS JOIN dbo.PostTypes AS pt
WHERE p.Id = 4;

/*

Opgave 1: Hvilke spørgsmål kan vi besvare med denne type af join?

*/

/* [CROSS JOIN bruges til at populere alle kombinationer af to tabeller. Eksempelvis er dette relevant hvis
  man ønsker at skifte granularitet fra en tidsenhed til en anden, fx fra år til måneder] */

/*

Opgave 2: Lav en query som returnerer alle kombinationer af indlægs- og stemmetyper.

- Tabeller involveret:  dbo.PostTypes, dbo.VoteTypes
- Ønsket output:
Type      Name
Question	AcceptedByOriginator
Question	UpMod
Question	DownMod
...
(120 rows)
*/

SELECT
  p.[Type],
  v.Name
FROM dbo.PostTypes AS p
CROSS JOIN dbo.VoteTypes AS v;

/* ***********************

INNER join:

- Et inner join benytter to logiske faser: Kartesisk Produkt og Filter
- Tabeloperatoren tager to tabeller som input, laver et kartesisk produkt mellem disse (a la et CROSS join)
  og filtrerer herefter rækkerne på baggrund af et prædikat som du angiver
  i den anden tabel
- Et inner join har formen:

SELECT
  <kolonner>
FROM <tabel1>
INNER JOIN <tabel2>
  ON <join-betingelse>;

*/

/* [
  - Vis INNER join i et Venn-diagram
  - Vis hvordan spørgsmål med et specifik tag kan kædes sammen med deres accepterede svar ved et INNER JOIN.
  - Bemærk, at ikke alle spørgsmål har et accepteret svar hvorfor nogle rækker filtreres fra
  ] */

/* [Mockup] */

CREATE TABLE #TableA (
  Id int NOT NULL,
  TableB_Id int NULL
);

INSERT INTO #TableA (Id, TableB_Id)
VALUES
(1, NULL), (2, 3);

CREATE TABLE #TableB (
  Id int NOT NULL,
  Col nvarchar(100) NULL
);

INSERT INTO #TableB (Id, Col)
VALUES
(1, 'ABC'), (2, 'DEF'), (3, 'GHI');

SELECT
  *
FROM #TableA;

SELECT
  *
FROM #TableB;

SELECT
  a.Id,
  a.TableB_Id,
  b.Col
FROM #TableA AS a
INNER JOIN #TableB AS b
  ON b.Id = a.TableB_Id;

DROP TABLE #TableA;
DROP TABLE #TableB;

/* [Stack Overflow] */

SELECT
  Id,
  Title,
  Tags,
  AcceptedAnswerId
FROM dbo.Posts
WHERE PostTypeId = 1 -- Question
AND Tags LIKE '%<sql>%<inner-join>%';

SELECT
  q.Id,
  q.Title,
  q.Tags,
  q.AcceptedAnswerId,
  a.Body
FROM dbo.Posts AS q
INNER JOIN dbo.Posts AS a
  ON a.Id = q.AcceptedAnswerId
WHERE q.PostTypeId = 1 -- Question
AND q.Tags LIKE '%<sql>%<inner-join>%';

/*

Opgave 3: Returner brugere fra USA og deres indlæg.

- Tabeller involveret:  dbo.Users, dbo.Posts
- Ønsket output:
Id      Displayname       Location  PostTypeId  CreationDate
65393	  Instance Hunter	  USA       2	          2009-02-12 12.51.08.890
65393	  Instance Hunter	  USA	      1           2009-02-13 13.49.09.740
65393	  Instance Hunter	  USA	      2           2009-02-16 20.35.06.343
...
(196.184 rows)
*/

/* [Bemærk at brugere fra USA uden indlæg ikke indgår] */

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

/*

Opgave 4 (valgfri): Kan du opnå samme resultat ved at bruge et CROSS JOIN?

*/

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

/*

Opgave 5: Returner unikke brugere som har fået badget "Teacher", sorteret aftagende på baggrund af omdømme.

- Tabeller involveret:  dbo.Badges, dbo.Users
- Ønsket output:
Id	    DisplayName	    Reputation
22656	  Jon Skeet	      1047863
157882	BalusC	        818687
29407	  Darin Dimitrov	814505
...
(535.840 rows)
*/

/* [Tag diskussion op omkring hvad der bør listes som join-betingelse og hvad der bør placeres i WHERE-
  betingelsen] */

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

/* ***********************

OUTER join:

- Et outer join benytter alle tre logiske faser: Kartesisk Produkt, Filter og Tilføj Ydre Rækker
- Tabeloperatoren tager to tabeller som input, laver et kartesisk produkt mellem disse, filtrerer rækkerne
  på baggrund af et prædikat som du angiver (a la et INNER join) og tilføjer rækker for den tabel der er
  markeret som "bevaret"
- Hvilken tabel der er "bevaret" styres af nøgleordene: LEFT, RIGHT og FULL
- Et outer join har en af følgende former:

SELECT
  <kolonner>
FROM <tabel1>
LEFT OUTER JOIN <tabel2>
  ON <join-betingelse>;

SELECT
  <kolonner>
FROM <tabel1>
RIGHT OUTER JOIN <tabel2>
  ON <join-betingelse>;

SELECT
  <kolonner>
FROM <tabel1>
FULL OUTER JOIN <tabel2>
  ON <join-betingelse>;

*/

/* [
  - Vis OUTER joins i et Venn-diagram]
  - Vis hvordan der, modsat eksemplet med INNER JOIN, også inkluderes indlæg som intet accepteret
    svar har (genkendt ved deres NULL-værdier)
  - Vis at nøgleordet OUTER er valgfrit
  ] */

/* [Mockup] */

CREATE TABLE #TableA (
  Id int NOT NULL,
  TableB_Id int NULL
);

INSERT INTO #TableA (Id, TableB_Id)
VALUES
(1, NULL), (2, 3);

CREATE TABLE #TableB (
  Id int NOT NULL,
  Col nvarchar(100) NULL
);

INSERT INTO #TableB (Id, Col)
VALUES
(1, 'ABC'), (2, 'DEF'), (3, 'GHI');

SELECT
  *
FROM #TableA;

SELECT
  *
FROM #TableB;

SELECT
  a.Id,
  a.TableB_Id,
  b.Col
FROM #TableA AS a
LEFT OUTER JOIN #TableB AS b
  ON b.Id = a.TableB_Id;

DROP TABLE #TableA;
DROP TABLE #TableB;

/* [Stack Overflow] */

SELECT
  q.Id,
  q.Title,
  q.Tags,
  q.AcceptedAnswerId,
  a.Body
FROM dbo.Posts AS q
LEFT /*OUTER*/ JOIN dbo.Posts AS a
  ON a.Id = q.AcceptedAnswerId
WHERE q.PostTypeId = 1 -- Question
AND q.Tags LIKE '%<sql>%<inner-join>%';

/*

Opgave 6: Returner brugere fra USA og deres indlæg, inklusiv brugere som ingen indlæg har lavet.

- Tabeller involveret:  dbo.Users, dbo.Posts
- Ønsket output:
Id	  DisplayName	    Location	PostTypeId	CreationDate
65393	Instance Hunter	USA	      1	          2009-03-04 03.09.41.437
65393	Instance Hunter	USA	      2	          2009-03-04 03.33.02.627
76840	aikeru	        USA	      1	          2009-03-11 19.14.55.487
...
(25.348 rows)
*/

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

/*

Opgave 7: Returner brugere som ingen indlæg har lavet.

- Tabeller involveret:  dbo.Users, dbo.Posts
- Ønsket output:
Id	    DisplayName	            Reputation
2901047	user2901047	            1
2474029	user2474029	            1
2740827	Said Falukatif Bakalli	1
...
(1.030.987 rows)
*/

SELECT
  u.Id,
  u.DisplayName,
  u.Reputation
FROM dbo.Users AS u
LEFT OUTER JOIN dbo.Posts AS p
  ON p.OwnerUserId = u.Id
WHERE p.Id IS NULL;

/* ***********************

Flere eksempler med joins:

*/

/* [Vis hvordan man en join-betingelse kan have flere matching-attributter og at disse kan bestå
  af både ligheds- og ulighedstegn] */

/* [Mockup] */

CREATE TABLE #TableA (
  Id int NOT NULL,
  TableB_Id int NULL
);

INSERT INTO #TableA (Id, TableB_Id)
VALUES
(1, NULL), (2, 3), (3, 1);

CREATE TABLE #TableB (
  Id int NOT NULL,
  Col1 nvarchar(100) NULL,
  Col2 date NULL
);

INSERT INTO #TableB (Id, Col1, Col2)
VALUES
(1, 'ABC', '19380101'), (2, 'DEF', '20120312'), (3, 'GHI', '20200521');

SELECT
  *
FROM #TableA;

SELECT
  *
FROM #TableB;

SELECT
  a.Id,
  a.TableB_Id,
  b.Col1,
  b.Col2
FROM #TableA AS a
LEFT OUTER JOIN #TableB AS b
  ON b.Id = a.TableB_Id
  AND b.Col2 > CAST('20000101' AS date);

DROP TABLE #TableA;
DROP TABLE #TableB;

/* [Stack Overflow] */

SELECT
  p.Id,
  p.Title,
  p.OwnerUserId,
  u.DisplayName,
  u.Reputation
FROM dbo.Posts AS p
INNER JOIN dbo.Users AS u
  ON u.Id = p.OwnerUserId
  AND u.Reputation > 1000000
WHERE p.PostTypeId = 1; -- Question

/* [Vis hvordan multi-join queries fungerer] */

/* [Husk at nævne at multi-join queries evalueres fra venstre mod højre. Dette er modsat konceptet om
  all-at-once operations som gør sig gældende ellers. Dette er særlig vigtigt når der arbejdes med OUTER
  joins da resultatet fra den første tabeloperator også leverer "ydre rækker" til den næste tabeloperator] */

/* [Mockup] */

CREATE TABLE #TableA (
  Id int NOT NULL,
  TableB_Id int NULL
);

INSERT INTO #TableA (Id, TableB_Id)
VALUES
(1, NULL), (2, 3), (3, 1);

CREATE TABLE #TableB (
  Id int NOT NULL,
  ColB nvarchar(100) NULL,
  TableC_Id int NULL
);

INSERT INTO #TableB (Id, ColB, TableC_Id)
VALUES
(1, 'ABC', 3), (2, 'DEF', 1), (3, 'GHI', 2);

CREATE TABLE #TableC (
  Id int NOT NULL,
  ColC date NULL
);

INSERT INTO #TableC (Id, ColC)
VALUES
(1, '20201231'), (2, '19250102'), (3, '20500304');

SELECT
  *
FROM #TableA;

SELECT
  *
FROM #TableB;

SELECT
  *
FROM #TableC;

SELECT
  a.Id,
  a.TableB_Id,
  b.ColB,
  b.TableC_Id,
  c.ColC
FROM #TableA AS a
LEFT OUTER JOIN #TableB AS b
  ON b.Id = a.TableB_Id
LEFT OUTER JOIN #TableC AS c
-- INNER JOIN #TableC AS c
  ON c.Id = b.TableC_Id;

DROP TABLE #TableA;
DROP TABLE #TableB;
DROP TABLE #TableC;

/* [Stack Overflow] */

SELECT
  p.Id,
  p.CreationDate,
  pt.Type,
  p.Title,
  u.DisplayName
FROM dbo.Posts AS p
INNER JOIN dbo.PostTypes AS pt
  ON pt.Id = p.PostTypeId
INNER JOIN dbo.Users AS u
  ON u.Id = p.OwnerUserId
WHERE p.Id = 4;

/* ***********************

Hovedpointer:

- JOIN er en tabeloperator som fungerer i FROM-delsætningen. Tabeloperatoren tager imod nogle inputtabeller,
  udfører nogle logiske faser og returnerer en resultattabel
- JOIN-operatoren har følgende logiske faser: Kartesisk Produkt, Filter og Tilføj Ydre Rækker
- Der er tre typer af joins: CROSS join, INNER joins og OUTER joins
- De tre typer af joins benytter følgende logiske faser:
  - CROSS join:   Kartesisk Produkt
  - INNER join:   Kartesisk Produkt og Filter
  - OUTER joins:  Kartesisk Produkt, Filter og Tilføj Ydre Rækker
- Når to tabeller joines, så kan der benyttes flere matching attributter i join-betingelsen (også kaldt
  composite joins)
- Når der er flere joins i en forespørgsel (også kaldt multijoin queries), så evalueres tabeloperatorerne
  fra venstre mod højre

*/
