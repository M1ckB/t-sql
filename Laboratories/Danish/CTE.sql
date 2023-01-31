/* ***********************

CTE (Common Table Expression)

Udviklet af Thomas Lange & Mick Ahlmann Brun

Mere info: https://github.com/M1ckB/T-SQL

Version 1.0 2023-01-29

Laboratoriet kræver:

- En understøttet version af SQL Server
- En Stack Overflow database: https://www.BrentOzar.com/go/querystack (medium)

Læs mere om Common Table Expressions i Microsofts T-SQL reference:

- https://learn.microsoft.com/en-us/sql/t-sql/queries/with-common-table-expression-transact-sql?view=sql-server-ver16

Du kan finde løsninger og svar på opgaverne nederst i scriptet.

*********************** */

USE StackOverflow2013;
GO

/* ***********************

ØVELSER

*********************** */

/* 

OPGAVE 1: Lav en forespørsel af Id og Title for posten med Id=1711. Brug en CTE til at filtrere og
    udvælge kolonner.

- Tabeller involveret: dbo.Posts
- Ønsket output:
Id        Title
1711	  What is the single most influential book every programmer should read?
(1 row)

*/

/*

OPGAVE 2: Find Id'er, ParentId'er og hierarkilevel for alle poster, som er eller som via ParentId-kolonnen
    direkte refererer posten med Id=1711'.
TIP: Du skal bruge nogle tricks for at opnå nedenstående struktur
    - OR-operator i WHERE-betingelsen, 
    - CASE WHEN-betingelse i SELECT-delsætningen, og
    - ORDER BY med stigende rækkefølge af en eller flere kolonner.

- Tabeller involveret: dbo.Posts
- Ønsket output:
Id	    ParentId	HierarchyLevel
1711	0	        0
1713	1711	    1
1788	1711	    1
...
(215 rows)

*/

/*

OPGAVE 3: Hvordan kan du også medtage eventuelle poster, som ikke refererer direkte til denne post,
    men kun gennem flere led af ParentId'er? 

- Tabeller involveret: dbo.Posts
- Ønsket output:
Id	    ParentId	HierarchyLevel
1711	0	        0
1713	1711	    1
1788	1711	    1
...
(215 rows)

*/

/* ***********************

LØSNINGER

*********************** */

/* OPGAVE 1 */

WITH SimpleCTE AS (
    SELECT Id, Title
    FROM dbo.Posts
    WHERE Id=1711
)
SELECT * FROM SimpleCTE;

/* OPGAVE 2 */

SELECT 
    Id, 
    ParentId, 
    CASE WHEN Id=1711 THEN 0 ELSE 1 END AS HierarchyLevel
FROM dbo.Posts
WHERE Id = 1711 OR ParentId=1711
ORDER BY HierarchyLevel, Id;

/* OPGAVE 3 */

WITH RecCTE AS 
( 
    --Anchor   
    SELECT Id, ParentId, 0 AS HierarchyLevel
    FROM dbo.Posts
    WHERE Title='What is the single most influential book every programmer should read?' --langsommere alternativ, da ikke index på denne kolonne!
    --WHERE Id=1711 --hurtigere alternativ da Id er primær nøgle (PK) og dermed indeks!

    UNION ALL

    --Recursive part
    SELECT p.Id, p.ParentId, r.HierarchyLevel+1 AS HierarchyLevel
    FROM RecCTE AS r
    INNER JOIN dbo.Posts AS p ON p.ParentId = r.Id 
) 
SELECT * 
FROM RecCTE 
ORDER BY HierarchyLevel, Id;

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