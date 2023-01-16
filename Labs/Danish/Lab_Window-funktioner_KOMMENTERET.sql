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

CREATE TABLE TabelA (
    Id int NOT NULL,
    Dato date NOT NULL,
    Kategori nvarchar(100) NOT NULL,
    Værdi int NULL
);

INSERT INTO TabelA (Id, Dato, Kategori, Værdi)
VALUES
(1, '20220101', 'A', 22), (2, '20000504', 'A', 5), (3, '20150205', 'A', 0),
(4, '20101203', 'B', 14), (5, '20050824', 'B', 79), (6, '20220930', 'B', 100), (7, '20220315', 'B', 43), (8, '20210710', 'B', 43),
(9, '20000504', 'C', 1), (10, '20221231', 'C', 112);

SELECT
    *
FROM TabelA;

SELECT
    Kategori,
    SUM(Værdi) AS Total_Værdi
FROM TabelA
GROUP BY Kategori
ORDER BY Kategori;

SELECT
    Id,
    Dato,
    Kategori,
    Værdi,
    SUM(Værdi) OVER (PARTITION BY Kategori) AS Total_Værdi,
    1.0 * Værdi / SUM(Værdi) OVER (PARTITION BY Kategori) AS Pct_Værdi
FROM TabelA
ORDER BY Kategori, Dato, Id;

SELECT
    Id,
    Kategori,
    Værdi,
    RANK() OVER (
        PARTITION BY Kategori
        ORDER BY Værdi DESC
    ) AS Rank_Værdi
FROM TabelA
ORDER BY Kategori, Værdi DESC;

DROP TABLE TabelA;

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
    SUM(FavoriteCount) AS Total_FavoriteCount
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
    SUM(FavoriteCount) OVER (PARTITION BY OwnerUserId) AS Total_FavoriteCount,
    1.0 * FavoriteCount / SUM(FavoriteCount) OVER (PARTITION BY OwnerUserId) AS Pct_FavoriteCount    
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
    ) AS Rank_FavoriteCount
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
- Ønsket output:        Id, OwnerUserId, CreationDate, FavoriteCount, Pct_FavoriteCount (beregnet)

*/

/* [Man kan benytte sig af både et self join, en correlated subquery og en CTE] */

SELECT
    p1.Id,
    p1.OwnerUserId,
    p1.CreationDate,
    p1.FavoriteCount,
    1.0 * p1.FavoriteCount / SUM(p2.FavoriteCount) AS Pct_FavoriteCount
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
    ) AS Pct_FavoriteCount
FROM dbo.Posts AS p1
WHERE p1.PostTypeId = 1 -- Question
AND p1.OwnerUserId IN (14388, 279932, 59711)
ORDER BY OwnerUserId, CreationDate, Id;

WITH Total_FavoriteCount AS (
    SELECT
        PostTypeId,
        OwnerUserId,
        SUM(FavoriteCount) AS Total_FavoriteCount
    FROM dbo.Posts
    GROUP BY PostTypeId, OwnerUserId
)

SELECT
    p1.Id,
    p1.OwnerUserId,
    p1.CreationDate,
    p1.FavoriteCount,
    1.0 * p1.FavoriteCount / p2.Total_FavoriteCount AS Pct_FavoriteCount
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
- Ønsket output:        Id, OwnerUserId, FavoriteCount, Rank_FavoriteCount (beregnet)

*/

/* [Man kan benytte sig af både et self join og en correlated subquery, sidstnævnte er den mest oplagte] */

SELECT
    p1.Id,
    p1.OwnerUserId,
    p1.FavoriteCount,
    1 + COUNT(p2.Id) AS Rank_FavoriteCount
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
            COUNT(*) AS Rank_FavoriteCount
        FROM dbo.Posts AS p2
        WHERE p2.PostTypeId = p1.PostTypeId
            AND p2.OwnerUserId = p1.OwnerUserId
            AND p2.FavoriteCount > p1.FavoriteCount
    ) + 1 AS Rank_FavoriteCount
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

CREATE TABLE TabelA (
    Id int NOT NULL,
    Dato date NOT NULL,
    Kategori nvarchar(100) NOT NULL,
    Værdi int NULL
);

INSERT INTO TabelA (Id, Dato, Kategori, Værdi)
VALUES
(1, '20220101', 'A', 22), (2, '20000504', 'A', 5), (3, '20150205', 'A', 0),
(4, '20101203', 'B', 14), (5, '20050824', 'B', 79), (6, '20220930', 'B', 100), (7, '20220315', 'B', 43), (8, '20210710', 'B', 43),
(9, '20000504', 'C', 1), (10, '20221231', 'C', 112);

SELECT
    *
FROM TabelA;

SELECT
    Id,
    Kategori,
    Dato,
    Værdi,
    ROW_NUMBER() OVER (
        PARTITION BY Kategori
        ORDER BY Dato, Id
        --ORDER BY Dato DESC, Id DESC
    ) AS Nr
FROM TabelA
ORDER BY Kategori, Dato, Id;

SELECT
    Id,
    Kategori,
    Dato,
    Værdi,
    SUM(Værdi) OVER (
        PARTITION BY Kategori
        ORDER BY Dato, Id
        /*RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW*/
        --ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS LøbendeTotal_Værdi
FROM TabelA
ORDER BY Kategori, Dato, Id;

DROP TABLE TabelA;

/* [Stack Overflow] */

SELECT
    Id,
    OwnerUserId,
    CreationDate,
    ROW_NUMBER() OVER (
        PARTITION BY OwnerUserId
        ORDER BY CreationDate, Id
        --ORDER BY CreationDate DESC, Id DESC
    ) AS Num
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
    ) AS RunningTotal_FavoriteCount 
FROM dbo.Posts
WHERE PostTypeId = 1 -- Question
    AND OwnerUserId IN (14388, 279932, 59711)
ORDER BY OwnerUserId, CreationDate, Id;

/*

Opgave 3: Rank omdømme fra størst til lavest for brugere fra Danmark ('Denmark').

- Tabeller involveret:  dbo.Users
- Ønsket output:        Id, DisplayName, CreationDate, Reputation, Rank_Reputation (beregnet)

*/

/* [Opgaven skal henlede opmærksomheden på konsekvensen af at udelade en window-partition] */

SELECT
    Id,
    DisplayName,
    CreationDate,
    Reputation,
    RANK() OVER(ORDER BY Reputation DESC) AS Rank_Reputation
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

CREATE TABLE TabelA (
    Id int NOT NULL,
    Kolonne date NOT NULL
);

INSERT INTO TabelA (Id, Kolonne)
VALUES
(1, '20220502'), (2, '20220314'), (3, '20230101'), (4, '20220314'), (5, '20220630');

SELECT
    *
FROM TabelA;

/* [Med udgangspunkt i det samme eksempel flyttes window-funktionen til forskellige delsætninger for at
    undersøge hvor den virker] */

SELECT
    Id,
    Kolonne,
    ROW_NUMBER() OVER (ORDER BY Kolonne, Id) AS Nr
FROM TabelA
--WHERE ROW_NUMBER() OVER (ORDER BY Kolonne, Id) = 1
--ORDER BY ROW_NUMBER() OVER (ORDER BY Kolonne, Id)
;

/* [Vis eksempel på hvordan tolkningen af window-funktioner ikke er entydig hvis den blev evalueret logisk
    i en anden fase] */

/* Et tænkt eksempel: Hvad vil forespørgslen nedenfor returnere? 3 eller 3 og 5? */

SELECT
    Id
FROM TabelA
WHERE Kolonne > '20220501'
    AND ROW_NUMBER() OVER (ORDER BY Kolonne, Id) > 2
--WHERE ROW_NUMBER() OVER (ORDER BY Kolonne, Id) > 2
--    AND Kolonne > '20220501'
;

/* [Vis eksempel på window-funktioner og samspillet med DISTINCT] */

/* Kan du gætte resultatet af nedenstående query? */

SELECT DISTINCT
    Kolonne,
    ROW_NUMBER() OVER(ORDER BY Kolonne) AS Nr
FROM TabelA
ORDER BY Kolonne;

/* [Vis eksempel på hvordan window-funktioner alligevel kan tages i brug i andre delsætninger, fx via
    en CTE] */

/* Hvordan kan vi komme uden om begrænsingen forårsaget af den logiske query processering? */

WITH CTE AS (
    SELECT
        Id,
        Kolonne,
        ROW_NUMBER() OVER(ORDER BY Kolonne, Id) AS Nr
    FROM TabelA
)

SELECT
    *
FROM CTE
WHERE Nr > 2;

DROP TABLE TabelA;

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

CREATE TABLE TabelA (
    Id int NOT NULL,
    Dato date NOT NULL,
    Kategori nvarchar(100) NOT NULL,
    Værdi int NULL
);

INSERT INTO TabelA (Id, Dato, Kategori, Værdi)
VALUES
(1, '20220101', 'A', 22), (2, '20000504', 'A', 5), (3, '20150205', 'A', 0),
(4, '20101203', 'B', 14), (5, '20050824', 'B', 79), (6, '20220930', 'B', 100), (7, '20220315', 'B', 43), (8, '20210710', 'B', 43),
(9, '20000504', 'C', 1), (10, '20221231', 'C', 112);

SELECT
    *
FROM TabelA;

/* Ranking: */

SELECT
    Id,
    Dato,
    Kategori,
    Værdi,
    ROW_NUMBER() OVER(
        PARTITION BY Kategori
        ORDER BY Værdi
    ) AS RækkeNr,
    RANK() OVER(
        PARTITION BY Kategori
        ORDER BY Værdi
    ) AS Rank,
    DENSE_RANK() OVER(
        PARTITION BY Kategori
        ORDER BY Værdi
    ) AS DenseRank,
    NTILE(2) OVER(
        PARTITION BY Kategori
        ORDER BY Værdi
    ) AS NTile
FROM TabelA
ORDER BY Kategori, Værdi;

/* Offset: */

SELECT
    Id,
    Dato,
    Kategori,
    Værdi,
    LAG(Værdi/*, 1, NULL*/) OVER(
        PARTITION BY Kategori
        ORDER BY Værdi
    ) AS TidligereVærdi,
    LEAD(Værdi/*, 1, NULL*/) OVER(
        PARTITION BY Kategori
        ORDER BY Værdi
    ) AS NæsteVærdi,
    FIRST_VALUE(Værdi) OVER(
        PARTITION BY Kategori
        ORDER BY Værdi
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS FørsteVærdi,
    LAST_VALUE(Værdi) OVER(
        PARTITION BY Kategori
        ORDER BY Værdi
        ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
    ) AS SidsteVærdi
FROM TabelA
ORDER BY Kategori, Værdi;

/* Aggregering: */

SELECT
    Id,
    Dato,
    Kategori,
    Værdi,
    COUNT(*) OVER(
        PARTITION BY Kategori
        /*ORDER BY Værdi
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW*/
    ) AS Antal,
    MIN(Værdi) OVER(
        PARTITION BY Kategori
        ORDER BY Værdi
    ) AS MindsteVærdi,
    MAX(Værdi) OVER(
        PARTITION BY Kategori
        /*ORDER BY Værdi
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW*/
    ) AS MaxVærdi,
    SUM(Værdi) OVER(
        PARTITION BY Kategori
        /*ORDER BY Værdi
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW*/
    ) AS SumVærdi
FROM TabelA
ORDER BY Kategori, Værdi;

DROP TABLE TabelA;

/* [Stack Overflow] */

/* Ranking: */

SELECT
    Id,
    DisplayName,
    [Location],
    Reputation,
    ROW_NUMBER() OVER(
        ORDER BY Reputation
    ) AS RækkeNr,
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
    ROW_NUMBER() OVER(
        ORDER BY Reputation
    ) AS RækkeNr,
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

SELECT
    Id,
    DisplayName,
    [Location],
    Reputation,
    LAG(Reputation/*, 1, NULL*/) OVER(
        ORDER BY Reputation
    ) AS TidligereVærdi,
    LEAD(Reputation/*, 1, NULL*/) OVER(
        ORDER BY Reputation
    ) AS NæsteVærdi,
    FIRST_VALUE(Reputation) OVER(
        ORDER BY Reputation
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS FørsteVærdi,
    LAST_VALUE(Reputation) OVER(
        ORDER BY Reputation
        ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
    ) AS SidsteVærdi
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
    ) AS Antal,
    MIN(Reputation) OVER(
        ORDER BY Reputation
    ) AS MindsteVærdi,
    MAX(Reputation) OVER(
        /*ORDER BY Reputation
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW*/
    ) AS MaxVærdi,
    SUM(Reputation) OVER(
        /*ORDER BY Reputation
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW*/
    ) AS SumVærdi
FROM dbo.Users
WHERE [Location] = 'Denmark'
ORDER BY Reputation;

/*

Opgave 4: Find 

- Tabeller involveret:  
- Ønsket output:        

*/

/*

Opgave 5: 

- Tabeller involveret:  
- Ønsket output:        

*/

/*

Opgave 6: 

- Tabeller involveret:  
- Ønsket output:        

*/

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
