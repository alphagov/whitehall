Feature: Email signup for world locations

  Background:
    Given I am a GDS editor
    And govuk delivery exists
    And a world location "Best City" exists

  Scenario: Signing up to world location alerts
    Given I view the world location "Best City"
    When I sign up for emails
    Then I should be signed up for the "Best City" world location mailing list

    When I publish a world location news article "More news" for "Best City"
    Then a govuk_delivery notification should have been sent to the mailing list I signed up for
