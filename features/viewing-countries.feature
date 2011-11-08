Feature: Viewing countries

Scenario: View list of all countries
  Given a country "British Antarctic Territory"
  And a country "Papua New Guinea"
  When I view the list of countries
  Then I should see the country "British Antarctic Territory"
  And I should see the country "Papua New Guinea"
