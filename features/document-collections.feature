Feature: Grouping documents into collection
  As an organisation,
  I want to present regularly published documents as collection
  So that my users can more easily find earlier publications of the same type

  Background:
    Given I am a writer in the organisation "Government Department"

  @javascript
  Scenario: Admin creates a document collection and previews it.
    Given a published document "Wombats of Wimbledon" exists
    When I draft a new document collection called "Wildlife of Wimbledon Common"
    And I add the document "Wombats of Wimbledon" to the document collection
    Then I can preview the document collection
    And I see that the document "Wombats of Wimbledon" is part of the document collection

  @javascript
  Scenario: Removing documents from a collection
    Given a published publication called "May 2012 Update" in the document collection "Monthly Updates"
    And I'm editing the document collection "Monthly Updates"
    When I remove the document "May 2012 Update" from the document collection
    And I preview the document collection
    Then I see that the document "May 2012 Update" is not part of the document collection

  Scenario: Documents should link back to their collection
    Given a published publication called "May 2012 Update" in the document collection "Monthly Updates"
    When I visit the publication "May 2012 Update"
    Then I should see links back to the collection
