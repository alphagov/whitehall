Feature: Email signup for documents

  Background:
    Given I am a GDS editor
    And govuk delivery exists
    And email alert api exists
    And a list of publications exists

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
