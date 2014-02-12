Feature: Email signup for organisations

  Background:
    Given I am a GDS editor
    And govuk delivery exists
    And the organisation "Sledgehamster extermination inc." exists with a featured article
    And the organisation "The Empire" exists with a featured article

  Scenario: Signing up to role alerts
    Given I visit the "Sledgehamster extermination inc." organisation
    When I sign up for emails
    Then I should be signed up for the "Sledgehamster extermination inc." organisation mailing list

    And I publish a news article "Nerf gun trials proved unsucessful" associated with the organisation "Sledgehamster extermination inc."
    Then a govuk_delivery notification should have been sent to the mailing list I signed up for
