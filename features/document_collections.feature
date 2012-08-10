Feature: Grouping documents into series and collections
  As an organisation,
  I want to present regularly published documents as collections
  So that my users can more easily find earlier publications of the same type

  Background:
    Given I am a writer in the organisation "Department of Beards"
    And the organisation "Department of Beards" exists
    And I create a collection called "Monthly Facial Topiary Update" in the "Department of Beards" organisation

  Scenario: Documents should link back to their collections
    When I create a document called "May 2012 Update" in the "Monthly Facial Topiary Update" collection
    And someone publishes the document "May 2012 Update"
    When I view the document "May 2012 Update"
    Then I should see links back to the "Monthly Facial Topiary Update" collection

  Scenario: Collections list all their documents
    Given I create a document called "May 2012 Update" in the "Monthly Facial Topiary Update" collection
    And I create a document called "June 2012 Update" in the "Monthly Facial Topiary Update" collection
    And someone publishes the document "May 2012 Update"
    And someone publishes the document "June 2012 Update"
    When I view the "Monthly Facial Topiary Update" collection
    Then I should see links to all the documents in the "Monthly Facial Topiary Update" collection

  Scenario: Editors should not be overwhelmed by collections from other organisations
    Given collections from several other organisations exist
    When I begin drafting a new publication "Title doesn't matter"
    Then I should see the collections from "Department of Beards" first in the collection list
