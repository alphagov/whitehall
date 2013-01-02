Feature: Viewing world locations

Scenario: View news articles relating to an overseas territory
  Given an overseas territory "British Antarctic Territory" exists
  And a published news article "Larsen ice sheet disintegrates" exists relating to the overseas territory "British Antarctic Territory"
  When I view the overseas territory "British Antarctic Territory"
  Then I should see the news article "Larsen ice sheet disintegrates"

Scenario: View policies relating to an overseas territory
  Given an overseas territory "British Antarctic Territory" exists
  And a published policy "Icebergs of the World, Unite!" exists relating to the overseas territory "British Antarctic Territory"
  When I view the overseas territory "British Antarctic Territory"
  Then I should see the policy "Icebergs of the World, Unite!"

Scenario: The publication is about an overseas territory
  Given an overseas territory "British Antarctic Territory" exists
  And a published publication "Penguins have rights too" exists that is about "British Antarctic Territory"
  When I view the overseas territory "British Antarctic Territory"
  Then I should see the publication "Penguins have rights too"

Scenario: View priorities for an international delegation
  Given an international delegation "United Nations" exists
  And a published international priority "Oil field exploitation" exists relating to the international delegation "United Nations"
  When I view the international delegation "United Nations"
  Then I should see the international priority "Oil field exploitation"

Scenario: Navigating between pages for an international delegation
  Given an international delegation "United Nations" exists
  When I view the international delegation "United Nations"
  Then I should see the world location navigation
  When I navigate to the "United Nations" international delegation's about page
  Then I should see the "United Nations" international delegation's about page
  And I should see the world location navigation
  When I navigate to the "United Nations" international delegation's home page
  Then I should see the "United Nations" international delegation's home page

Scenario: Inactive world locations are listed but not linked
  Given the country "Democratic People's Republic of South London" is inactive
  When I visit the world locations page
  Then I should see a country called "Democratic People's Republic of South London"
  But I should not see a link to the country called "Democratic People's Republic of South London"

Scenario: Hard-coded featured countries are featured
  Given a country "Spain" exists
  When I visit the world locations page
  Then the country called "Spain" should be featured

Scenario: World locations tell me what type they are
  Given a country "Spain" exists
  And an overseas territory "British Antarctic Territory" exists
  And an international delegation "United Nations" exists

  When I view the country "Spain"
  Then I should see that it is a country

  When I view the overseas territory "British Antarctic Territory"
  Then I should see that it is an overseas territory

  When I view the overseas territory "United Nations"
  Then I should see that it is an international delegation
