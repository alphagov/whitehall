Feature: Grouping documents into series
  As an organisation,
  I want to present regularly published documents as series
  So that my users can more easily find earlier publications of the same type

  Background:
    Given I am a writer in the organisation "Department of Beards"
    And the organisation "Department of Beards" exists
    And I create a series called "Monthly Facial Topiary Update" in the "Department of Beards" organisation

  Scenario: Documents should link back to their series
    When I create a document called "May 2012 Update" in the "Monthly Facial Topiary Update" series
    And someone publishes the document "May 2012 Update"
    When I visit the publication "May 2012 Update"
    Then I should see links back to the "Monthly Facial Topiary Update" series

  Scenario: series list all their documents
    Given I create a document called "May 2012 Update" in the "Monthly Facial Topiary Update" series
    And I create a document called "June 2012 Update" in the "Monthly Facial Topiary Update" series
    And someone publishes the document "May 2012 Update"
    And someone publishes the document "June 2012 Update"
    When I view the "Monthly Facial Topiary Update" series
    Then I should see links to all the documents in the "Monthly Facial Topiary Update" series

  Scenario: Editors should not be overwhelmed by series from other organisations
    Given series from several other organisations exist
    When I begin drafting a new publication "Title doesn't matter"
    Then I should see the series from "Department of Beards" first in the series list
