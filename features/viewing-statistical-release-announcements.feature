Feature: Viewing upcoming statistical release announcements

  Scenario: Citizen views a list of all statistical release announcements
    Given There are some statistical release announcements in rummager
    When I visit the statistical release announcements page
    Then I should all the statistical release announcements

  Scenario: Citizen filters the lise of statistical release announcements
    Given There are some statistical release announcements in rummager
    When I visit the statistical release announcements page
    And I filter the statistical release announcements by keyword, from_date and to_date
    Then I should only see statistical release announcements for those filters
