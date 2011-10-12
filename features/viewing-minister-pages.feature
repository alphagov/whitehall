Feature: Viewing minister pages
As a citizen
I want to be able to view a page gathering information about a minister
So that I can see what government activities they are involved with

Scenario: Viewing all policies and publications that a minister is responsible for
  Given a published policy titled "Down with Gravity" that's the responsibility of:
    | Ministerial Role  | Person          |
    | Minister of Crazy | Johnny Macaroon |
  And a published publication titled "Hollowing out the Earth's core" that's the responsibility of:
      | Ministerial Role  | Person          |
      | Minister of Crazy | Johnny Macaroon |
  When I visit the minister page for "Johnny Macaroon"
  Then I should see that the minister is responsible for the documents:
    | Down with Gravity |
    | Hollowing out the Earth's core |