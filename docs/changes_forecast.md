# Issues Planning
To get a rough idea regarding the areas of the codebase I used namespace names and some more generic categories such as:
* `support` for broader updates to support certain updates and improvements.
* `core` for anything that I suspect are change to the general engine or common parts. 

* To answer the questions what is on the short term agenda there is milestone project 7.0.
* Longer term is based on issues with the labels `bug` and `up-for-grabs` and `feature`.

## Category counts
Given the above filters on issues and the suspected categorization the following issue counts are identified per category.

| Category    | Short| Long | Total Result |
|-------------|------|------|--------------|
| Collections | 1    | 5    | 6            |
| Core        | 4    | 2    | 6            |
| Equivalency | 3    | 9    | 12           |
| Events      |      | 3    | 3            |
| Formatting  |      | 3    | 3            |
| Primitives  | 3    | 1    | 4            |
| Support     | 2    | 6    | 7            |
| Specialized |      | 1    | 1            |

## Short term impact
For the 7.0 short term changes most impact is expected to be in the categories:
* `Core` (4)
* `Equivalancy` (3)
* `Primitives` (3)

## Longer term change impact
Looking at the longer term issues there are two more dominant categories:
* `Collections` (5)
* `Equivalency` (9)

This is probably not completely strange since other assertions are lower level and simpler. Given that FlentAssertions is already under development for more than 10 years.