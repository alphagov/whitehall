Feature: Viewing upcoming statistical release announcements

  Scenario: Citizen filters the list of statistical release announcements and uses the pagination
    Given There are some statistical release announcements
    When I visit the statistical release announcements page
    Then I can see the first page of all the statistical release announcements
    When I navigate to the next page of statistical release announcements
    Then I can see the second page of all the statistical release announcements
    When I filter the statistical release announcements by keyword, from_date and to_date
    And I should only see statistical release announcements for those filters
