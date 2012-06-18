Feature: viewing inbound links to a policy as an editor
  As a writer, I want to see a list of PUBLISHED documents that are associated
  with the policy document I am currently viewing, so I can see the full set of
  related items that will appear on the published page.

Scenario: Seeing related published documents when viewing a policy
  Given a published policy "Reform tax on hairpieces"
  And a published publication "Impact assessment: merkin wearers" associated with the policy
  And a draft publication "Changing the way we tax wigs" associated with the policy
  And I am an editor
  When I view the policy titled "Reform tax on hairpieces"
  Then I should see a link to "Impact assessment: merkin wearers" in the list of related documents
  But I should not see a link to "Changing the way we tax wigs" in the list of related documents
