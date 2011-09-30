Feature: Editing submitted policies
In order to publish policies of a consistent quality
A department editor
Should be able to edit submitted policies

Scenario: Editing a submitted policy
  Given "Ben Beardson" submitted "Legalise beards" with body "Beards for everyone!"
  And I am an editor
  And I visit the list of policies awaiting review

  When I change the policy "Legalise beards" to "Decriminalise beards"

  Then I should see the policy "Decriminalise beards" in the list of submitted policies