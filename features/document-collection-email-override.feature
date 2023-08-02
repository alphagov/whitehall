Feature: Setting the taxonomy topic email override for a document collection

  Scenario: Setting the email override.
    Given I am a user with email override editor permissions.
    And a draft document collection published by my organisation exists.
    When I visit the edit document collection page
    Then I see the tab "Email notifications"



