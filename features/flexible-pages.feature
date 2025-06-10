Feature: Flexible pages

  Scenario: Creating a new draft flexible page
    Given I am a writer in the organisation "Department of Examples"
    And the flexible pages feature flag is enabled
    When I draft a new "History page" flexible page titled "The history of GOV.UK"
    Then I can see a preview link