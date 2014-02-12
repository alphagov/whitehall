Feature: Email signup for documents

  Background:
    Given I am a GDS editor
    And govuk delivery exists

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

  Scenario: Signing up for a feed which is relevant to local governments
    Given a published policy "Re-introduce feudalism to Cornwall" relevant to local government
    When I filter the announcements list by "News stories"
    When I sign up for emails, checking the relevant to local government box
    Then I should be signed up for the local government news stories mailing list

    When I publish a news article "Serfdom is prooving to be an unpopular lifestyle choice, says the mayor of Penzance" associated with the policy "Re-introduce feudalism to Cornwall"
    Then no govuk_delivery notifications should have been sent yet

    When I send the latest email in the email curation queue
    Then a govuk_delivery notification should have been sent to the mailing list I signed up for
