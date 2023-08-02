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
    Then I am redirected to the document collection edit page.



