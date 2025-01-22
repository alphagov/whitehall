Feature: Schedule a content object
  Background:
    Given I am a GDS admin
    And the organisation "Ministry of Example" exists
    And a schema "email_address" exists with the following fields:
      | field         | type   | format | required |
      | email_address | string | email  | true     |
    And an email address content block has been created

  @disable-sidekiq-test-mode
  Scenario: GDS Editor immediately publishes a scheduled content object
    When I am updating a content block
    And I schedule the change for 7 days in the future
    And I add an internal note
    When I review and confirm my answers are correct
    When I click to view the content block
    And I click to edit the schedule
    And I choose to publish the change now
    When I review and confirm my answers are correct
    When I click to view the content block
    Then the published state of the object should be shown
    And there should be no jobs scheduled

  @disable-sidekiq-test-mode
  Scenario: GDS Editor reschedules a content object
    When I am updating a content block
    And I schedule the change for 7 days in the future
    And I add an internal note
    When I review and confirm my answers are correct
    When I click to view the content block
    And I click to edit the schedule
    And I schedule the change for 5 days in the future
    When I review and confirm my answers are correct
    When I click to view the content block
    Then I should see the scheduled date on the object
    And there should only be one job scheduled

  @disable-sidekiq-test-mode
  Scenario: GDS Editor tries to reschedule a content object without choosing to schedule
    When I am updating a content block
    And I schedule the change for 7 days in the future
    And I add an internal note
    When I review and confirm my answers are correct
    When I click to view the content block
    And I click to edit the schedule
    And I save and continue
    Then I should see an error message telling me that schedule publishing cannot be blank

  @disable-sidekiq-test-mode
  Scenario: GDS editor cancels the rescheduling of an object
    When I am updating a content block
    And I schedule the change for 7 days in the future
    And I add an internal note
    When I review and confirm my answers are correct
    When I click to view the content block
    And I click to edit the schedule
    And I click the cancel link
    Then I should be taken back to the document page
    And no draft Content Block Edition has been created

  @disable-sidekiq-test-mode
  Scenario: GDS editor cancels the rescheduling of an object on the confirmation page
    When I am updating a content block
    And I schedule the change for 7 days in the future
    And I add an internal note
    When I review and confirm my answers are correct
    When I click to view the content block
    And I click to edit the schedule
    And I schedule the change for 5 days in the future
    And I click cancel
    Then I am taken back to Content Block Manager home page
    And no draft Content Block Edition has been created
