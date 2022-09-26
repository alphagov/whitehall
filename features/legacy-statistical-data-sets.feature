Feature: Statistical data sets

  Scenario: Creating a new draft statistical data set
    Given I am a writer in the organisation "Ministry of Grooming"
    When I draft a new statistical data set "Standard Beard Lengths" for organisation "Ministry of Grooming"
    Then I should see the statistical data set "Standard Beard Lengths" in the list of draft documents
