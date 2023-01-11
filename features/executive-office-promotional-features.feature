Feature: Promotional features for executive offices

  Background:
    Given I am an admin
    And the executive office organisation "Number 32 - The Cheese Office" exists

  Scenario: Add a promotional feature with an image to an executive office
    When I add a new promotional feature with a single item which has an image
    Then I should see the promotional feature on the organisation's page

  Scenario: Add a promotional feature with a youtube url to an executive office
    When I add a new promotional feature with a single item which has a YouTube URL
    Then I should see the promotional feature on the organisation's page

  Scenario: Deleting a promotional feature
    And the executive office has a promotional feature with an item
    When I delete the promotional feature
    Then I should no longer see the promotional feature

  Scenario: Editing an existing promotional feature item
    And the executive office has a promotional feature with an item
    When I edit the promotional item, set the summary to "Edited summary"
    Then I should see the promotional feature item's summary has been updated to "Edited summary"

  Scenario: Deleting a promotional feature item
    And the executive office has a promotional feature with an item
    When I delete the promotional item
    Then I should no longer see the promotional item

  Scenario: Limiting the number of feature items to a maximum of three
    And the executive office has a promotional feature with the maximum number of items
    When I view the promotional feature
    Then I should not be able to add any further feature items

  Scenario: Reordering promotional features
    And the executive office has the promotional feature "Feature 1"
    And the executive office has the promotional feature "Feature 2"
    And the executive office has the promotional feature "Feature 3"
    When I set the order of the promotional features to:
      | title       | order |
      | Feature 2   | 1     |
      | Feature 3   | 2     |
      | Feature 1   | 3     |
    Then the promotional features should be in the following order:
      | title       |
      | Feature 2   |
      | Feature 3   |
      | Feature 1   |
