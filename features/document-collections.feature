Feature: Grouping documents into a collection
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
    Then I can see in the preview that "Wombats of Wimbledon" is part of the document collection

  @javascript
  Scenario: Removing documents from a collection
    Given a published publication called "May 2012 Update" in a published document collection
    When I redraft the document collection and remove "May 2012 Update" from it
    Then I can see in the preview that "May 2012 Update" does not appear

  Scenario: Documents should link back to their collection
    Given a published publication called "May 2012 Update" in the document collection "Monthly Updates"
    When I visit the publication "May 2012 Update"
    Then I should see links back to the collection

  Scenario: Legacy document series urls are redirected to the new document collection urls
    Given a published document collection "Rail statistics" exists
    When I visit the old document series url "/government/organisations/government-department/series/rail-statistics"
    Then I should be redirected to the "Rail statistics" document collection

  @javascript
  Scenario: Reordering documents in a document collection
    Given a published document "Wombats of Wimbledon" exists
    And a published document "Feeding Wombats" exists
    And a published document "The nocturnal habits of Wombats" exists
    When I draft a new document collection called "Wildlife of Wimbledon Common"
    And I add the document "Wombats of Wimbledon" to the document collection
    And I add the document "Feeding Wombats" to the document collection
    And I add the document "The nocturnal habits of Wombats" to the document collection
    And I move "Feeding Wombats" before "Wombats of Wimbledon" in the document collection
    Then I can preview the document collection
    And I see that "Feeding Wombats" is before "Wombats of Wimbledon" in the document collection
    And I see that "Wombats of Wimbledon" is before "The nocturnal habits of Wombats" in the document collection
