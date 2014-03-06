Feature: Viewing upcoming release announcements

  Scenario: Citizen views a list of all release announcements
    Given There are some release announcements in rummager
    When I visit the release announcements page
    Then I should all the release announcements

  Scenario: Citizen filters the lise of release announcements
    Given There are some release announcements in rummager
    When I visit the release announcements page
    And I filter the release announcements by keyword, from_date and to_date
    Then I should only see release announcements for those filters
