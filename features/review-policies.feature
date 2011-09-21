Feature: Reviewing policies
In order to review the policies
A departmental editor
Should see all policies which have been submitted for a second set of eyes

Scenario: Viewing a policy that's been submitted for review
  Given "Ben Beardson" submitted "Legalise beards" with body "Beards for everyone!"
  When I visit the list of policies awaiting review
  And I view the policy titled "Legalise beards"
  Then I should see that "Ben Beardson" is the policy author
  And I should see that "Beards for everyone!" is the policy body