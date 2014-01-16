Feature: Email signup for policies

  Background:
    Given I am a GDS editor
    And a published policy "Exterminate! Exterminate!"
    And a published policy "Irrelevant Policy"
    And a published news article associated with the policy "Exterminate! Exterminate!"

  Scenario: Signing up to role alerts
    Given I visit the policy activity page for "Exterminate! Exterminate!"
    Then a govuk_delivery signup should be sent for the feed subscription URL
    And a govuk_delivery notification should be sent for the feed subscription URL
    And a govuk_delivery notification should be sent for anything other than the feed subscription URL
    When I sign up for emails
    And I publish a news article "More news" associated with the policy "Exterminate! Exterminate!"
    And I publish a news article "Irrelevant news" associated with the policy "Irrelevant Policy"
