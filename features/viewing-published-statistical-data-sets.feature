Feature: Viewing published statistical data sets

  Scenario: The Statistical data set has been associated with a document series
    Given a document series "Free flow speeds"
    And a published publication that's part of the "Free flow speeds" document series
    And a published statistical data set "Vehicle speeds 2010" that's part of the "Free flow speeds" document series
    When I visit the list of publications
    And I follow the link to the "Free flow speeds" document series
    And I follow the link to the "Vehicle speeds 2010" statistical data set
    Then I should see the "Vehicle speeds 2010" statistical data set
