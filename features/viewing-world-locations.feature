Feature: Viewing world locations

Scenario: View news articles relating to an world location
  Given a world location "British Antarctic Territory" exists
  And a published news article "Larsen ice sheet disintegrates" exists relating to the world location "British Antarctic Territory"
  When I view the world location "British Antarctic Territory"
  Then I should see the news article "Larsen ice sheet disintegrates"

Scenario: View policies relating to a world location
  Given a world location "British Antarctic Territory" exists
  And a published policy "Icebergs of the World, Unite!" exists relating to the world location "British Antarctic Territory"
  When I view the world location "British Antarctic Territory"
  Then I should see the policy "Icebergs of the World, Unite!"

Scenario: The publication is about a world location
  Given a world location "British Antarctic Territory" exists
  And a published publication "Penguins have rights too" exists that is about "British Antarctic Territory"
  When I view the world location "British Antarctic Territory"
  Then I should see the publication "Penguins have rights too"

Scenario: View priorities for an international delegation
  Given an international delegation "United Nations" exists
  And a published worldwide priority "Oil field exploitation" exists relating to the international delegation "United Nations"
  When I view the international delegation "United Nations"
  Then I should see the worldwide priority "Oil field exploitation"

Scenario: Inactive world locations are listed but not linked
  Given the world location "Democratic People's Republic of South London" is inactive
  When I visit the world locations page
  Then I should see a world location called "Democratic People's Republic of South London"
  But I should not see a link to the world location called "Democratic People's Republic of South London"

Scenario: World locations tell me what type they are
  Given a world location "Spain" exists
  And an international delegation "United Nations" exists

  When I view the world location "Spain"
  Then I should see that it is a world location

  When I view the world location "United Nations"
  Then I should see that it is an international delegation
