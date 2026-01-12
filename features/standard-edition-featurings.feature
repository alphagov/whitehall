Feature:
  As an Editor.
  I want to be able to create and manage featuring for configurable topical events.
  So that I can link users to relevant documents and links.

  Background:
    Given I am a GDS admin
    And a topical event standard edition called "Really topical" exists
    And the configurable document types feature flag is enabled

  Scenario: Creating a non-GOV.UK link
    When I visit the standard edition featuring index page
    And I create a new a non-GOV.UK link with the title "Featured link"
    Then I can see the non-GOV.UK link with the title "Featured link"

  Scenario: Editing a non-GOV.UK link
    Given the topical event standard edition has an offsite link with the title "Featured link"
    When I visit the standard edition featuring index page
    And I update the title of a featured link from "Featured link" to "New title"
    Then I can see the non-GOV.UK link with the title "New title"

  Scenario: Deleting a non-GOV.UK link
    Given the topical event standard edition has an offsite link with the title "Featured link"
    When I visit the standard edition featuring index page
    And I delete "Featured link"
    Then I can see that "Featured link" has been deleted

  Scenario: Featuring a non-GOV.UK link
    Given the topical event standard edition has an offsite link with the title "Featured link"
    When I visit the standard edition featuring index page
    And I feature "Featured link"
    Then I see that "Featured link" has been featured

  Scenario: Featuring an edition
    Given the topical event standard edition is linked to an edition with the title "Featured edition"
    When I visit the standard edition featuring index page
    And I feature "Featured edition"
    Then I see that "Featured edition" has been featured

  Scenario: Reordering currently featured documents
    Given two featurings exist for the edition
    When I visit the standard edition featuring index page
    And I set the order of the edition featurings to:
      | title           | order |
      | Featured link 2 | 0     |
      | Featured link 1 | 1     |
    Then the edition featurings should be in the following order:
      | title           |
      | Featured link 2 |
      | Featured link 1 |
