Feature: Viewing people pages

Scenario: Viewing the person page for a minister
  Given "Benjamin Disraeli" is a minister with a history
  When I visit the person page for "Benjamin Disraeli"
  Then I should see information about the person "Benjamin Disraeli"
