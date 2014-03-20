Feature: Viewing upcoming statistics announcements

  Scenario: Citizen filters the list of statistics announcements and uses the pagination
    Given There are some statistics announcements
    When I visit the statistics announcements page
    Then I can see the first page of all the statistics announcements
    When I navigate to the next page of statistics announcements
    Then I can see the second page of all the statistics announcements
    When I filter the statistics announcements by keyword, from_date and to_date
    And I should only see statistics announcements for those filters

  Scenario: Citizen filters the list of statistics announcements by department and topic
    Given There are some statisics announcments for various departments and topics
    When I visit the statistics announcements page
    And I filter the statistics announcements by department and topic
    Then I should only see statistics announcements for the selected departments and topics

  Scenario: Citizen views the details of a statistics announcement
    Given There is a statistics announcement
    When I visit the statistics announcements page
    And I click on the first statistics announcement
    Then I should be on a page showing the title, release date, organisation, topic and summary of the release announcement
