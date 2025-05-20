Feature: Schedule a content object
  Background:
    Given I am a GDS admin
    And the organisation "Ministry of Example" exists
    And a schema "pension" exists with the following fields:
      | field         | type   | format | required |
      | description   | string | string | true     |
    And a pension content block has been created

  @disable-sidekiq-test-mode
  Scenario: GDS Editor immediately publishes a scheduled content object
    Given I have scheduled a change for 7 days in the future
    When I click to view the content block
    And I click to edit the schedule
    And I choose to publish the change now
    When I review and confirm my answers are correct
    When I click to view the content block
    Then the published state of the object should be shown
    And there should be no jobs scheduled

  @disable-sidekiq-test-mode
  Scenario: GDS Editor reschedules a content object
    Given I have scheduled a change for 7 days in the future
    When I click to view the content block
    And I click to edit the schedule
    And I schedule the change for 5 days in the future
    When I review and confirm my answers are correct
    When I click to view the content block
    Then I should see the scheduled date on the object
    And there should only be one job scheduled

  @disable-sidekiq-test-mode
  Scenario: GDS Editor tries to reschedule a content object without choosing to schedule
    Given I have scheduled a change for 7 days in the future
    When I click to view the content block
    And I click to edit the schedule
    And I save and continue
    Then I should see an error message telling me that schedule publishing cannot be blank

  @disable-sidekiq-test-mode
  Scenario: GDS editor cancels the rescheduling of an object
    Given I have scheduled a change for 7 days in the future
    When I click to view the content block
    And I click to edit the schedule
    And I click the cancel link
    Then I should be taken back to the document page
    And no draft Content Block Edition has been created

  @disable-sidekiq-test-mode
  Scenario: GDS editor cancels the rescheduling of an object on the confirmation page
    Given I have scheduled a change for 7 days in the future
    When I click to view the content block
    And I click to edit the schedule
    And I schedule the change for 5 days in the future
    And I click the cancel link
    And I choose to delete the in-progress draft
    Then I should be taken back to the document page
    And no draft Content Block Edition has been created
