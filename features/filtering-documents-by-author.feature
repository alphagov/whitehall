Feature: Filtering documents by author

Scenario: Viewing only documents written by me
  Given I am a writer
  And I draft a new publication "My Publication"
  And a draft publication "Another Publication" exists
  And I visit the list of draft documents

  When I select the "written by me" filter
  Then I should see the publication "My Publication"
  And I should not see the publication "Another Publication"

Scenario: Viewing only publications written by me
  Given I am a writer
  And I draft a new publication "My Publication"
  And I draft a new policy "My Policy"
  And I visit the list of draft documents

  When I select the "written by me" filter
  And I select the "publications" filter
  Then I should see the publication "My Publication"
  And I should not see the policy "My Policy"