Feature: Schedule a content object
  Background:
    Given I am a GDS admin
    And the organisation "Ministry of Example" exists
    And a schema "email_address" exists with the following fields:
      | field         | type   | format | required |
      | email_address | string | email  | true     |
    And an email address content block has been created

  @enable-sidekiq-test-mode
  Scenario: GDS Editor schedules a content object
    When I am updating a content block
    Then I am asked when I want to publish the change
    And I schedule the change for 7 days in the future
    And I should be taken to the scheduled confirmation page
    When I click to view the content block
    And I should see the scheduled date on the object
    And I should see the scheduled event on the timeline

  @disable-sidekiq-test-mode
  Scenario: GDS Editor immediately publishes a scheduled content object
    When I am updating a content block
    Then I am asked when I want to publish the change
    And I schedule the change for 7 days in the future
    When I click to view the content block
    And I click to edit the schedule
    And I choose to publish the change now
    And I accept and publish
    When I click to view the content block
    Then the published state of the object should be shown
    And there should be no jobs scheduled

  @disable-sidekiq-test-mode
  Scenario: GDS Editor reschedules a content object
    When I am updating a content block
    Then I am asked when I want to publish the change
    And I schedule the change for 7 days in the future
    When I click to view the content block
    And I click to edit the schedule
    And I schedule the change for 5 days in the future
    When I click to view the content block
    Then I should see the scheduled date on the object
    And there should only be one job scheduled

  Scenario: A scheduled content object is published
    When I am updating a content block
    Then I am asked when I want to publish the change
    When I choose to schedule the change
    And the block is scheduled and published
    Then the published state of the object should be shown
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
