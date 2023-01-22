/* ***********************

PIVOT og UNPIVOT

Udviklet af Thomas Lange & Mick Ahlmann Brun

Mere info: https://github.com/M1ckB/T-SQL
 
Version 1.0 2023-01-17

Laboratoriet kræver:

- En understøttet version af SQL Server
- En Stack Overflow database: https://www.BrentOzar.com/go/querystack

Læs mere om set-operatorerne i Microsofts T-SQL reference:

- https://learn.microsoft.com/en-us/sql/t-sql/queries/from-using-pivot-and-unpivot?view=sql-server-ver16

Du kan finde løsninger og svar på opgaverne nederst i scriptet.

*********************** */

USE StackOverflow2013;
GO

/* ***********************

ØVELSER

*********************** */

/* Dette script danner en temporær tabel, #postbyusertype, som indeholder fire kolonner for poster, som er lukkede:
  PostClosedYear = Året hvor posten i dbo.Posts lukkedes
  UserType = 'Superuser' hvis Reputation i dbo.Users >= 10.000; 'User' ellers
  ViewCount = Antal visninger af posten i dbo.Posts */

SELECT YEAR(p.ClosedDate) AS PostClosedYear, CASE WHEN u.Reputation>=10000 THEN 'Superuser' ELSE 'User' END AS UserType, p.ViewCount
INTO #viewsbyusertypes
FROM dbo.Posts p 
INNER JOIN dbo.Users u ON u.Id=p.OwnerUserId
WHERE ClosedDate IS NOT NULL;

/*

OPGAVE 1: Du skal optælle det gennemsnitlige antal visninger for Users og Superusers fordelt på antal
  år med brug af PIVOT-operatoren...

*/

/*

OPGAVE 1.A: Hvad er 
  Grupperingselementet?
  Spredningselementet? 
  Aggregeringselementet? 
  Aggregeringsfunktionen?

*/

/*

OPGAVE 1.B: Skriv en forespørgsel med brug af PIVOT-operatoren, som danner det ønskede output.

- Tabeller involveret: #postsbyusertype (eller, om vil dbo.Posts og dbo.Users)
- Ønsket output:
PostClosedYear	User	Superuser
2008	          7895	5460
2009	          9876	13478
2010	          4934	11035
2011	          5348	9442
2012	          4754	11972
2013	          4309	10487
2014	          6283	21185
2015	          14236	19902
2016	          22574	32564
2017	          16269	24736
2018	          18527	27985
(11 rows)
*/

/*

OPGAVE 1.C: Kig på resultatet. Hvad kan man konkludere om sammenhængen mellem omdømme
  og visninger?

*/

/* ***********************

LØSNINGER

*********************** */

/* Bemærk hvorledes forskellige metoder kan bruges til at opnå det samme resultat, men at
  nogle metoder er mere effektive og kompakte */

/* OPGAVE 1.A */

/* OPGAVE 1.B */

SELECT PostClosedYear, [User], [Superuser]
FROM #viewsbyusertypes
PIVOT(AVG(ViewCount) FOR UserType IN ([User],[Superuser])) p;

/* OPGAVE 1.C */

DROP TABLE #viewsbyusertypes;

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