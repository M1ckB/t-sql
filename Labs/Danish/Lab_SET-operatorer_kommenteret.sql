/* ***********************

Emne: UNION, INTERSECT, EXCEPT
Version: 1.1
Dato: 2023-01-10

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

CREATE TABLE TabA (
  Id int NOT NULL,
  Col int NOT NULL
);

INSERT INTO TabA (Id, Col)
VALUES
(1, 5), 
(2, 6);

CREATE TABLE TabB (
  Id int NOT NULL,
  Col int NOT NULL
);

INSERT INTO TabB (Id, Col)
VALUES
(1, 5), 
(3, 7);


SELECT * FROM TabA;
SELECT * FROM TabB;

SELECT Id, Col FROM TabA
UNION
SELECT Id, Col FROM TabB;

SELECT Id, Col FROM TabA
UNION ALL
SELECT Id, Col FROM TabB;

DROP TABLE TabA;
DROP TABLE TabB;

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
Opgave 1: Hvad er forskellen på UNION og UNION ALL?
   Hvornår er de ens?
*/

/* [Forskellen på UNION og UNION ALL er, UNION returnerer distinkte rækker, mens UNION ALL returnerer rækker 
  det samlede antal gange, de findes i SELECT-forespørgslernes resultat-tabeller.]*/

/*  
Opgave 2 (optional): Nogle gange kan du bruge både FULL OUTER JOIN og UNION ALL til at løse en opgave. Hvornår vælger du UNION/UNION ALL?
*/

/* [UNION og UNION ALL bruger og sammenligner alle kolonner defineret i SELECT-forespørgslerne, uden at 
  der skal defineres en lang liste af betingelser for sammenligninger (som der skal i FULL OUTER JOINs).
  Ofte er det derfor simplere at lave UNION eller UNION ALL end et FULL OUTER JOIN */

/*
Opgave 3: Skriv en forespørsel som giver dig tallene fra 1 til 10. 
- Tabeller involveret: Ingen
- Ønsket output:
   n
   -----------
   1
   2
   3
   4
   5
   6
   7
   8
   9
   10
*/

-- Med UNION ALL:
SELECT 1 AS n
UNION SELECT 2
UNION SELECT 3
UNION SELECT 4
UNION SELECT 5
UNION SELECT 6
UNION SELECT 7
UNION SELECT 8
UNION SELECT 9
UNION SELECT 10;

-- Med VALUES:
SELECT n
FROM (VALUES(1),(2),(3),(4),(5),(6),(7),(8),(9),(10)) AS Nums(n);



/* ***********************

INTERSECT og EXCEPT SET-operatorerne:

- INTERSECT giver os distinkte rækker som findes i resultat-tabellerne fra både 
  venstre SELECT-forespørgsel og højre SELECT-forespørgsel. 
  
- EXCEPT giver os distinkte rækker fra venstre SELECT-forespørgsels resultat-tabel,
  som ikke findes i højre SELECT-forespørgsels resultat-tabel. 
  Bemærk, at rækkefølgen mellem SELECT-forespørgslerne er afgørende for resultatet.

*/

/* [Mockup] */

CREATE TABLE TabA (
  Id int NOT NULL,
  Col int NOT NULL
);

INSERT INTO TabA (Id, Col)
VALUES
(1, 5), 
(2, 6);

CREATE TABLE TabB (
  Id int NOT NULL,
  Col int NOT NULL
);

INSERT INTO TabB (Id, Col)
VALUES
(1, 5), 
(3, 7);


SELECT * FROM TabA;
SELECT * FROM TabB;


SELECT Id, Col FROM TabA
INTERSECT
SELECT Id, Col FROM TabB;

SELECT Id, Col FROM TabA
EXCEPT
SELECT Id, Col FROM TabB;


DROP TABLE TabA;
DROP TABLE TabB;

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
Opgave 4: Skriv en forespørgsel som finder distinkte brugere i StackOverflow
 , som har givet DownVotes, men ingen UpVotes. 
- Tabeller involveret: dbo.Users
- Ønsket output: 
Id	  DisplayName
211	  jhornnes
15299	user15299
17020	Matt
17060	user17060
... (495 rows)
*/

SELECT Id,DisplayName
FROM dbo.Users
WHERE DownVotes>0

EXCEPT 

SELECT Id,DisplayName
FROM dbo.Users
WHERE UpVotes>0;



/*
Opgave 5: Skriv en forespørgsel som finder distinkte brugere i StackOverflow
 , som har givet mindst 1000 DownVotes og mindst 10000 UpVotes. 
- Tabeller involveret: dbo.Users
- Ønsket output: 
Id	  DisplayName
-1	  Community
476	  deceze
1288	Bill the Lizard
3043	Joel Coehoorn
... (79 rows)
*/

SELECT Id,DisplayName
FROM dbo.Users
WHERE DownVotes>1000

INTERSECT 

SELECT Id,DisplayName
FROM dbo.Users
WHERE UpVotes>10000;


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
