Feature: Email signup for world locations

  Background:
    Given I am a GDS editor
    And a world location "Best City" exists
    And a world location "Irrelevantland" exists

  Scenario: Signing up to role alerts
    Given I view the world location "Best City"
    Then a govuk_delivery signup should be sent for the feed subscription URL
    And a govuk_delivery notification should be sent for the feed subscription URL
    And a govuk_delivery notification should be sent for anything other than the feed subscription URL
    When I sign up for emails
    And I publish a world location news article "More news" for "Best City"
    And I publish a world location news article "Irrelevant news" for "Irrelevantland"
