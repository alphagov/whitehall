Feature: Edition update slug
  This feature allows GDS editors to update a documents slug

  Scenario: GDS editor updates a slug
    Given I am a GDS admin
    And a published publication "You will never guess" exists
    And I visit the edit slug page for "You will never guess"
    And I update the slug to "new-slug"
    Then I can see the edition's public URL contains "new-slug"

  Scenario: Admin attempts to update a slug
    Given I am an admin
    And a published publication "You will never guess" exists
    And I visit the edit slug page for "You will never guess"
    Then I am told I do not have permissions to access this page

  Scenario: Writer updates the title of a document
    Given I am a writer
    And the slugs for editions feature flag is enabled
    And a published publication "You will never guess" exists
    When I edit the publication "You will never guess"
    And I change the title to "Ten facts that will shock you"
    And I save the edition and go to the document summary
    Then I can see the preview URL of the publication "Ten facts that will shock you" contains "ten-facts-that-will-shock-you"

  @javascript
  Scenario: Writer updates the title of a document and opts out of slug update
    Given I am a writer
    And the slugs for editions feature flag is enabled
    And a published publication "You will never guess" exists
    When I edit the publication "You will never guess"
    And I change the title to "Ten facts that will shock you"
    And I opt out of updating the slug
    And I save the edition and go to the document summary
    Then I can see the preview URL of the publication "Ten facts that will shock you" contains "you-will-never-guess"

  @javascript
  Scenario: Writer updates the title of a document and slugs for editions feature is disabled
    Given I am a writer
    And the slugs for editions feature flag is disabled
    And a published publication "You will never guess" exists
    When I edit the publication "You will never guess"
    And I change the title to "Ten facts that will shock you"
    Then I cannot opt out of updating the slug