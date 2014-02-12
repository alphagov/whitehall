Feature: Email signup for topical events

  Background:
    Given I am a GDS editor
    And govuk delivery exists
    And a topical event called "Wombat management" exists with featured documents
    And a topical event called "Sledgehamster population control" exists with featured documents

  Scenario: Signing up to topical event alerts
    Given I visit the "Wombat management" topical event
    When I sign up for emails
    Then I should be signed up for the "Wombat management" topical event mailing list

    When I publish a news article "Massive wombat influx in Wimbledon Common" associated with the topical event "Wombat management"
    Then a govuk_delivery notification should have been sent to the mailing list I signed up for
