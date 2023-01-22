/* ***********************

SET-OPERATORER: UNION, INTERSECT og EXCEPT
  af Thomas Lange & Mick Ahlmann Brun

Version 1.0 2023-01-10

Laboratoriet kræver:

- En understøttet version af SQL Server
- En Stack Overflow database: https://www.BrentOzar.com/go/querystack

Agenda:

- Introduktion til set-operatorerne UNION, INTERSECT, EXCEPT 
- Introduktion til forskellige typer af set-operationer, deres muligheder og anvendelser

Læs mere om set-operatorerne i Microsofts T-SQL reference:

- https://learn.microsoft.com/en-us/sql/t-sql/language-elements/set-operators-union-transact-sql?view=sql-server-ver16
- https://learn.microsoft.com/en-us/sql/t-sql/language-elements/set-operators-except-and-intersect-transact-sql?view=sql-server-ver16

*/

USE StackOverflow2013;
GO

/* ***********************

SET-operatorer:
- SET-operatorer laver mængdelære-operationer mellem to tabel-resultater fra SELECT-forespørgsler.
- Vi skal derfor have to fungerende SELECT-forespørgsler til rådighed for at kunne lave SET-operationerne.

- Der findes tre SET-operatorer i T-SQL:
   - UNION 
   - INTERSECT
   - EXCEPT 

Use cases:

- Kombination af delresultater til et samlet resultat, fx oplysninger fra forskellige adm. systemer
- Fjernelse af udvalgte rækker fra en tabel, fx via en negativliste

*/

/* ***********************

UNION set-operatoren:

- UNION konkatenerer tabel-resultaterne af to SELECT-forespørgsler til et enkelt tabel-resultat.
- Det er muligt at in- og ekskludere dubletrækker:

- UNION ALL - Inklusive dubletter
- UNION - Eksklusive dubletter.

*/

/* [Vis, uden at gå i detaljer med tabeloperatorens udformning, hvordan tabel-resultater fra to forskellige
  SELECT-forespørgsler kædes sammen og bliver til en ny tabel] */

/* [Mockup] */

CREATE TABLE #TableA (
  Id int NOT NULL,
  Col int NOT NULL
);

INSERT INTO #TableA (Id, Col)
VALUES
(1, 5), 
(2, 6);

CREATE TABLE #TableB (
  Id int NOT NULL,
  Col int NOT NULL
);

INSERT INTO #TableB (Id, Col)
VALUES
(1, 5), 
(3, 7);


SELECT * FROM #TableA;
SELECT * FROM #TableB;

SELECT Id, Col FROM #TableA
UNION
SELECT Id, Col FROM #TableB;

SELECT Id, Col FROM #TableA
UNION ALL
SELECT Id, Col FROM #TableB;

DROP TABLE #TableA;
DROP TABLE #TableB;

/*[Bemærk: Kolonnenavnet på tabel-resultatet bestemmes af første SELECT-forespørgsel i UNION-operatoren.
   Derfor er det vigtigt at kolonnerne i de to SELECT-forespørgsler kommer i rigtig rækkefølge. 
   Det anbefales ikke at lavet SELECT * i SET-operator forespørgslerne.]*/

/* [Stack Overflow] */

SELECT 
  Id, DisplayName, [Location], UpVotes
FROM dbo.Users
WHERE [Location] LIKE '%copenhagen%';
--[1162 rows]

SELECT 
    Id, DisplayName, [Location], UpVotes
FROM dbo.Users
WHERE UpVotes>=5000;
--[921 rows]

SELECT 
  Id, DisplayName, [Location], UpVotes
FROM dbo.Users
WHERE [Location] LIKE '%copenhagen%'
--UNION
UNION ALL
SELECT 
    Id, DisplayName, [Location], UpVotes
FROM dbo.Users
WHERE UpVotes>=5000;
--[UNION     2080 rows]
--[UNION ALL 2083 rows]

/*

Lav opgave 1, 2 (optional) og 3

*/

/* ***********************

INTERSECT og EXCEPT SET-operatorerne:

- INTERSECT giver os distinkte rækker som findes i resultat-tabellerne fra både 
  venstre SELECT-forespørgsel og højre SELECT-forespørgsel. 
  
- EXCEPT giver os distinkte rækker fra venstre SELECT-forespørgsels resultat-tabel,
  som ikke findes i højre SELECT-forespørgsels resultat-tabel. 
  Bemærk, at rækkefølgen mellem SELECT-forespørgslerne er afgørende for resultatet.

*/

/* [Mockup] */

CREATE TABLE #TableA (
  Id int NOT NULL,
  Col int NOT NULL
);

INSERT INTO #TableA (Id, Col)
VALUES
(1, 5), 
(2, 6);

CREATE TABLE #TableB (
  Id int NOT NULL,
  Col int NOT NULL
);

INSERT INTO #TableB (Id, Col)
VALUES
(1, 5), 
(3, 7);


SELECT * FROM #TableA;
SELECT * FROM #TableB;


SELECT Id, Col FROM #TableA
INTERSECT
SELECT Id, Col FROM #TableB;

SELECT Id, Col FROM #TableA
EXCEPT
SELECT Id, Col FROM #TableB;


DROP TABLE #TableA;
DROP TABLE #TableB;

/*[Bemærk: 
    UNION er virkelig god til at konkatenere tabeller med samme kolonner!
    EXCEPT er virkelig god (uundværlig!) til at teste om to tabeller er ens!]*/


/* [Stack Overflow] */

SELECT 
  Id, DisplayName, [Location], UpVotes
FROM dbo.Users
WHERE [Location] LIKE '%copenhagen%';
--[1162 rows]

SELECT 
    Id, DisplayName, [Location], UpVotes
FROM dbo.Users
WHERE UpVotes>=5000;
--[921 rows]

--INTERSECT:
SELECT 
  Id, DisplayName, [Location], UpVotes
FROM dbo.Users
WHERE [Location] LIKE '%copenhagen%'
INTERSECT
SELECT 
    Id, DisplayName, [Location], UpVotes
FROM dbo.Users
WHERE UpVotes>=5000;

--EXCEPT den ene vej:
SELECT 
  Id, DisplayName, [Location], UpVotes
FROM dbo.Users
WHERE [Location] LIKE '%copenhagen%'
EXCEPT
SELECT 
    Id, DisplayName, [Location], UpVotes
FROM dbo.Users
WHERE UpVotes>=5000;

--EXCEPT den anden vej:
SELECT 
    Id, DisplayName, [Location], UpVotes
FROM dbo.Users
WHERE UpVotes>=5000
EXCEPT
SELECT 
  Id, DisplayName, [Location], UpVotes
FROM dbo.Users
WHERE [Location] LIKE '%copenhagen%';

/*

Lav opgave 4 og 5

*/

/* ***********************

Hovedpointer:

- SET-operatorerne fungerer på resultat-tabeller fra to SELECT-statements.
- Rækkefølgen af kolonner er vigtig, så undlad SELECT * ...!
- De tre SET-operatorer i T-SQL:
  - UNION (og UNION ALL): Konkatenerer resultat-tabellerne med distinkte (og ikke-distinkte) rækker
  - INTERCEPT: Finder distinkte rækker som findes i begge resultat-tabeller
  - EXCEPT:  Finder distinkte rækker i venstre resultat-tabel som ikke findes i højre resultat-tabel
- Stærke til fx konkatenering af tabellers indhold og til at finde forskelle mellem tabellers indhold.
- Når der er flere SET-operationer i en forespørgsel, så evealueres de fra venstre mod højre.

*/

/* ***********************

Licens:

Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)

Mere info: https://creativecommons.org/licenses/by-sa/4.0/

Du kan frit:

- Dele: kopiere og distribuere materialet via ethvert medium og i ethvert format
- Tilpasse: remixe, redigere og bygge på materialet til ethvert formål, selv erhvervsmæssigt

Under følgende betingelser:

- Kreditering: Du skal kreditere, dele et link til licensen og indikere om der er lavet ændringer.
- Del på samme vilkår: Hvis du remixer, redigerer eller bygger på materialet, så skal dine bidrag
  distribueres under samme licens som den originale.

*/