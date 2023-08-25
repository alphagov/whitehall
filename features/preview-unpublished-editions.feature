Feature: Previewing unpublished editions

  Scenario: Unpublished editions link to preview
    Given I am an editor
    When I draft a new publication "Test publication"
    Then I should see a link to the preview version of the publication "Test publication"

  Scenario: Unpublished editions link to preview from the edit page
    Given I am an editor
    When I draft a new publication "Test publication"
    When I am on the edit page for publication "Test publication"
    Then I should see a link to the preview version of the publication "Test publication"
