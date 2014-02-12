Feature: Email signup for topics

  Background:
    Given I am a GDS editor
    And govuk delivery exists
    And a topic called "Wombat management" exists with featured documents
    And a topic called "Sledgehamster population control" exists with featured documents

  Scenario: Signing up to topic alerts
    Given I visit the "Wombat management" topic
    When I sign up for emails
    Then I should be signed up for the "Wombat management" topic mailing list

    When I publish a news article "Massive wombat influx in Wimbledon Common" associated with the topic "Wombat management"
    Then a govuk_delivery notification should have been sent to the mailing list I signed up for
