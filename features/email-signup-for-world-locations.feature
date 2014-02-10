Feature: Email signup for world locations

  Background:
    Given I am a GDS editor
    And govuk delivery exists
    And a world location "Best City" exists
    And a world location "Irrelevantland" exists

  Scenario: Signing up to role alerts
    Given I view the world location "Best City"
    When I sign up for emails
    Then I should be signed up for the "Best City" world location mailing list

    When I publish a world location news article "Irrelevant news" for "Irrelevantland"
    Then a govuk_delivery notification should not have been sent to the mailing list I signed up for

    When I publish a world location news article "More news" for "Best City"
    Then a govuk_delivery notification should have been sent to the mailing list I signed up for
