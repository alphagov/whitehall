Feature: Grouping documents into series
  As an organisation,
  I want to present regularly published documents as series
  So that my users can more easily find earlier publications of the same type

  Background:
    Given I am a writer in the organisation "Government Department"

  @javascript
  Scenario: Adding documents to a series
    Given a published policy "The Policy" exists
    And a document series "Monthly Updates" exists
    Then I should be able to search for "Policy" and add the document to the series

  @javascript
  Scenario: Removing documents from a series
    Given a published publication called "May 2012 Update" in the series "Monthly Updates"
    Then I should be able to remove the publication from the series

  Scenario: Documents should link back to their series
    Given a published publication called "May 2012 Update" in the series "Monthly Updates"
    When I visit the publication "May 2012 Update"
    Then I should see links back to the series
