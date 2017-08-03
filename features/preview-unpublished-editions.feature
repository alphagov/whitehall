Feature: Previewing unpublished editions

Scenario: Unpublished editions link to preview
  Given I am an editor
  When I draft a new publication "Test publication"
  Then I should see a link to the preview version of the publication "Test publication"
