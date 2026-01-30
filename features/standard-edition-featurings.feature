Feature:
  As an Editor.
  I want to be able to create and manage featuring for configurable topical events.
  So that I can link users to relevant documents and links.

  Background:
    Given I am a GDS admin
    And a topical event standard edition called "Really topical" exists
    And the configurable document types feature flag is enabled

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
      | Featured Topical Event 2 | 0     |
      | Featured Topical Event 1 | 1     |
    Then the edition featurings should be in the following order:
      | title           |
      | Featured Topical Event 2 |
      | Featured Topical Event 1 |
