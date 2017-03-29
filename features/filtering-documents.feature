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

  Scenario: Filtering announcements
    Given there are some published announcements
    When I visit the announcements index page
    Then I should be able to filter announcements by keyword, announcement type, topic, department, world location and publication date

  Scenario: Filtering translated announcments
    Given there are some published announcments including a few in French
    When I visit the announcments index in French
    Then I should see only announcements which have French translations
    And I should be able to filter them by country (or 'Pays' in French)
