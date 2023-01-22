/* ***********************

SET-OPERATORER

Udviklet af Thomas Lange & Mick Ahlmann Brun

Mere info: https://github.com/M1ckB/T-SQL

Version 1.0 2023-01-10

Laboratoriet kræver:

- En understøttet version af SQL Server
- En Stack Overflow database: https://www.BrentOzar.com/go/querystack

Læs mere om set-operatorerne i Microsofts T-SQL reference:

- https://learn.microsoft.com/en-us/sql/t-sql/language-elements/set-operators-union-transact-sql?view=sql-server-ver16
- https://learn.microsoft.com/en-us/sql/t-sql/language-elements/set-operators-except-and-intersect-transact-sql?view=sql-server-ver16

Du kan finde løsninger og svar på opgaverne nederst i scriptet.

*********************** */

USE StackOverflow2013;
GO

/* ***********************

ØVELSER

*********************** */

/*

OPGAVE 1: Hvad er forskellen på UNION og UNION ALL?
  Hvornår er de ens?

*/

/*

OPGAVE 2 (optional): Nogle gange kan du bruge både FULL OUTER JOIN og UNION ALL til at løse
  en opgave. Hvornår vælger du UNION/UNION ALL?

*/

/*

OPGAVE 3: Skriv en forespørsel som giver dig tallene fra 1 til 10. 

- Tabeller involveret: Ingen
- Ønsket output:
n
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
(10 rows)

*/

/*

OPGAVE 4: Skriv en forespørgsel som finder distinkte brugere i StackOverflow, som har givet
  DownVotes, men ingen UpVotes.

- Tabeller involveret: dbo.Users
- Ønsket output: 
Id	  DisplayName
211	  jhornnes
15299	user15299
17020	Matt
17060	user17060
...
(495 rows)

*/

/*

OPGAVE 5: Skriv en forespørgsel som finder distinkte brugere i StackOverflow, som har givet mindst
  1000 DownVotes og mindst 10000 UpVotes.

- Tabeller involveret: dbo.Users
- Ønsket output: 
Id	  DisplayName
-1	  Community
476	  deceze
1288	Bill the Lizard
3043	Joel Coehoorn
...
(79 rows)

*/

/* ***********************

LØSNINGER

*********************** */

/* OPGAVE 1 */

/* Forskellen på UNION og UNION ALL er, at UNION returnerer distinkte rækker, mens UNION ALL
  returnerer rækker det samlede antal gange, de findes i SELECT-forespørgslernes
  resultat-tabeller */

/* OPGAVE 2 */

/* UNION og UNION ALL bruger og sammenligner alle kolonner defineret i SELECT-forespørgslerne,
  uden at der skal defineres en lang liste af betingelser for sammenligninger (som der skal i
  FULL OUTER JOINs). Ofte er det derfor simplere at lave UNION eller UNION ALL end et
  FULL OUTER JOIN */

/* OPGAVE 3 */

/* Med UNION ALL: */
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

/* Med VALUES: */
SELECT n
FROM (VALUES(1),(2),(3),(4),(5),(6),(7),(8),(9),(10)) AS Nums(n);

/* OPGAVE 4 */

SELECT Id,DisplayName
FROM dbo.Users
WHERE DownVotes>0

EXCEPT 

SELECT Id,DisplayName
FROM dbo.Users
WHERE UpVotes>0;

/* OPGAVE 5 */

SELECT Id,DisplayName
FROM dbo.Users
WHERE DownVotes>1000

INTERSECT 

SELECT Id,DisplayName
FROM dbo.Users
WHERE UpVotes>10000;

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
