/* ***********************

Derived Tables

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
I en tidligere lab, skulle du finde brugere i StackOverflow-databasen, som ingen indlæg har lavet.

- Tabeller involveret: dbo.Users, dbo.Posts
- Ønsket output:
Id	    DisplayName	            Reputation
2901047	user2901047	            1
2474029	user2474029	            1
2740827	Said Falukatif Bakalli	1
...
(1.030.987 rows)

Et godt svar på denne opgave var scriptet her:
*/
SELECT
  u.Id,
  u.DisplayName,
  u.Reputation
FROM dbo.Users AS u
LEFT OUTER JOIN dbo.Posts AS p ON p.OwnerUserId = u.Id
WHERE p.Id IS NULL;

/*

OPGAVE 1: Lav et view, som indeholder scriptet. Navngiv viewet, så det afspejler indholdet (enten i dit eget schema eller med dit eget navn som del af viewets navn).

*/

/*

OPGAVE 2: Lav et nyt script, som ændrer viewet, så
    - Kolonnenavnene ændres til UserId, UserName og UserRepution.
    - Viewet indeholder alle brugere, både bruger med og uden indlæg. 
    - Viewet kun viser én linje pr. bruger og der tilføjes en kolonne, UserNumberOfPosts, som viser antal indlæg, brugeren har haft i alt. 


Når du laver SELECT * FROM <ditview>, sorteret med faldende antal UserNumberOfPosts, er følgende output ønsket:
UserId	UserName	UserReputation	UserNumberOfPosts
9073	Chris Smith	4068	        81
9082	wallyqs	    2483	        25
9090	Adi	        1368	        41
...
(2465713 rows)

*/


/*

OPGAVE 3: Slet dit view!

*/


/* ***********************

LØSNINGER

*********************** */

/* OPGAVE 1 */
GO
CREATE VIEW _minbruger_vUsersActivity AS
SELECT
  u.Id,
  u.DisplayName,
  u.Reputation
FROM dbo.Users AS u
LEFT OUTER JOIN dbo.Posts AS p ON p.OwnerUserId = u.Id
WHERE p.Id IS NULL;
GO

/* OPGAVE 2 */
GO 
ALTER VIEW _minbruger_vUsersActivity AS
SELECT
  u.Id AS UserId,
  u.DisplayName AS UserName,
  u.Reputation AS UserReputation,
  COUNT(p.OwnerUserId) AS UserNumberOfPosts
FROM dbo.Users AS u
LEFT OUTER JOIN dbo.Posts AS p ON p.OwnerUserId = u.Id
GROUP BY u.Id, u.DisplayName, u.Reputation
ORDER BY UserNumberOfPosts DESC;
GO

/* OPGAVE 3 */
GO 
DROP VIEW _minbruger_vUsersActivity;
GO

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