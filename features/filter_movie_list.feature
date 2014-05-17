Feature: display list of movies filtered by MPAA rating
 
  As a concerned parent
  So that I can quickly browse movies appropriate for my family
  I want to see movies matching only certain MPAA ratings

Background: movies have been added to database

  Given the following movies exist:
  | title                   | rating | release_date |
  | Aladdin                 | G      | 25-Nov-1992  |
  | The Terminator          | R      | 26-Oct-1984  |
  | When Harry Met Sally    | R      | 21-Jul-1989  |
  | The Help                | PG-13  | 10-Aug-2011  |
  | Chocolat                | PG-13  | 5-Jan-2001   |
  | Amelie                  | R      | 25-Apr-2001  |
  | 2001: A Space Odyssey   | G      | 6-Apr-1968   |
  | The Incredibles         | PG     | 5-Nov-2004   |
  | Raiders of the Lost Ark | PG     | 12-Jun-1981  |
  | Chicken Run             | G      | 21-Jun-2000  |

  And I am on the RottenVegetables home page

Scenario: restrict to movies with 'PG' or 'R' ratings
  When I uncheck the following ratings: G, PG-13
  When I check the following ratings: PG, R
  When I press "Refresh"
  Then I should see "PG" and "R" rated movies
  Then I should not see "G" and "PG-13" rated movies
  Then I should not see "X" and "NC-17" rated movies

Scenario: all ratings selected
  When I check the following ratings: G, R, PG, PG-13
  When I press "Refresh"
  Then I should see exactly 10 movies
  
Scenario: restrict to movies with 'G' ratings
  When I uncheck the following ratings: R, PG, PG-13
  When I check the following ratings: G
  When I press "Refresh"
  Then I should see "G" and "G" rated movies
  Then I should not see "R" and "PG" rated movies
  Then I should not see "PG-13" and "NC-17" rated movies

Scenario: G ratings selected
  When I uncheck the following ratings: R, PG, PG-13
  When I check the following ratings: G
  When I press "Refresh"
  Then I should see exactly 3 movies
