Feature: Setting the taxonomy topic email override for a document collection

  Scenario: Setting the email override.
    Given I am a user with email override editor permissions.
    And a draft document collection published by my organisation exists.
    When I visit the edit document collection page
    Then I click on the tab "Email notifications"
    And I choose "Emails about this topic"
    And I select "Topic One"
    And I click the checkbox to confirm my selection.
    And I click "Save"
    Then I see the success message "You’ve selected the email notification settings. You’ve chosen ‘Emails about the topic’ and the topic Topic One. You will not be able to change these settings after you publish the collection."


  Scenario: User cannot set the email override without checking the confirmation box.
    Given I am a user with email override editor permissions.
    And a draft document collection published by my organisation exists.
    When I visit the edit document collection page
    Then I click on the tab "Email notifications"
    And I choose "Emails about this topic"
    And I select "Topic One"
    And I click "Save"
    Then I see the error "You must confirm you’re happy with the email notification settings" prompting me to confirm my selection.



