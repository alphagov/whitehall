Feature: Promotional features for executive offices

  Background:
    Given I am an admin
    And the executive office organisation "Number 32 - The Cheese Office" exists

    Scenario: Add a promotional feature to an executive office
      When I add a new promotional feature with a single item
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
