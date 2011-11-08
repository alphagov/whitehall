Feature: Viewing countries

Scenario: View list of all countries
  Given a country "British Antarctic Territory"
  And a country "Papua New Guinea"
  When I view the list of countries
  Then I should see the country "British Antarctic Territory"
  And I should see the country "Papua New Guinea"

Scenario: View news articles relating to a country
  Given a country "British Antarctic Territory"
  And a published news article "Larsen ice sheet disintegrates" exists relating to the country "British Antarctic Territory"
  When I view the country "British Antarctic Territory"
  Then I should see the news article "Larsen ice sheet disintegrates"

