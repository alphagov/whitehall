Feature: Email signup for documents

  Background:
    Given I am a GDS editor
    And govuk delivery exists
    And a list of publications exists

  Scenario: Signing up to unfiltered publications alerts
    When I visit the list of publications
    And I sign up for emails
    Then I should be signed up for the all publications mailing list

    When I publish a new publication called "Example Publication"
    Then a govuk_delivery notification should have been sent to the mailing list I signed up for

  Scenario: Signing up to filtered publications alerts
    When I filter the publications list by "Correspondence"
    And I sign up for emails
    Then I should be signed up to the correspondence publications mailing list

    When I publish a new publication of the type "Correspondence" called "Example Correspondence"
    Then a govuk_delivery notification should have been sent to the mailing list I signed up for

  Scenario: Signing up to unfiltered announcement alerts
    When I visit the list of announcements
    And I sign up for emails
    Then I should be signed up for the all announcements mailing list

    When I publish a new news article of the type "News story" called "Example News Article"
    Then a govuk_delivery notification should have been sent to the mailing list I signed up for

  Scenario: Signing up to filtered announcement alerts
    When I filter the announcements list by "News stories"
    And I sign up for emails
    Then I should be signed up for the news stories mailing list

    When I publish a new news article of the type "News story" called "Example News Story"
    Then a govuk_delivery notification should have been sent to the mailing list I signed up for
