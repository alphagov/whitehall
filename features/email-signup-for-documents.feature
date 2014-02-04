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

  Scenario: Signing up for a feed which is relevant to local governments
    Given a published policy "Re-introduce feudalism to Cornwall" relevant to local government

    When I filter the announcements list by "News stories"

    Then a govuk_delivery signup should be sent for the local government feed subscription URL
    And a govuk_delivery notification should be sent for the local government feed subscription URL

    When I sign up for emails, checking the relevant to local government box
    And I publish a news article "Serfdom is prooving to be an unpopular lifestyle choice, says the mayor of Penzance" associated with the policy "Re-introduce feudalism to Cornwall"
    And I send the latest email in the email curation queue
