Feature: Email signup for policies

  Background:
    Given I am a GDS editor
    And govuk delivery exists
    And a published policy "Exterminate! Exterminate!"
    And a published news article associated with the policy "Exterminate! Exterminate!"

  Scenario: Signing up to policy alerts
    Given I visit the policy activity page for "Exterminate! Exterminate!"
    When I sign up for emails
    Then I should be signed up for the "Exterminate! Exterminate!" policy mailing list

    When I publish a news article "More news" associated with the policy "Exterminate! Exterminate!"
    Then a govuk_delivery notification should have been sent to the mailing list I signed up for
