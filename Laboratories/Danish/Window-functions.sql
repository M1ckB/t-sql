/* ***********************

WINDOW-FUNKTIONER

Udviklet af Thomas Lange & Mick Ahlmann Brun

Mere info: https://github.com/M1ckB/T-SQL

Version 1.0 2023-01-11

Laboratoriet kræver:

- En understøttet version af SQL Server
- En Stack Overflow database: https://www.BrentOzar.com/go/querystack (medium)

Læs mere om window funktioner i Microsofts T-SQL reference:

- https://learn.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql?view=sql-server-ver16

Du kan finde løsninger og svar på opgaverne nederst i scriptet.

*********************** */

USE StackOverflow2013;
GO

/* ***********************

ØVELSER

*********************** */

/*

OPGAVE 1: Beregn for hver bruger, begrænset til brugerne 14388, 279932, 59711, de enkelte spørgsmåls
    andel af den samlede FavoriteCount uden brug af window-funktioner.

- Tabeller involveret: dbo.Posts
- Ønsket output:
Id	    OwnerUserId	CreationDate	        FavoriteCount	PctFavoriteCount
388242	14388	    2008-12-23 05.23.56.063	9086	        1.000000000000
487258	59711	    2009-01-28 11.10.32.043	3662	        0.906884596334
577659	59711	    2009-02-23 13.37.45.853	20	            0.004952947003
...
(11 rows)

*/

/*

OPGAVE 2: Rank FavoriteCount fra største til mindste for spørgsmål stillet af brugerne 14388,
    279932, 59711 uden brug af window-funktioner? 

- Tabeller involveret: dbo.Posts
- Ønsket output:
Id	    OwnerUserId	FavoriteCount	Rank_FavoriteCount
388242	14388	    9086	        1
487258	59711	    3662	        1
730620	59711	    324	            2
...
(11 rows)

*/

/*

OPGAVE 3: Rank omdømme fra størst til lavest for brugere fra Danmark ('Denmark').

- Tabeller involveret: dbo.Users
- Ønsket output:
Id	    DisplayName	            CreationDate	        Reputation	RankReputation
61974	Mark Byers	            2009-02-03 14.56.00.380	563558	    1
13627	driis	                2008-09-16 20.16.07.617	118224	    2
218589	Klaus Byskov Pedersen	2009-11-25 13.19.42.430	79949	    3
...
(2.462 rows)

*/

/*

OPGAVE 4: Dan et rækkenummer for spørgsmål lavet af bruger 214. Rækkenummeret skal
    være sorteret efter antal visninger og dernæst oprettelsestidspunktet.

- Tabeller involveret: dbo.Posts
- Ønsket output:
Id	    OwnerUserId	Title	                        ViewCount	CreationDate	        Rownum
7610390	214	        Deriving a random long value...	42          2011-09-30 12.30.47.453	1
9175497	214	        Redundancy in web API	        88	        2012-02-07 11.33.20.793	2
8098868	214	        ? extends TSubject extends...	112	        2011-11-11 19.22.41.780	3
...
(44 rows)

*/

/*

OPGAVE 5: Beregn forskellen i antal visninger mellem et aktuelt spørgsmål og spørgsmålet før
    for bruger 214. Såfremt der ikke er et tidligere spørgsmål, så fratrækkes 0.

- Tabeller involveret: dbo.Posts
- Ønsket output:
Id	    OwnerUserId	Title	                            CreationDate	        ViewCount	DiffViewCount
761	    214	        Localising date format descriptors	2008-08-03 17.30.20.473	633	        633
12271	214	        Creating Visual Studio templates...	2008-08-15 14.04.01.017	270	        -363
190915	214	        Using tables in UDF's in Excel 2007	2008-10-10 11.35.22.773	870	        600
...
(44 rows)

*/

/*

OPGAVE 6: Beregn for hvert år en kumuleret sum af antal visninger baseret på oprettelsestidspunkt
    for spørgsmål lavet af bruger 214.

- Tabeller involveret: dbo.Posts
- Ønsket output:
Id	    OwnerUserId	CreationYear	CreationDate	        ViewCount	RunningTotalViewCount
761	    214	        2008	        2008-08-03 17.30.20.473	633	        633
12271	214	        2008	        2008-08-15 14.04.01.017	270	        903
190915	214	        2008	        2008-10-10 11.35.22.773	870	        1773
...
(44 rows)

*/

/* ***********************

LØSNINGER

*********************** */

/* OPGAVE 1 */

/* Window-funktioner løser mange opgaver mere kompakt og effektivt end det ellers er muligt.
    Nedenfor er nogle løsningsforslag til hvad man kan gøre uden */

/* Med et self-join: */

SELECT
    p1.Id,
    p1.OwnerUserId,
    p1.CreationDate,
    p1.FavoriteCount,
    1.0 * p1.FavoriteCount / SUM(p2.FavoriteCount) AS PctFavoriteCount
FROM dbo.Posts AS p1
INNER JOIN dbo.Posts AS p2 ON p2.OwnerUserId = p1.OwnerUserId AND p2.PostTypeId = p1.PostTypeId
WHERE p1.PostTypeId = 1 /* Question */ AND p1.OwnerUserId IN (14388, 279932, 59711)
GROUP BY p1.Id, p1.OwnerUserId, p1.CreationDate, p1.FavoriteCount
ORDER BY OwnerUserId, CreationDate, Id;

/* Med en correlated subquery: */

SELECT
    p1.Id,
    p1.OwnerUserId,
    p1.CreationDate,
    p1.FavoriteCount,
    1.0 * p1.FavoriteCount / 
    (
        SELECT
            SUM(p2.FavoriteCount)
        FROM dbo.Posts AS p2
        WHERE p2.PostTypeId = p1.PostTypeId AND p2.OwnerUserId = p1.OwnerUserId
    ) AS PctFavoriteCount
FROM dbo.Posts AS p1
WHERE p1.PostTypeId = 1 /* Question */ AND p1.OwnerUserId IN (14388, 279932, 59711)
ORDER BY OwnerUserId, CreationDate, Id;

/* Med en CTE: */

WITH Total_FavoriteCount AS (
    SELECT
        PostTypeId,
        OwnerUserId,
        SUM(FavoriteCount) AS TotalFavoriteCount
    FROM dbo.Posts
    GROUP BY PostTypeId, OwnerUserId
)

SELECT
    p1.Id,
    p1.OwnerUserId,
    p1.CreationDate,
    p1.FavoriteCount,
    1.0 * p1.FavoriteCount / p2.TotalFavoriteCount AS PctFavoriteCount
FROM dbo.Posts AS p1
INNER JOIN Total_FavoriteCount AS p2 ON p2.PostTypeId = p1.PostTypeId AND p2.OwnerUserId = p1.OwnerUserId
WHERE p1.PostTypeId = 1 /* Question */ AND p1.OwnerUserId IN (14388, 279932, 59711)
ORDER BY OwnerUserId, CreationDate, Id;

/* OPGAVE 2 */

/* Igen er der flere løsninger på et problem som dette, men fælles for dem alle er at de
    er mere komplekse og mindre effektive end hvis vi havde haft en window-funktion til
    rådighed */

/* Med et self-join: */

SELECT
    p1.Id,
    p1.OwnerUserId,
    p1.FavoriteCount,
    1 + COUNT(p2.Id) AS RankFavoriteCount
FROM dbo.Posts AS p1
LEFT OUTER JOIN dbo.Posts AS p2 ON p2.OwnerUserId = p1.OwnerUserId AND p2.PostTypeId = p1.PostTypeId
    AND p2.FavoriteCount > p1.FavoriteCount
WHERE p1.PostTypeId = 1 /* Question */ AND p1.OwnerUserId IN (14388, 279932, 59711)
GROUP BY p1.Id, p1.OwnerUserId, p1.FavoriteCount
ORDER BY OwnerUserId, FavoriteCount DESC;

/* Med en correlated subquery: */

SELECT
    p1.Id,
    p1.OwnerUserId,
    p1.FavoriteCount,
    (
        SELECT
            COUNT(*) AS RankFavoriteCount
        FROM dbo.Posts AS p2
        WHERE p2.PostTypeId = p1.PostTypeId AND p2.OwnerUserId = p1.OwnerUserId
            AND p2.FavoriteCount > p1.FavoriteCount
    ) + 1 AS RankFavoriteCount
FROM dbo.Posts AS p1
WHERE p1.PostTypeId = 1 /* Question */ AND p1.OwnerUserId IN (14388, 279932, 59711)
ORDER BY OwnerUserId, FavoriteCount DESC;

/* Den sidste løsning er den mest oplagte */

/* OPGAVE 3 */

/* Når der udelades en window-partition, så fungerer hele den underliggende forespørgsel
    som vindue */

SELECT
    Id,
    DisplayName,
    CreationDate,
    Reputation,
    RANK() OVER(ORDER BY Reputation DESC) AS RankReputation
FROM dbo.Users
WHERE [Location] = 'Denmark';

/* OPGAVE 4 */

SELECT
    Id,
    OwnerUserId,
    Title,
    ViewCount,
    CreationDate,
    ROW_NUMBER() OVER(ORDER BY ViewCount, CreationDate) AS RowNum
FROM dbo.Posts
WHERE PostTypeId = 1 /* Question */ AND OwnerUserId = 214
ORDER BY ViewCount, CreationDate;

/* OPGAVE 5 */

SELECT
    Id,
    OwnerUserId,
    Title,
    CreationDate,
    ViewCount,
    ViewCount - LAG(ViewCount, 1, 0) OVER(ORDER BY CreationDate) AS DiffViewCount
FROM dbo.Posts
WHERE PostTypeId = 1 /* Question */ AND OwnerUserId = 214
ORDER BY CreationDate;

/* OPGAVE 6 */

SELECT
    Id,
    OwnerUserId,
    YEAR(CreationDate) AS CreationYear,
    CreationDate,
    ViewCount,
    SUM(ViewCount) OVER (
        PARTITION BY YEAR(CreationDate)
        ORDER BY CreationDate
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningTotalViewCount
FROM dbo.Posts
WHERE PostTypeId = 1 /*  Question */ AND OwnerUserId = 214
ORDER BY CreationDate;

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
