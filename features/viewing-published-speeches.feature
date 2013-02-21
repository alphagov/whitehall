Feature: Viewing published speeches

Scenario: Viewing speeches made by a minister
  Given "David Cameron" is the "Prime Minister" for the "Cabinet Office"
  And a published speech "Abolish Fig Rolls" by "Prime Minister" on "June 23rd, 2010" at "The Mansion House"
  When I visit the minister page for "Prime Minister"
  Then I should see the speech "Abolish Fig Rolls"
  When I visit the speech "Abolish Fig Rolls"
  Then I should see the speech was delivered on "23 June 2010" at "The Mansion House"

Scenario: Viewing a published speech with related policies
  Given a published speech "Things I Have Thought" with related published policies "Policy 1" and "Policy 2"
  When I visit the speech "Things I Have Thought"
  Then I can see links to the related published policies "Policy 1" and "Policy 2"
