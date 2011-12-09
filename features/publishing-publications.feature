Feature: Publishing publications
  In order to allow the public to view publications
  A writer and editor
  Should be able to draft and publish publications

Scenario: Publishing a submitted publication
  Given I am an editor
  Given a submitted publication "Standard Beard Lengths" exists
  When I publish the publication "Standard Beard Lengths"
  Then I should see the publication "Standard Beard Lengths" in the list of published documents
  And the publication "Standard Beard Lengths" should be visible to the public

Scenario: Publishing a corporate publication
  Given I am an editor
  And the organisation "Ministry of Hair" exists
  And a submitted corporate publication "Why we care about hair" about the "Ministry of Hair"
  When I publish the publication "Why we care about hair"
  Then I should see "Why we care about hair" is a corporate publication of the "Ministry of Hair"

