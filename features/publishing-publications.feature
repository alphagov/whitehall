Feature: Publishing publications
  In order to allow the public to view publications
  A writer and editor
  Should be able to draft and publish publications

Scenario: Creating a new draft publication
  Given I am a writer
  When I draft a new publication "Standard Beard Lengths"
  Then I should see the publication "Standard Beard Lengths" in the list of draft documents

Scenario: Submitting a draft publication to a second pair of eyes
  Given I am a writer
  And a draft publication called "Standard Beard Lengths" exists
  When I submit the publication "Standard Beard Lengths"
  Then I should see the publication "Standard Beard Lengths" in the list of submitted documents

Scenario: Publishing a submitted publication
  Given I am an editor
  And a submitted publication called "Standard Beard Lengths" exists
  When I publish the publication "Standard Beard Lengths"
  Then I should see the publication "Standard Beard Lengths" in the list of published documents
  And the publication "Standard Beard Lengths" should be visible to the public
