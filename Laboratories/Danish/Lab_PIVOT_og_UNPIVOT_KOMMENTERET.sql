/* ***********************

PIVOT OG UNPIVOT
  af Thomas Lange & Mick Ahlmann Brun
 
Version 1.0 2023-01-17

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

Use cases:

- Pivotering til præsentationsformål, her bruges særligt PIVOT (resultatet bliver til en "crosstab")
- Normalisering af en tabel, her bruges særligt UNPIVOT

Pivotering handler altid om at identificere involverede elementer: 
  Grupperingselementet
  Spredningselementet 
  Aggregeringselementet 
  Aggregeringsfunktionen


*/

/* [Vis, hvordan tabel-resultater fra en SELECT-forespørgsel kan vendes 
1. fra rækker til kolonner (PIVOT), og 
2. fra kolonner til rækker (UNPIVOT) 
*/



/* [Mockup] */

CREATE TABLE #OrigTxt (
  GroupId int NOT NULL,
  SpreadCol nvarchar(1) NOT NULL, 
  AggCol int NOT NULL
);
INSERT INTO #OrigTxt (GroupId, SpreadCol, AggCol)
VALUES
(1, 'A', 100), 
(2, 'A', 200), 
(2, 'B', 300);

CREATE TABLE #OrigNum (
  GroupId int NOT NULL,
  SpreadCol int NOT NULL, 
  AggCol int NOT NULL
);
INSERT INTO #OrigNum (GroupId, SpreadCol, AggCol)
VALUES
(1, 10, 100), 
(2, 10, 200), 
(2, 20, 300);

SELECT * FROM #OrigTxt;
SELECT * FROM #OrigNum;

/*PIVOT*/

--Hvad er grupperingselementet? Id
--Hvad er spredningselementet? GrpCol
--Hvad er aggregeringselementet? SumCol
--Hvad er aggregeringsfunktionen? SUM()


--Hvis vi skulle gøre det 'i hånden' ...
--med tekst spredningskolonne
SELECT GroupId, 
 SUM(CASE WHEN SpreadCol = 'A' THEN AggCol END) AS A, 
 SUM(CASE WHEN SpreadCol = 'B' THEN AggCol END) AS B
FROM #OrigTxt 
GROUP BY GroupId;

--med numerisk spredningskolonne...
SELECT GroupId, 
 SUM(CASE WHEN SpreadCol = 10 THEN AggCol END) AS [10], 
 SUM(CASE WHEN SpreadCol = 20 THEN AggCol END) AS [20]
FROM #OrigNum 
GROUP BY GroupId;


--Med PIVOT bliver syntaksen mere kompakt og ens for tekst og numeriske spredningskolonner...

SELECT GroupId, [A], [B]
FROM #OrigTxt
PIVOT( SUM(AggCol) FOR SpreadCol IN ([A],[B]) ) AS p;

SELECT GroupId, [10], [20]
FROM #OrigNum
PIVOT( SUM(AggCol) FOR SpreadCol IN ([10],[20]) ) AS p;


/*UNPIVOT*/

--Gemmer outputtet af sidste forespørgsel i temp-tabel:
SELECT GroupId, [10], [20]
INTO #PivotNum
FROM #OrigNum
PIVOT( SUM(AggCol) FOR SpreadCol IN ([10],[20]) ) AS p;

SELECT * FROM #OrigNum;
SELECT * FROM #PivotNum;

--UNPIVOT har næsten samme syntaks:
SELECT GroupId, SpreadColNew, AggColNew
FROM #PivotNum
UNPIVOT  (AggColNew FOR SpreadColNew IN ([10], [20])) up;  



DROP TABLE #OrigTxt;
DROP TABLE #OrigNum;
DROP TABLE #PivotNum;

/* [Stack Overflow] */

-- Posts indeholder 1 række pr. post med angivet posttype, creationdate mv., samt optællinger af svar og kommentarer mv.:
SELECT TOP 10 * FROM dbo.posts;
-- Vi vil her kun bruge PostCreationYear, PostTypeId og Commentcount for årene 2008-2010:
SELECT TOP 10 
  YEAR(CreationDate) AS PostCreationYear, PostTypeId, CommentCount FROM dbo.posts WHERE CreationDate BETWEEN CAST('20080101' AS date) AND CAST('20101231' AS date);


--Vil nu for hvert PostCreationYear optælle summen af CommentCount for hver af PostTypeId-værdierne som repræsenterer Questions og Answers

--Hvad er grupperingselementet? PostCreationYear
--Hvad er spredningselementet? PostTypeId
--Hvad er aggregeringselementet? CommentCount
--Hvad er aggregeringsfunktionen? SUM()

SELECT p.PostCreationYear, [1] AS Questions, [2] AS Answers
FROM (
  SELECT YEAR(CreationDate) AS PostCreationYear, PostTypeId, CommentCount FROM dbo.posts WHERE CreationDate BETWEEN CAST('20080101' AS date) AND CAST('20101231' AS date)
  ) posts
PIVOT ( SUM(CommentCount) FOR PostTypeId IN ([1],[2])) AS p;



/* [I opgaverne skal man lave beregninger a la eksemplerne, med og uden brug af PIVOT-operatoren. Det skal
    gerne illustrere effektiv og kompakt syntaksen bliver med PIVOT] */

/*
Opgave 1

Dette script danner en temporær tabel, #postbyusertype, som indeholder fire kolonner for poster, som er lukkede:
  PostClosedYear = Året hvor posten i dbo.Posts lukkedes
  UserType = 'Superuser' hvis Reputation i dbo.Users >= 10.000; 'User' ellers
  ViewCount = Antal visninger af posten i dbo.Posts */


SELECT YEAR(p.ClosedDate) AS PostClosedYear, CASE WHEN u.Reputation>=10000 THEN 'Superuser' ELSE 'User' END AS UserType, p.ViewCount
INTO #viewsbyusertypes
FROM dbo.Posts p 
INNER JOIN dbo.Users u ON u.Id=p.OwnerUserId
WHERE ClosedDate IS NOT NULL ;

/*
Du skal optælle det gennemsnitlige antal visninger for Users og Superusers fordelt på antal år med brug af PIVOT-operatoren. 

1.a. Hvad er 
  Grupperingselementet?
  Spredningselementet? 
  Aggregeringselementet? 
  Aggregeringsfunktionen?

1.b. Skriv en forespørgsel med brug af PIVOT-operatoren, som danner det ønskede output
1.c. Kig på resultatet. Hvad kan man konkludere om sammenhængen mellem reputation og visninger?


- Tabeller involveret:  #postsbyusertype (eller, om vil dbo.Posts og dbo.Users)
- Ønsket output:

PostClosedYear	User	Superuser
2008	7895	5460
2009	9876	13478
2010	4934	11035
2011	5348	9442
2012	4754	11972
2013	4309	10487
2014	6283	21185
2015	14236	19902
2016	22574	32564
2017	16269	24736
2018	18527	27985

*/

/*
Svar på opgaven:
*/
SELECT PostClosedYear, [User], [Superuser]
FROM #viewsbyusertypes
PIVOT(AVG(ViewCount) FOR UserType IN ([User],[Superuser])) p

DROP TABLE #viewsbyusertypes;
*/



/*UNPIVOT*/

/* [Mockup] */

CREATE TABLE #TableA (
  Id int NOT NULL,
  [2020] nvarchar(1) NOT NULL, 
  [2021] nvarchar(1) NOT NULL, 
  [2022] nvarchar(1) NOT NULL);

INSERT INTO #TableA (Id, [2020], [2021], [2022])
VALUES
(1, 'A', 'B', 'C'), 
(2, 'B', 'C', 'D'), 
(3, 'E', 'F', 'G');

SELECT * FROM #TableA;

-- UNPIVOT  
SELECT Id, [Year], [Value]
FROM #TableA
UNPIVOT  ([Value] FOR [Year] IN ([2020], [2021], [2022])) up;  

DROP TABLE #TableA

/* ***********************

Hovedpointer:



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