Feature: Editing draft policies
In order to send the best version of a policy to the departmental editor
A policy writer
Should be able to edit and save draft policies

Scenario: Saving a draft policy
  Given I am logged in as "George"
  And I visit the list of draft policies
  And I click create new policy
  Then I should be on the new policy page
  When I write and save a policy called "Milk for kids" with body
    """
    Calcium is good for growing bones!
    """
  Then I should see the policy "Milk for kids" written by "George" in my list of draft policies

Scenario: Submitting a draft policy to the second set of eyes
  Given I am logged in as "George"
  And I have written a policy called "Legalise beards"
  And I submit the policy for the second set of eyes
  Then I should be notified "Your policy has been submitted to your second pair of eyes"
  And I should not see the policy "Legalise beards" in my list of draft policies

Scenario: Cancelling the draft policy
  Given I am logged in as "George"
  And I visit the new policy page
  When I click cancel
  Then I should be on the policies admin page

Scenario: Editing an existing draft policy
  Given I am logged in as "George"
  And I have written a policy called "Legalise beards"
  And I visit the list of draft policies
  When I change the policy "Legalise beards" to "Decriminalise beards"
  Then I should see the policy "Decriminalise beards" in my list of draft policies

Scenario: Cancelling the draft policy
  Given I am logged in as "George"
  And I have written a policy called "Legalise beards"
  And I visit the list of draft policies
  And I click edit for the policy "Legalise beards"
  When I click cancel
  Then I should be on the policies admin page

Scenario: Entering invalid data
  Given I am logged in as "George"
  And I visit the new policy page
  When I write and save a policy called "Britons on the Moon" with body ""
  Then I should be alerted "There are some problems with the policy"

Scenario: Trying to save a policy that has been changed by another user
  Given I am logged in as "George"
  And I have written a policy called "Legalise beards"
  And I visit the list of draft policies
  And I click edit for the policy "Legalise beards"
  When another user changes the body for "Legalise beards" to "Hair is good!"
  And I press save
  Then I should be alerted that the policy has been saved while I was editing
