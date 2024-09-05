Feature: Schedule a content object
  Background:
    Given the content object store feature flag is enabled
    And I am a GDS admin
    And the organisation "Ministry of Example" exists
    And a schema "email_address" exists with the following fields:
      | field         | type   | format | required |
      | email_address | string | email  | true     |
    And an email address content block has been created

  Scenario: GDS Editor schedules a content object
    When I am updating a content block
    Then I am asked when I want to publish the change
    And I schedule the change for 7 days in the future
    Then the edition should have been scheduled successfully
    And I should be taken back to the document page
    And I should see the scheduled date on the object
    And I should see the scheduled event on the timeline

  Scenario: A scheduled content object is published
    When I am updating a content block
    Then I am asked when I want to publish the change
    When I choose to schedule the change
    And the block is scheduled and published
    Then published state of the object is shown
    And I should see the publish event on the timeline

  Scenario: GDS Editor does not provide date for scheduling
    When I am updating a content block
    Then I am asked when I want to publish the change
    When I choose to schedule the change
    And I accept and publish
    Then I see the errors prompting me to provide a date and time

  Scenario: GDS Editor does not provide a valid date for scheduling
    When I am updating a content block
    Then I am asked when I want to publish the change
    When I choose to schedule the change
    And I enter an invalid date
    And I accept and publish
    Then I see the errors informing me the date is invalid

  Scenario: GDS Editor provides a date in the past for scheduling
    When I am updating a content block
    Then I am asked when I want to publish the change
    When I choose to schedule the change
    And I enter a date in the past
    And I accept and publish
    Then I see the errors informing me the date must be in the future
