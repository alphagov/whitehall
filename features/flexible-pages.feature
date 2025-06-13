Feature: Flexible pages

  Scenario: Creating a new draft flexible page
    Given I am a writer in the organisation "Department of Examples"
    And the flexible pages feature flag is enabled
    And the test flexible page type is defined
    When I draft a new "Test flexible page type" flexible page titled "The history of GOV.UK"
    Then I am on the summary page of the draft titled "The history of GOV.UK"