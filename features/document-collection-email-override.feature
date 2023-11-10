Feature: Setting the taxonomy topic email override for a document collection

  Scenario: Setting the email override.
    Given I am a user with email override editor permissions.
    And a draft document collection published by my organisation exists.
    When I visit the edit document collection page
    Then I click on the tab "Email notifications"
    And I choose "Emails about this topic"
    And I select "School Curriculum"
    And I click the checkbox to confirm my selection.
    And I click "Save"
    Then I see the success message "You have set the email type"

  Scenario: User cannot set the email override without checking the confirmation box.
    Given I am a user with email override editor permissions.
    And a draft document collection published by my organisation exists.
    When I visit the edit document collection page
    Then I click on the tab "Email notifications"
    And I choose "Emails about this topic"
    And I select "School Curriculum"
    And I click "Save"
    Then I see the error "You must confirm you’re happy with the email notification settings" prompting me to confirm my selection.



