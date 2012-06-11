Feature: removing organisations added in error
  As an editor,
  I want to be able to remove organisations which were added in error
  So I can make sure the list of organisations is accurate

Scenario: deleting an organisation with no children or roles
  Given I am an editor
  And the organisation "Department of Fun" exists
  When I delete the organisation "Department of Fun"
  Then there should not be an organisation called "Department of Fun"
