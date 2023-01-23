# T-SQL

The repository contains educational material used to host courses about Microsoft's Transact-SQL (T-SQL).

The content of the repository will be in both English and Danish.

## Map of Content

The educational material is grouped into the following categories:

- [Laboratories](Laboratories): Scripts used for demos and assignments (this is the main content)
- [Other materials](Other-materials): E.g. pictures
- [Sample databases](Sample-databases): Information about sample databases that are used

### Organization of Laboratories

A laboratory is named according to the topic it covers. It is split into two files, a demo and some exercises. The demo is created as a Jupyter Notebook (with the file extension `.ipynb`) while the exercises are created as a SQL script (with the file extension `.sql`).

The demo is where the exploration of a topic starts. It will explain and demonstrate concepts and there will be references to exercises along the way.

The exercises work as a learning aid to help explore and grasp the concepts introduced.

### Topics

Each laboratory concerns a specific topic. So far, the following topics are covered:

- Table Operators:
  - Joins ([Danish](Laboratories/Danish/Joins.ipynb))
  - PIVOT and UNPIVOT ([Danish](Laboratories/Danish/PIVOT-and-UNPIVOT.ipynb))
- Set operators ([Danish](Laboratories/Danish/Set-operators.ipynb))
- Querying Metadata
- Subqueries
- Table Expressions:
  - Derived Table
  - Common Table Expression (CTE)
  - View
- Window Functions ([Danish](Laboratories/Danish/Window-functions.ipynb))
- Programmable Objects:
  - Batches and Control-Flow Statements
  - Dynamic SQL
  - Temporary Table
  - Routines
  - Error Handling

## Credits

The content is maintained and developed by [Thomas Lange](https://github.com/thomas-lange-dk) and [Mick Ahlmann Brun](https://github.com/M1ckB).

## Licensing

The repository is licensed under Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0).

You are free to:

- Share - copy and redistribute the material in any medium or format
- Adapt - remix, transform, and build upon the material for any purpose, even commercially

Under the following terms:

- Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made.
- ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.

See `LICENSE` for details.
