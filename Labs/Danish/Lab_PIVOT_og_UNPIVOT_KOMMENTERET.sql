/* ***********************

Emne: PIVOT og UNPIVOT
Version: 1.1
Dato: 2023-01-17

Laboratoriet kræver:

- En understøttet version af SQL Server
- En Stack Overflow database: https://www.BrentOzar.com/go/querystack

Agenda:

- Introduktion til operatorerne PIVOT og UNPIVOT 

Læs mere om set-operatorerne i Microsofts T-SQL reference:

- https://learn.microsoft.com/en-us/sql/t-sql/queries/from-using-pivot-and-unpivot?view=sql-server-ver16

*/

USE StackOverflow2013;
GO

/* ***********************
PIVOT-operatoren:
Fra rækker til kolonner!

PIVOT-operationer af data handler om at rotere data fra rækker til kolonner, eventuelt med samtidig aggregering af værdier.
En almindelig use case er, at man ønsker at rapportere data for flere år på en enkelt linje.

PIVOT vender et tabel-resultatet fra en SELECT-forespørgsel ved at forvandle unikke værdier fra en kolonne (i flere rækker) til flere kolonner. 
PIVOT foretager aggregeringer hvor nødvendigt på tilbageværende kolonneværdier. 


UNPIVOT-operatoren:
Fra kolonner til rækker!

UNPIVOT-operationen er en teknik, som roterer data fra kolonner til rækker. 
En almindelig use case er, at man modtager data med flere kolonner for samme oplysning for flere år og ønsker en tabel, som muliggør filtrering på år.

UNPIVOT forvandler kolonner i en tabel-resultatet fra en SELECT-forespørgsel til kolonneværdier (i flere rækker).

*/

/* [Vis, hvordan tabel-resultater fra en SELECT-forespørgsel kan vendes 
1. fra rækker til kolonner (PIVOT), og 
2. fra kolonner til rækker (UNPIVOT) 
*/

/* [Mockup] */

CREATE TABLE #TableA (
  Id int NOT NULL,
  GrpCol nvarchar(1) NOT NULL, 
  SumCol int NOT NULL
);

INSERT INTO #TableA (Id, GrpCol, SumCol)
VALUES
(1, 'A', 100), 
(1, 'A', 100), 
(2, 'A', 200), 
(2, 'B', 300);

SELECT * FROM #TableA;

--Hvis vi skulle gøre det 'i hånden'...
SELECT Id, 
 SUM(CASE WHEN GrpCol = 'A' THEN SumCol END) AS A, 
 SUM(CASE WHEN GrpCol = 'B' THEN SumCol END) AS B
FROM #TableA 
GROUP BY Id

--Med PIVOT bliver syntaksen mere kompakt...
SELECT Id, A, B
FROM #TableA
PIVOT( SUM(SumCol) FOR GrpCol IN (A,B) ) AS p

DROP TABLE #TableA;

/* [Stack Overflow] */



-- Posts indeholder 1 række pr. post med angivet posttype, creationdate mv., samt optællinger af svar og kommentarer mv.:
SELECT TOP 10 * FROM dbo.posts 
-- Vi vil her kun bruge PostCreationYear, PostTypeId og Commentcount for årene 2008-2010:
SELECT TOP 10 
  YEAR(CreationDate) AS PostCreationYear, PostTypeId, CommentCount FROM dbo.posts WHERE CreationDate BETWEEN CAST('20080101' AS date) AND CAST('20101231' AS date)

--Vil nu gerne optælle summen af Questions og Answers pr PostCreationYear
SELECT p.PostCreationYear, [1] AS Questions, [2] AS Answers
FROM (
  SELECT YEAR(CreationDate) AS PostCreationYear, PostTypeId, CommentCount FROM dbo.posts WHERE CreationDate BETWEEN CAST('20080101' AS date) AND CAST('20101231' AS date)
  ) posts
PIVOT ( SUM(CommentCount) FOR PostTypeId IN ([1],[2])) AS p

/* ***********************

Hovedpointer:

*/
