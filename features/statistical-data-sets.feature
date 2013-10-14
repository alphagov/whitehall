Feature: Statistical data sets

  Scenario: Creating a new draft statistical data set
    Given I am a writer in the organisation "Ministry of Grooming"
    When I draft a new statistical data set "Standard Beard Lengths" for organisation "Ministry of Grooming"
    Then I should see the statistical data set "Standard Beard Lengths" in the list of draft documents

  @not-quite-as-fake-search
  Scenario: The Statistical data set has been associated with a document collection
    Given a published document collection "Free flow speeds" exists
    And a published publication that's part of the "Free flow speeds" document collection
    And a published statistical data set "Vehicle speeds 2010" that's part of the "Free flow speeds" document collection
    When I visit the list of publications
    And I follow the link to the "Free flow speeds" document collection
    And I follow the link to the "Vehicle speeds 2010" statistical data set
    Then I should see the "Vehicle speeds 2010" statistical data set
