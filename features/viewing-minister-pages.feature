Feature: Viewing minister pages
As a citizen
I want to be able to view a page gathering information about a minister
So that I can see what government activities they are involved with

Scenario: The minister has some published policies and publications
  And a published publication "Down with Gravity" that's the responsibility of:
    | Ministerial Role  | Person          |
    | Minister of Crazy | Johnny Macaroon |
  And a published publication "Hollowing out the Earth's core" that's the responsibility of:
    | Ministerial Role  | Person          |
    | Minister of Crazy | Johnny Macaroon |
  When I visit the minister page for "Minister of Crazy"
  Then I should see that the minister is responsible for the documents:
    | Down with Gravity |
    | Hollowing out the Earth's core |

Scenario: The minister belongs to departments
  Given "Johnny Macaroon" is the "Minister of Crazy" for the "Department of Woah"
  When I visit the minister page for "Minister of Crazy"
  Then I should see that the minister is associated with the "Department of Woah"

Scenario: The minister has responsibilities through their role
  Given "Marty McFly" is the "Minister of Anachronisms" for the "Department of Temporal Affairs"
  And the role "Minister of Anachronisms" has the responsibilities "Chronometric stability"
  When I visit the minister page for "Minister of Anachronisms"
  Then I should see that the minister has responsibilities "Chronometric stability"
