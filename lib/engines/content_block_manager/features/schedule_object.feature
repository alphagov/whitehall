Feature: Schedule a content object
  Background:
    Given I am a GDS admin
    And the organisation "Ministry of Example" exists
    And a schema "pension" exists:
    """
    {
       "type":"object",
       "required":[
          "description"
       ],
       "additionalProperties":false,
       "properties":{
          "description": {
            "type": "string"
          }
       }
    }
    """
    And a pension content block has been created

  @enable-sidekiq-test-mode
  Scenario: GDS Editor schedules a content object
    When I am updating a content block
    And I schedule the change for 7 days in the future
    When I review and confirm my answers are correct
    And I should be taken to the scheduled confirmation page
    When I click to view the content block
    And I should see the scheduled date on the object
    And I should see the scheduled event on the timeline

  @disable-sidekiq-test-mode
  Scenario: GDS Editor publishes a new version of a previously scheduled content object
    Given I have scheduled a change for 7 days in the future
    When I am updating a content block
    And I choose to publish the change now
    When I review and confirm my answers are correct
    Then there should be no jobs scheduled

  Scenario: A scheduled content object is published
    When I am updating a content block
    When I choose to schedule the change
    And the block is scheduled and published
    When I review and confirm my answers are correct
    Then the published state of the object should be shown
    And I should see the publish event on the timeline

  Scenario: GDS Editor does not provide date for scheduling
    When I am updating a content block
    When I choose to schedule the change
    And I save and continue
    Then I see the errors prompting me to provide a date and time

  Scenario: GDS Editor does not provide a valid date for scheduling
    When I am updating a content block
    When I choose to schedule the change
    And I enter an invalid date
    And I save and continue
    Then I see the errors informing me the date is invalid

  Scenario: GDS Editor provides a date in the past for scheduling
    When I am updating a content block
    When I choose to schedule the change
    And I enter a date in the past
    And I save and continue
    Then I see the errors informing me the date must be in the future

  Scenario: GDS Editor cancels after scheduling a block
    When I am updating a content block
    When I choose to schedule the change
    And the block is scheduled and published
    And I click the cancel link
    And I choose to delete the in-progress draft
    Then I should be taken back to the document page
