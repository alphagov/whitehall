Feature: Email signup for topics

  Background:
    Given I am a GDS editor
    Given a topic called "Wombat management" exists with featured documents
    Given a topic called "Sledgehamster population control" exists with featured documents

  Scenario: Signing up to topic alerts
    Given I visit the "Wombat management" topic
    Then a govuk_delivery signup should be sent for the feed subscription URL
    And a govuk_delivery notification should be sent for the feed subscription URL
    And a govuk_delivery notification should be sent for anything other than the feed subscription URL
    When I sign up for emails
    And I publish a news article "Massive wombat influx in Wimbledon Common" associated with the topic "Wombat management"
    And I publish a news article "Another sledgehamster attack" associated with the topic "Sledgehamster population control"
