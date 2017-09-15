Feature: Email signup for organisations

  Background:
    Given I am a GDS editor
    And email alert api exists
    And the organisation "Sledgehamster extermination inc." exists with a featured article

  Scenario: Signing up to organisation alerts
    Given I visit the "Sledgehamster extermination inc." organisation
    When I sign up for emails
    Then I should be signed up for the "Sledgehamster extermination inc." organisation mailing list
