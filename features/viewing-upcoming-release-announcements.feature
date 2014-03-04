Feature: Viewing upcoming release announcements

  Background: Citizen views a list of all release announcements
    Given There are some release announcements in rummager
    When I visit the release announcements page
    Then I should all the release announcements
