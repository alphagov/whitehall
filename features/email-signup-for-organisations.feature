Feature: Email signup for organisations

  Background:
    Given I am a GDS editor
    And the organisation "Sledgehamster extermination inc." exists with a featured article
    And the organisation "The Empire" exists with a featured article

  Scenario: Signing up to role alerts
    Given I visit the "Sledgehamster extermination inc." organisation
    Then a govuk_delivery signup should be sent for the feed subscription URL
    And a govuk_delivery notification should be sent for the feed subscription URL
    And a govuk_delivery notification should be sent for anything other than the feed subscription URL
    When I sign up for emails
    And I publish a news article "Nerf gun trials proved unsucessful" associated with the organisation "Sledgehamster extermination inc."
    And I publish a news article "Critial security vulnerability exposed in Death Start plans" associated with the organisation "The Empire"
