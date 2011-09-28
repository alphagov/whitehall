Feature: Fact checking policies
  In order to ensure we're not publishing any inaccuracies in our policies
  As a policy writer
  I want to request fact checking of a draft policy

Scenario: Policy writer requests fact checking
  Given I am logged in as a policy writer
  And I have drafted a policy

  When I request that "fact-checker@example.com" fact checks the policy

  Then "fact-checker@example.com" should receive an email requesting fact checking

Scenario: Fact checker views the draft policy
  Given "fact-checker@example.com" has received an email requesting they fact check a draft policy titled "Check me"

  When "fact-checker@example.com" clicks the email link to the draft policy

  Then they should see the draft policy titled "Check me"