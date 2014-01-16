Feature: Email signup for topical events

  Background:
    Given I am a GDS editor
    Given a topical event called "Wombat management" exists with featured documents
    Given a topical event called "Sledgehamster population control" exists with featured documents

  Scenario: Signing up to topical event alerts
    Given I visit the "Wombat management" topical event
    Then a govuk_delivery signup should be sent for the feed subscription URL
    And a govuk_delivery notification should be sent for the feed subscription URL
    And a govuk_delivery notification should be sent for anything other than the feed subscription URL
    When I sign up for emails
    And I publish a news article "Massive wombat influx in Wimbledon Common" associated with the topical event "Wombat management"
    And I publish a news article "Another sledgehamster attack" associated with the topical event "Sledgehamster population control"
