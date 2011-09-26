Feature: Publishing policies
In order to allow the public to view policies
A departmental editor
Should be able to publish policies

Scenario: Draft policies shouldn't be viewable by the public
  Given I am logged in as "Ben Beardson"
  And I have written a policy called "Legalise beards"
  Then the policy "Legalise beards" should not be visible to the public

Scenario: Publishing a policy that's been submitted to the second set of eyes
  Given "Ben Beardson" submitted "Legalise beards" with body "Beards for everyone!"
  And I am logged in as a departmental editor called "Edward Editor"
  When I publish the policy called "Legalise beards"
  Then the policy "Legalise beards" should be visible to the public

Scenario: The policy author shouldn't be able to publish the policy
  Given I am logged in as a departmental editor called "Edward Editor"
  And I have written a policy called "Eddie The Eagle as Olypmic Tsar"
  And I submit the policy for the second set of eyes
  When I publish the policy called "Eddie The Eagle as Olypmic Tsar"
  Then I should be alerted that I am not the second set of eyes
  And the policy "Eddie The Eagle as Olypmic Tsar" should not be visible to the public

Scenario: A policy writer shouldn't be able to publish policies
  Given "Ben Beardson" submitted "Legalise beards" with body "Beards for everyone!"
  And I am logged in as "Wally Writer"
  When I publish the policy called "Legalise beards"
  Then I should be alerted that I do not have privileges to publish policies
  Then the policy "Legalise beards" should not be visible to the public

Scenario: Policies shouldn't be publishable when they've been changed by another user
  Given "Ben Beardson" submitted "Legalise beards" with body "Beards for everyone!"
  And I am logged in as a departmental editor called "Edward Editor"
  And I open the policy "Legalise beards"
  When another user changes the title from "Legalise beards" to "Decriminalise beards"
  And I press publish
  Then I should be alerted that the policy has been changed
  And the policy "Legalise beards" should not be visible to the public
  And the policy "Decriminalise beards" should not be visible to the public