Feature: Publishing policies
In order to allow the public to view policies
A departmental editor
Should be able to publish policies

Scenario: Draft policies shouldn't be viewable by the public
  Given I am a writer
  And I have drafted a policy called "Legalise beards"
  Then the policy "Legalise beards" should not be visible to the public

Scenario: Publishing a policy that's been submitted to the second set of eyes
  Given "Ben Beardson" submitted "Legalise beards" with body "Beards for everyone!"
  And I am an editor
  When I publish the policy called "Legalise beards"
  Then the policy "Legalise beards" should be visible to the public

Scenario: Policies shouldn't be publishable when they've been changed by another user
  Given "Ben Beardson" submitted "Legalise beards" with body "Beards for everyone!"
  And I am an editor
  And I open the policy "Legalise beards"
  When another user changes the title from "Legalise beards" to "Decriminalise beards"
  And I press publish
  Then I should be alerted that the policy has been changed
  And the policy "Legalise beards" should not be visible to the public
  And the policy "Decriminalise beards" should not be visible to the public
