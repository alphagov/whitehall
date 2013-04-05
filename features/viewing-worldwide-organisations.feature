Feature: Viewing worldwide organisations
  Scenario: Viewing a list of worldwide organisations
    Given two worldwide organisations "UK Trade & Investment Australia" and "British Embassy Manama"
    When I visit the worldwide organisations index page
    Then I should see an alphabetical list containing "British Embassy Manama" and "UK Trade & Investment Australia"
