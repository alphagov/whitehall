Feature: Reviewing policies
In order to allow the public to view policies
A departmental editor
Should be able to publish policies

Scenario: Publishing a policy that's been submitted to the second set of eyes
  Given "Ben Beardson" submitted "Legalise beards" with body "Beards for everyone!"
  And I visit the list of policies awaiting review
  When I publish the policy called "Legalise beards"
  Then the policy "Legalise beards" should be visible to the public