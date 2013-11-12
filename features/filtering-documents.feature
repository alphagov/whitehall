@not-quite-as-fake-search
Feature: Filtering Documents

  As a citizen, I want to be able to browse various types of content by filtering down by the following attributes.

  - Publications (inc. Consultations & Statistics):
    - Keyword
    - Publication type
    - Topic
    - Department
    - Official document status
    - World locations
    - Published date

  - Policies
    - Keyword
    - Topic
    - Department

  - Announcements
    - Keyword
    - Announcement type
    - Topic
    - Department
    - World Location
    - Published date

  - Viewing translated index page
    - e.g. https://www.gov.uk/government/announcements.fr?include_world_location_news=1&world_locations[]=france

    - c.f. world-location-news.feature


  Scenario: Filtering policies
    Given there are some published policies
    When I look at the policies index page
    Then I should be able to filter policies by topic, department and keyword

  Scenario: Filtering publications
    Given there are some published publications
    When I visit the publications index page
    Then I should be able to filter publications by keyword, publication type, topic, department, official document status, world location, and publication date

  Scenario: Filtering announcements
    Given there are some published announcements
    When I visit the announcements index page
    Then I should be able to filter announcements by keyword, announcement type, topic, department, world location and publication date

  @javascript
  Scenario: Filtering publications in a javascript-enabled browser
    Given there are some published publications
    When I visit the publications index page
    When I select a filter option without clicking any button
    Then the filtered publications refresh automatically

  Scenario: Filtering translated announcments
    Given there are some published announcments including a few in French
    When I visit the announcments index in French
    Then I should see only announcements which have French translations
    And I should be able to filter them by country (or 'Pays' in French)

  Scenario: User filters by "Statistics" which returns statistics and national statistics
    Given a published publication "Road accidents" with type "Statistics"
    And a published publication "National road accidents" with type "Statistics - national statistics"
    When I filter the publications list by "Statistics"
    Then I should see "Road accidents" in the result list
    And I should see "National road accidents" in the result list
