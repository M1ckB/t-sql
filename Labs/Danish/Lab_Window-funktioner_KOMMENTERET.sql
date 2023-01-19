/* ***********************

Emne: Window-funktioner
Version: 1.0
Dato: 2023-01-11

Laboratoriet kræver:

- En understøttet version af SQL Server
- En Stack Overflow database: https://www.BrentOzar.com/go/querystack

Agenda:

- Introduktion til konceptet om window-funktioner, deres opbygning og delsætninger
- Introduktion til forskellige familier af window-funktioner

Læs mere om window funktioner i Microsofts T-SQL reference:

- https://learn.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql?view=sql-server-ver16

*/

USE StackOverflow2013;
GO

/* ***********************

Introduktion til window-funktioner:

- Windowing bruges som et effektivt og fleksibelt værktøj til analytiske formål
- Window-funktioner er, i sin essens, nogle funktioner som for hver række laver en beregning over en mængde
    af rækker relateret til den aktuelle række
- Mængden af rækker som der laves en beregning henover, kaldes et vindue ("window")
- Modsat vores grupperede forespørgsler, så kan vi med window-funktioner bevare detaljen. Derudover
    kan man også definere en orden i sin beregning

*/

/* [
    - Vis eksempler som illustrerer hvordan window-funktioner fungerer vis-a-vis grupperede forespørgsler
    - Brug annoteringsværktøj til at tegne selve vinduet og evt. ordenen for en forespørgsel
   ]
*/

/* [Mockup] */

CREATE TABLE #TableA (
    Id int NOT NULL,
    Dat date NOT NULL,
    Cat nvarchar(100) NOT NULL,
    Val int NULL
);

INSERT INTO #TableA (Id, Dat, Cat, Val)
VALUES
(1, '20220101', 'A', 22), (2, '20000504', 'A', 5), (3, '20150205', 'A', 0),
(4, '20101203', 'B', 14), (5, '20050824', 'B', 79), (6, '20220930', 'B', 100),
(7, '20220315', 'B', 43), (8, '20210710', 'B', 43), (9, '20000504', 'C', 1),
(10, '20221231', 'C', 112);

SELECT
    *
FROM #TableA;

SELECT
    Cat,
    SUM(Val) AS TotalVal
FROM #TableA
GROUP BY Cat
ORDER BY Cat;

SELECT
    Id,
    Dat,
    Cat,
    Val,
    SUM(Val) OVER (PARTITION BY Cat) AS TotalVal,
    1.0 * Val / SUM(Val) OVER (PARTITION BY Cat) AS PctVal
FROM #TableA
ORDER BY Cat, Dat, Id;

SELECT
    Id,
    Cat,
    Val,
    RANK() OVER (
        PARTITION BY Cat
        ORDER BY Val DESC
    ) AS RankVal
FROM #TableA
ORDER BY Cat, Val DESC;

DROP TABLE #TableA;

/* [Stack Overflow] */

SELECT
    Id,
    CreationDate,
    OwnerUserId,
    Title,
    FavoriteCount
FROM dbo.Posts
WHERE PostTypeId = 1 -- Question
AND OwnerUserId IN (14388, 279932, 59711)
ORDER BY OwnerUserId, CreationDate, Id;

SELECT
    OwnerUserId,
    SUM(FavoriteCount) AS TotalFavoriteCount
FROM dbo.Posts
WHERE PostTypeId = 1 -- Question
AND OwnerUserId IN (14388, 279932, 59711)
GROUP BY OwnerUserId
ORDER BY OwnerUserId;

SELECT
    Id,
    OwnerUserId,
    CreationDate,
    FavoriteCount,
    SUM(FavoriteCount) OVER (PARTITION BY OwnerUserId) AS TotalFavoriteCount,
    1.0 * FavoriteCount / SUM(FavoriteCount) OVER (PARTITION BY OwnerUserId) AS PctFavoriteCount    
FROM dbo.Posts
WHERE PostTypeId = 1 -- Question
    AND OwnerUserId IN (14388, 279932, 59711)
ORDER BY OwnerUserId, CreationDate, Id;

SELECT
    Id,
    OwnerUserId,
    FavoriteCount,
    RANK() OVER (
        PARTITION BY OwnerUserId
        ORDER BY FavoriteCount DESC
    ) AS RankFavoriteCount
FROM dbo.Posts
WHERE PostTypeId = 1 -- Question
    AND OwnerUserId IN (14388, 279932, 59711)
ORDER BY OwnerUserId, FavoriteCount DESC;

/* [I opgaverne skal man lave beregninger a la eksemplerne, men uden brug af window-funktioner. Det skal
    gerne illustrere hvor elegante og hurtige window-funktioner er] */

/*

Opgave 1: Beregn for hver bruger, begrænset til brugerne 14388, 279932, 59711, de enkelte spørgsmåls
    andel af den samlede FavoriteCount (a la eksemplet) uden brug af window-funktioner? 

- Tabeller involveret:  dbo.Posts
- Ønsket output:
Id	    OwnerUserId	CreationDate	        FavoriteCount	PctFavoriteCount
388242	14388	    2008-12-23 05.23.56.063	9086	        1.000000000000
487258	59711	    2009-01-28 11.10.32.043	3662	        0.906884596334
577659	59711	    2009-02-23 13.37.45.853	20	            0.004952947003
...
(11 rows)
*/

/* [Man kan benytte sig af både et self join, en correlated subquery og en CTE] */

SELECT
    p1.Id,
    p1.OwnerUserId,
    p1.CreationDate,
    p1.FavoriteCount,
    1.0 * p1.FavoriteCount / SUM(p2.FavoriteCount) AS PctFavoriteCount
FROM dbo.Posts AS p1
INNER JOIN dbo.Posts AS p2
    ON p2.OwnerUserId = p1.OwnerUserId
    AND p2.PostTypeId = p1.PostTypeId
WHERE p1.PostTypeId = 1 -- Question
    AND p1.OwnerUserId IN (14388, 279932, 59711)
GROUP BY p1.Id, p1.OwnerUserId, p1.CreationDate, p1.FavoriteCount
ORDER BY OwnerUserId, CreationDate, Id;

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
        WHERE p2.PostTypeId = p1.PostTypeId
            AND p2.OwnerUserId = p1.OwnerUserId
    ) AS PctFavoriteCount
FROM dbo.Posts AS p1
WHERE p1.PostTypeId = 1 -- Question
AND p1.OwnerUserId IN (14388, 279932, 59711)
ORDER BY OwnerUserId, CreationDate, Id;

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
INNER JOIN Total_FavoriteCount AS p2
    ON p2.PostTypeId = p1.PostTypeId
    AND p2.OwnerUserId = p1.OwnerUserId
WHERE p1.PostTypeId = 1 -- Question
    AND p1.OwnerUserId IN (14388, 279932, 59711)
ORDER BY OwnerUserId, CreationDate, Id;

/*

Opgave 2: Rank FavoriteCount fra største til mindste for spørgsmål stillet af brugerne 14388, 279932, 59711
    (a la eksemplet) uden brug af window-funktioner? 

- Tabeller involveret:  dbo.Posts
- Ønsket output:
Id	    OwnerUserId	FavoriteCount	Rank_FavoriteCount
388242	14388	    9086	        1
487258	59711	    3662	        1
730620	59711	    324	            2
...
(11 rows)
*/

/* [Man kan benytte sig af både et self join og en correlated subquery, sidstnævnte er den mest oplagte] */

SELECT
    p1.Id,
    p1.OwnerUserId,
    p1.FavoriteCount,
    1 + COUNT(p2.Id) AS RankFavoriteCount
FROM dbo.Posts AS p1
LEFT OUTER JOIN dbo.Posts AS p2
    ON p2.OwnerUserId = p1.OwnerUserId
    AND p2.PostTypeId = p1.PostTypeId
    AND p2.FavoriteCount > p1.FavoriteCount
WHERE p1.PostTypeId = 1 -- Question
    AND p1.OwnerUserId IN (14388, 279932, 59711)
GROUP BY p1.Id, p1.OwnerUserId, p1.FavoriteCount
ORDER BY OwnerUserId, FavoriteCount DESC;

SELECT
    p1.Id,
    p1.OwnerUserId,
    p1.FavoriteCount,
    (
        SELECT
            COUNT(*) AS RankFavoriteCount
        FROM dbo.Posts AS p2
        WHERE p2.PostTypeId = p1.PostTypeId
            AND p2.OwnerUserId = p1.OwnerUserId
            AND p2.FavoriteCount > p1.FavoriteCount
    ) + 1 AS RankFavoriteCount
FROM dbo.Posts AS p1
WHERE p1.PostTypeId = 1 -- Question
AND p1.OwnerUserId IN (14388, 279932, 59711)
ORDER BY OwnerUserId, FavoriteCount DESC;

/* ***********************

Opbygningen af window-funktioner:

Window-funktioner er overordnet opbygget af to elementer:
    1. Funktionen, eller beregningen, som ønskes foretaget, fx COUNT, RANK eller FIRST_VALUE
    2. Specifikationen af selve vinduet i OVER-delsætningen

SELECT
    <funktion> OVER (
        PARTITION BY <opdelingskolonner>
        ORDER BY <sorteringskolonner>
        ROWS/RANGE BETWEEN <øvre grænse> AND <nedre grænse>
    ) AS Beregning

OVER-delsætningen giver følgende muligheder for at specificere vinduet:

- Partitioning: Bruges til at opdele forespørgslen i grupper som beregningen foretages for.
    Hvis ikke denne angives, så laves beregningen for hele forespørgslen
- Ordering: Bruges til at bestemme ordenen som rækker evalueres i inden for en window-frame
- Framing: Bruges til udvælge en delmængde af rækker inden for en window-partiton

Bemærk, at ikke alle muligheder kan tages i brug for alle funktioner.

*/

/* [Med udgangspunkt i det samme eksempel ændres specifikationen af vinduet og konsekvenserne noteres] */

/* [Mockup] */

CREATE TABLE #TableA (
    Id int NOT NULL,
    Dat date NOT NULL,
    Cat nvarchar(100) NOT NULL,
    Val int NULL
);

INSERT INTO #TableA (Id, Dat, Cat, Val)
VALUES
(1, '20220101', 'A', 22), (2, '20000504', 'A', 5), (3, '20150205', 'A', 0),
(4, '20101203', 'B', 14), (5, '20050824', 'B', 79), (6, '20220930', 'B', 100),
(7, '20220315', 'B', 43), (8, '20210710', 'B', 43), (9, '20000504', 'C', 1),
(10, '20221231', 'C', 112);

SELECT
    *
FROM #TableA;

SELECT
    Id,
    Cat,
    Dat,
    Val,
    ROW_NUMBER() OVER (
        PARTITION BY Cat
        ORDER BY Dat, Id
        --ORDER BY Dat DESC, Id DESC
    ) AS RowNum
FROM #TableA
ORDER BY Cat, Dat, Id;

SELECT
    Id,
    Cat,
    Dat,
    Val,
    SUM(Val) OVER (
        PARTITION BY Cat
        ORDER BY Dat, Id
        /*RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW*/
        --ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS RunningTotalVal
FROM #TableA
ORDER BY Cat, Dat, Id;

DROP TABLE #TableA;

/* [Stack Overflow] */

SELECT
    Id,
    OwnerUserId,
    CreationDate,
    ROW_NUMBER() OVER (
        PARTITION BY OwnerUserId
        ORDER BY CreationDate, Id
        --ORDER BY CreationDate DESC, Id DESC
    ) AS RowNum
FROM dbo.Posts
WHERE PostTypeId = 1 -- Question
    AND OwnerUserId IN (14388, 279932, 59711)
ORDER BY OwnerUserId, CreationDate, Id;

SELECT
    Id,
    OwnerUserId,
    CreationDate,
    FavoriteCount,
    SUM(FavoriteCount) OVER (
        PARTITION BY OwnerUserId
        ORDER BY CreationDate, Id
        /*RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW*/
        --ROWS BETWEEN 2 PRECEDING AND CURRENT ROW        
    ) AS RunningTotalFavoriteCount 
FROM dbo.Posts
WHERE PostTypeId = 1 -- Question
    AND OwnerUserId IN (14388, 279932, 59711)
ORDER BY OwnerUserId, CreationDate, Id;

/*

Opgave 3: Rank omdømme fra størst til lavest for brugere fra Danmark ('Denmark').

- Tabeller involveret:  dbo.Users
- Ønsket output:
Id	    DisplayName	            CreationDate	        Reputation	RankReputation
61974	Mark Byers	            2009-02-03 14.56.00.380	563558	    1
13627	driis	                2008-09-16 20.16.07.617	118224	    2
218589	Klaus Byskov Pedersen	2009-11-25 13.19.42.430	79949	    3
...
(2.462 rows)
*/

/* [Opgaven skal henlede opmærksomheden på konsekvensen af at udelade en window-partition] */

SELECT
    Id,
    DisplayName,
    CreationDate,
    Reputation,
    RANK() OVER(ORDER BY Reputation DESC) AS RankReputation
FROM dbo.Users
WHERE [Location] = 'Denmark';

/* ***********************

Logisk processering af window-funktioner i forespørgsel:

I vores logiske processering af en forespørgsel evalueres window-funktioner på følgende trin (markeret
    med X):

1. FROM
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT
    5.1 Evaluering af udtryk (X)
    5.2 Fjernelse af dubletter
6. ORDER BY (X)
7. OFFSET-FETCH/TOP

Dvs. i udgangspunktet understøttes window-funktioner udelukkende i SELECT- og ORDER BY-delsætningerne.
    Denne begrænsning skal sikre entydighed omkring hvilken underliggende tabel der laves beregninger på.

Hvis vi ønsker at bruge window-funktioner i andre delsætninger, så bliver vi nødt til at lave beregninger
    trinvist.

*/

/* [I stedet for opgaver, så laves der en demo af pointerne hvor der spørges ud i plenum løbende] */

/* [Mockup] */

CREATE TABLE #TableA (
    Id int NOT NULL,
    Col date NOT NULL
);

INSERT INTO #TableA (Id, Col)
VALUES
(1, '20220502'), (2, '20220314'), (3, '20230101'), (4, '20220314'), (5, '20220630');

SELECT
    *
FROM #TableA;

/* [Med udgangspunkt i det samme eksempel flyttes window-funktionen til forskellige delsætninger for at
    undersøge hvor den virker] */

SELECT
    Id,
    Col,
    ROW_NUMBER() OVER (ORDER BY Col, Id) AS RowNum
FROM #TableA
--WHERE ROW_NUMBER() OVER (ORDER BY Col, Id) = 1
--ORDER BY ROW_NUMBER() OVER (ORDER BY Col, Id)
;

/* [Vis eksempel på hvordan tolkningen af window-funktioner ikke er entydig hvis den blev evalueret logisk
    i en anden fase] */

/* Et tænkt eksempel: Hvad vil forespørgslen nedenfor returnere? 3 eller 3 og 5? */

SELECT
    Id
FROM #TableA
WHERE Col > '20220501'
    AND ROW_NUMBER() OVER (ORDER BY Col, Id) > 2
--WHERE ROW_NUMBER() OVER (ORDER BY Col, Id) > 2
--    AND Col > '20220501'
;

/* [Vis eksempel på window-funktioner og samspillet med DISTINCT] */

/* Kan du gætte resultatet af nedenstående query? */

SELECT DISTINCT
    Col,
    ROW_NUMBER() OVER(ORDER BY Col) AS RowNum
FROM #TableA
ORDER BY Col;

/* [Vis eksempel på hvordan window-funktioner alligevel kan tages i brug i andre delsætninger, fx via
    en CTE] */

/* Hvordan kan vi komme uden om begrænsingen forårsaget af den logiske query processering? */

WITH CTE AS (
    SELECT
        Id,
        Col,
        ROW_NUMBER() OVER(ORDER BY Col, Id) AS RowNum
    FROM #TableA
)

SELECT
    *
FROM CTE
WHERE RowNum > 2;

DROP TABLE #TableA;

/* ***********************

Introduktion til familier af window-funktioner:

Der findes forskellige familier af window-funktioner:

- Ranking (læs mere: https://learn.microsoft.com/en-us/sql/t-sql/functions/ranking-functions-transact-sql?view=sql-server-ver16)
- Offset (læs mere: https://learn.microsoft.com/en-us/sql/t-sql/functions/analytic-functions-transact-sql?view=sql-server-ver16)
- Aggregering (læs mere: https://learn.microsoft.com/en-us/sql/t-sql/functions/aggregate-functions-transact-sql?view=sql-server-ver16)
- (Statistik)

*/

/* [
    - Vis et eksempel med hver af de tre første familier af funktioner og nævn blot den sidste
    - Læg vægt på:
        1. De forskellige beregningsmuligheder
        2. Hvilke vinduesspecifikationer som understøttes
    ] */

/* [Mockup] */

CREATE TABLE #TableA (
    Id int NOT NULL,
    Dat date NOT NULL,
    Cat nvarchar(100) NOT NULL,
    Val int NULL
);

INSERT INTO #TableA (Id, Dat, Cat, Val)
VALUES
(1, '20220101', 'A', 22), (2, '20000504', 'A', 5), (3, '20150205', 'A', 0),
(4, '20101203', 'B', 14), (5, '20050824', 'B', 79), (6, '20220930', 'B', 100),
(7, '20220315', 'B', 43), (8, '20210710', 'B', 43), (9, '20000504', 'C', 1),
(10, '20221231', 'C', 112);

SELECT
    *
FROM #TableA;

/* Ranking: */

SELECT
    Id,
    Dat,
    Cat,
    Val,
    ROW_NUMBER() OVER(
        PARTITION BY Cat
        ORDER BY Val
    ) AS RowNum,
    RANK() OVER(
        PARTITION BY Cat
        ORDER BY Val
    ) AS Rank,
    DENSE_RANK() OVER(
        PARTITION BY Cat
        ORDER BY Val
    ) AS DenseRank,
    NTILE(2) OVER(
        PARTITION BY Cat
        ORDER BY Val
    ) AS NTile
FROM #TableA
ORDER BY Cat, Val;

/* Offset: */

SELECT
    Id,
    Dat,
    Cat,
    Val,
    LAG(Val/*, 1, NULL*/) OVER(
        PARTITION BY Cat
        ORDER BY Val
    ) AS PrevVal,
    LEAD(Val/*, 1, NULL*/) OVER(
        PARTITION BY Cat
        ORDER BY Val
    ) AS NextVal,
    FIRST_VALUE(Val) OVER(
        PARTITION BY Cat
        ORDER BY Val
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS FirstVal,
    LAST_VALUE(Val) OVER(
        PARTITION BY Cat
        ORDER BY Val
        ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
    ) AS LastVal
FROM #TableA
ORDER BY Cat, Val;

/* Aggregering: */

SELECT
    Id,
    Dat,
    Cat,
    Val,
    COUNT(*) OVER(
        PARTITION BY Cat
        /*ORDER BY Val
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW*/
    ) AS Cnt,
    MIN(Val) OVER(
        PARTITION BY Cat
        /*ORDER BY Val
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW*/
    ) AS MinVal,
    MAX(Val) OVER(
        PARTITION BY Cat
        /*ORDER BY Val
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW*/
    ) AS MaxVal,
    SUM(Val) OVER(
        PARTITION BY Cat
        /*ORDER BY Val
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW*/
    ) AS SumVal
FROM #TableA
ORDER BY Cat, Val;

DROP TABLE #TableA;

/* [Stack Overflow] */

/* Ranking: */

SELECT
    Id,
    DisplayName,
    [Location],
    Reputation,
    ROW_NUMBER() OVER(
        ORDER BY Reputation
    ) AS RowNum,
    RANK() OVER(
        ORDER BY Reputation
    ) AS Rank,
    DENSE_RANK() OVER(
        ORDER BY Reputation
    ) AS DenseRank,
    NTILE(2) OVER(
        ORDER BY Reputation
    ) AS NTile
FROM dbo.Users
WHERE [Location] = 'Denmark'
ORDER BY Reputation;

/* Offset: */

SELECT
    Id,
    DisplayName,
    [Location],
    Reputation,
    LAG(Reputation/*, 1, NULL*/) OVER(
        ORDER BY Reputation
    ) AS PrevVal,
    LEAD(Reputation/*, 1, NULL*/) OVER(
        ORDER BY Reputation
    ) AS NextVal,
    FIRST_VALUE(Reputation) OVER(
        ORDER BY Reputation
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS FirstVal,
    LAST_VALUE(Reputation) OVER(
        ORDER BY Reputation
        ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
    ) AS LastVal
FROM dbo.Users
WHERE [Location] = 'Denmark'
ORDER BY Reputation;

/* Aggregering: */

SELECT
    Id,
    DisplayName,
    [Location],
    Reputation,
    COUNT(*) OVER(
        /*ORDER BY Reputation
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW*/
    ) AS Cnt,
    MIN(Reputation) OVER(
        ORDER BY Reputation
    ) AS MinVal,
    MAX(Reputation) OVER(
        /*ORDER BY Reputation
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW*/
    ) AS MaxVal,
    SUM(Reputation) OVER(
        /*ORDER BY Reputation
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW*/
    ) AS SumVal
FROM dbo.Users
WHERE [Location] = 'Denmark'
ORDER BY Reputation;

/*

Opgave 4: Dan et rækkenummer for spørgsmål lavet af bruger 214. Rækkenummeret skal
    være sorteret efter antal visninger og dernæst oprettelsestidspunktet.

- Tabeller involveret:  dbo.Posts
- Ønsket output:
Id	    OwnerUserId	Title	                        ViewCount	CreationDate	        Rownum
7610390	214	        Deriving a random long value...	42          2011-09-30 12.30.47.453	1
9175497	214	        Redundancy in web API	        88	        2012-02-07 11.33.20.793	2
8098868	214	        ? extends TSubject extends...	112	        2011-11-11 19.22.41.780	3
...
(44 rows)
*/

SELECT
    Id,
    OwnerUserId,
    Title,
    ViewCount,
    CreationDate,
    ROW_NUMBER() OVER(ORDER BY ViewCount, CreationDate) AS RowNum
FROM dbo.Posts
WHERE PostTypeId = 1 -- Question
AND OwnerUserId = 214
ORDER BY ViewCount, CreationDate;

/*

Opgave 5: Beregn forskellen i antal visninger mellem et aktuelt spørgsmål
    og spørgsmålet før for bruger 214. Såfremt der ikke er et tidligere
    spørgsmål, så fratrækkes 0.

- Tabeller involveret:  dbo.Posts
- Ønsket output:
Id	    OwnerUserId	Title	                            CreationDate	        ViewCount	DiffViewCount
761	    214	        Localising date format descriptors	2008-08-03 17.30.20.473	633	        633
12271	214	        Creating Visual Studio templates...	2008-08-15 14.04.01.017	270	        -363
190915	214	        Using tables in UDF's in Excel 2007	2008-10-10 11.35.22.773	870	        600
...
(44 rows)
*/

SELECT
    Id,
    OwnerUserId,
    Title,
    CreationDate,
    ViewCount,
    ViewCount - LAG(ViewCount, 1, 0) OVER(ORDER BY CreationDate) AS DiffViewCount
FROM dbo.Posts
WHERE PostTypeId = 1 -- Question
AND OwnerUserId = 214
ORDER BY CreationDate;

/*

Opgave 6: Beregn for hvert år en kumuleret sum af antal visninger
    baseret på oprettelsestidspunkt for spørgsmål lavet af bruger 214.

- Tabeller involveret:  dbo.Posts
- Ønsket output:
Id	    OwnerUserId	CreationYear	CreationDate	        ViewCount	RunningTotalViewCount
761	    214	        2008	        2008-08-03 17.30.20.473	633	        633
12271	214	        2008	        2008-08-15 14.04.01.017	270	        903
190915	214	        2008	        2008-10-10 11.35.22.773	870	        1773
...
(44 rows)
*/

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
WHERE PostTypeId = 1 -- Question
AND OwnerUserId = 214
ORDER BY CreationDate;

/* ***********************

Hovedpointer:

- Window-funktioner er et uundværligt værktøj til analytikeren
- Window-funktioner laver, for hver række, en beregning over en mængde af rækker relateret til den
    aktuelle række
- En window-funktion består af følgende elementer:
    1. En funktion, fx COUNT, RANK eller FIRST_VALUE
    2. En specifikation af et vindue i OVER-delsætningen via Partitioning, Odering og Framing
- Window-funktioner evalueres logisk i SELECT- og ORDER BY-delsætningerne
- Der findes forskellige typer af window-funktioner, herunder funktioner til ranking, offset,
    aggregeringer og statistik

*/
