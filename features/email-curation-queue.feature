Feature: Email queue for local gov alerts
  As an editor of local government email alerts from GOV.UK,
  I need to be able to review the title text, summary text and change
  notes of all documents that are flagged as 'relevant to local government'
  before the message information is sent to GovDelivery's "create bulletin"

  Done means:

  1. When local government items are published, they get put into a queue instead of sending an email.
  2. The title and summary are copied into new fields
  3. The new queue items can be deleted, or edited and saved. Saving the item uses the notify_govuk_delivery logic to send the queued item.

  Background:
    Given I am a GDS editor

  Scenario: Approving a local government policy for delivery
    When a policy relevant to local government is published
    Then the policy is listed at the top of the email curation queue
    When I tweak the title and summary to better reflect why it is interesting to subscribers
    Then the policy should be sent to the notification service with the tweaked copy
    When I decide the policy is ready to go out
    And then the policy is not listed on the email curation queue

  Scenario: Rejecting delivery for a local government policy
    When a policy relevant to local government is published
    Then the policy is listed at the top of the email curation queue
    And the policy should not be sent to the notification service
    When I decide the policy is not relevant to subscribers and delete it
    And then the policy is not listed on the email curation queue
