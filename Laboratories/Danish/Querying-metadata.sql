/* ***********************

SQL Servers metadata

Udviklet af Thomas Lange & Mick Ahlmann Brun

Mere info: https://github.com/M1ckB/T-SQL

Version 1.0 2023-01-29

Laboratoriet kræver:

- En understøttet version af SQL Server
- En Stack Overflow database: https://www.BrentOzar.com/go/querystack (medium)

Læs mere om system-databaser i SQL Server hos Microsoft:

- https://learn.microsoft.com/en-us/sql/relational-databases/databases/system-databases

Læs mere om metadata i INFORMATION_SCHEMA-views (ANSI/ISO standard kataloger for metadata) i Microsofts T-SQL reference:

- https://learn.microsoft.com/en-us/sql/relational-databases/system-information-schema-views/system-information-schema-views-transact-sql

Læs også om den udvidede metadata i SYS-views (Object Catalog Views) i Microsofts T-SQL reference:

- https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/object-catalog-views-transact-sql

Du kan finde løsninger og svar på opgaverne nederst i scriptet.

*********************** */

USE StackOverflow2013;
GO

/* ***********************

ØVELSER

*********************** */

/* 

OPGAVE 1: Lav en forespørsel som viser samtlige kolonner i StackOverflow-databasen ved brug af
  INFORMATION_SCHEMA-views.

- Tabeller involveret: INFORMATION_SCHEMA.COLUMNS 
- Ønsket output:
TABLE_SCHEMA	TABLE_NAME	COLUMN_NAME
dbo	            Badges	    Date
dbo	            Badges	    Id
dbo	            Badges	    Name
...
(61 row)

*/

/*

OPGAVE 2: Kan du lave samme resultat ved at forespørge views i sys-skemaet?
TIP: Tabellens Id i sys.tables hedder object_id.

- Tabeller involveret: sys.schemas, sys.tables, sys.columns
- Ønsket output:
TABLE_SCHEMA	TABLE_NAME	COLUMN_NAME
dbo	            Badges	    Date
dbo	            Badges	    Id
dbo	            Badges	    Name
...
(61 row)

*/

/* ***********************

LØSNINGER

*********************** */

/* OPGAVE 1 */

SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY TABLE_SCHEMA, TABLE_NAME,COLUMN_NAME;

/* OPGAVE 2 */

SELECT s.name AS TABLE_SCHEMA,
  t.name AS TABLE_NAME,
  c.name AS COLUMN_NAME
FROM sys.columns AS c 
INNER JOIN sys.tables t ON t.object_id=c.object_id
INNER JOIN sys.schemas s ON s.schema_id=t.schema_id
ORDER BY TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME;

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