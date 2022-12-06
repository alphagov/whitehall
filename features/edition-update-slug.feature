Feature: Edition update slug
  This feature allows GDS editors to update a documents slug

  Scenario: GDS editor updates a slug
    Given I am a GDS editor
    And a published news article "You will never guess" exists
    And I visit the edit slug page for "You will never guess"
    And I update the slug to "/new-slug"
    Then I can see the slug has been updated to "/new-slug"

  Scenario: Admin attempts to update a slug
    Given I am an admin
    And a published news article "You will never guess" exists
    And I visit the edit slug page for "You will never guess"
    Then I am told I do not have access to the document
