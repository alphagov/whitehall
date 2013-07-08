Feature: Rejecting submitted policies

Scenario: An editor rejects a submitted policy
  Given I am an editor
  And a submitted policy titled "The policy"
  When I reject the policy titled "The policy"
  Then I should see the policy titled "The policy" in the list of documents that need work
  And the writers who worked on the policy titled "The policy" should be emailed about the rejection

Scenario: A writer viewing a rejected policy
  Given an editor named "George" has rejected the policy titled "The policy"
  And I am a writer
  When I view the policy titled "The policy"
  Then I should see that it was rejected by "George"

Scenario: A writer re-submitting a rejected policy
  Given an editor named "George" has rejected the policy titled "The policy"
  And I am a writer
  When I resubmit the policy titled "The policy"
  Then I should see the policy titled "The policy" in the list of submitted documents