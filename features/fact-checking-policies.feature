Feature: Fact checking policies
  In order to ensure we're not publishing any inaccuracies in our policies
  As a policy writer
  I want to request fact checking of a draft policy

Scenario: Policy writer requests fact checking
  Given I am logged in as "George"
  And I have drafted a policy

  When I request that "fact-checker@example.com" fact checks the policy

  Then "fact-checker@example.com" should receive an email requesting fact checking