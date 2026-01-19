Feature:
  As an Editor.
  I want to be able to create and manage features for configurable standard editions.
  So that I can link users to relevant documents and links.

  Background:
    Given I am a GDS admin
    And a featurable standard edition called "Featurable Edition" exists
    And the configurable document types feature flag is enabled

  Scenario: Featuring an edition
    Given the featurable standard edition is linked to an edition with the title "Featured edition"
    When I visit the standard edition featuring index page
    And I feature "Featured edition"
    Then I see that "Featured edition" has been featured

  Scenario: Reordering currently featured documents
    Given two featurings exist for the edition
    When I visit the standard edition featuring index page
    And I set the order of the edition featurings to:
      | title              | order |
      | Featured Edition 2 | 0     |
      | Featured Edition 1 | 1     |
    Then the edition featurings should be in the following order:
      | title              |
      | Featured Edition 2 |
      | Featured Edition 1 |
