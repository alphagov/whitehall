Feature: View a content object

  Scenario: GDS Editor views a content object
    Given the content object store feature flag is enabled
    Given I am a GDS admin
    And a schema "email_address" exists with the following fields:
      | email_address |
    And an email address content block has been created
    When I visit the object store
    Then I should see the details for all content blocks
    When I click to view the content block
    Then I should see the details for the email address content block