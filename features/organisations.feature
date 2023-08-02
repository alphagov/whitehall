Feature: Administering Organisations

  Background:
    Given I am an admin in the organisation "Ministry of Pop"
    And a directory of organisations exists
    And a world location "United Kingdom" exists

  Scenario: Adding an Organisation
    Given I have the "GDS Admin" permission
    When I add a new organisation called "Ministry of Jazz"
    Then I should be able to see "Ministry of Jazz" in the list of organisations

  Scenario: Adding a translation to an Organisation
    Given I have the "GDS Admin" permission
    When I add a new organisation called "Ministry of Jazz"
    And I add a translation for an organisation called "Ministry of Jazz"
    Then I should be able to see the translation for "Ministry of Jazz" in the list of translations

  Scenario: Administering organisation contact details
    When I visit the organisation admin page for "Ministry of Pop"
    And I add a new contact "Main office" with address "1 Acacia Avenue"
    Then I should see the "Main office" contact in the admin interface with address "1 Acacia Avenue"
    When I edit the contact to have address "1 Acacia Road"
    Then I should see the "Main office" contact in the admin interface with address "1 Acacia Road"

  Scenario: Creating offsite content on an organisation page
    When I add the offsite link "Offsite Thing" of type "Alert" to the organisation "Ministry of Pop"
    Then I should see the edit offsite link "Offsite Thing" on the "Ministry of Pop" organisation page

  @design-system-only
  Scenario: Featuring a topical event for an organisation
    When an active topical event called "Super topical" exists
    And I visit the the organisation feature page for "Ministry of Pop"
    And I feature "Super topical"
    Then I see that "Super topical" has been featured

  @javascript @bootstrap-only
  Scenario: Filtering items to feature on an organisation page
    Given an organisation and some documents exist
    When I go to the organisation feature page
    Then I can filter instantaneously the list of documents by title, author, organisation, and document type

  Scenario: Requesting publications in alternative format
    And I set the alternative format contact email of "Ministry of Pop" to "alternative.format@ministry-of-pop.gov.uk"
    And a published publication "Charleston styles today" with a PDF attachment and alternative format provider "Ministry of Pop"
    Then the alternative format contact email is "alternative.format@ministry-of-pop.gov.uk"

  Scenario: deleting an organisation with no children or roles
    Given I am an editor in the organisation "Department of Fun"
    When I delete the organisation "Department of Fun"
    Then there should not be an organisation called "Department of Fun"

  Scenario: Admin closes an organisation, superseding it with another one
    Given I am an editor in the organisation "Department of wombat population control"
    And the organisation "Wimbledon council of wombat population control" exists
    When I close the organisation "Department of wombat population control", superseding it with the organisation "Wimbledon council of wombat population control"
    Then I can see that the organisation "Department of wombat population control" has been superseded with the organisaion "Wimbledon council of wombat population control"

  Scenario: Reordering roles
    Given I am an editor in the organisation "Ministry of Sound"
    And the following roles exist within the "Ministry of Sound":
      | name   |
      | Role 1 |
      | Role 2 |
    When I visit the "Ministry of Sound" "People" page
    And I set the order of roles for "Ministry of Sound" to:
      | name   | order |
      | Role 1 | 1     |
      | Role 2 | 0     |
    Then the roles should be in the following order:
      | name   |
      | Role 2 |
      | Role 1 |
