Feature: Email signup for documents

  Background:
    Given I am a GDS editor

  Scenario: Signing up to unfiltered publications alerts
    When I visit the list of publications

    Then a govuk_delivery signup should be sent for the feed subscription URL
    And a govuk_delivery notification should be sent for the feed subscription URL
    When I sign up for emails
    And I publish a new publication called "Example Publication"

  Scenario: Signing up to filtered publications alerts
    When I filter the publications list by "Correspondence"

    Then a govuk_delivery signup should be sent for the feed subscription URL
    And a govuk_delivery notification should be sent for the feed subscription URL
    And a govuk_delivery notification should be sent for anything other than the feed subscription URL
    When I sign up for emails
    And I publish a new publication of the type "Correspondence" called "Example Correspondence"
    And I publish a new publication of the type "International treaty" called "Example International Treaty"

  Scenario: Signing up to unfiltered announcement alerts
    When I visit the list of announcements

    Then a govuk_delivery signup should be sent for the feed subscription URL
    And a govuk_delivery notification should be sent for the feed subscription URL
    When I sign up for emails
    And I publish a new news article of the type "News story" called "Example News Article"

  Scenario: Signing up to filtered announcement alerts
    When I filter the announcements list by "News stories"

    Then a govuk_delivery signup should be sent for the feed subscription URL
    And a govuk_delivery notification should be sent for the feed subscription URL
    And a govuk_delivery notification should be sent for anything other than the feed subscription URL
    When I sign up for emails
    And I publish a new news article of the type "News story" called "Example News Story"
    And I publish a new news article of the type "Press release" called "Example Press Release"
