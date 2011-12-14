Feature: Search

Scenario: Search for policy title
  Given a published policy "Ban beards" exists
  And a published policy "Promote moustaches" exists

  When I search for "beards"

  Then I see the policy "Ban beards" in the search results
  And I do not see the policy "Promote moustaches" in the search results