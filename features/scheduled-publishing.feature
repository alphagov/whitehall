Feature: Scheduled publishing

  @disable-sidekiq-test-mode
  Scenario: An editor schedules a submitted edition for scheduled publication
    Given I am an editor
    And a submitted scheduled news article exists
    When I schedule the news article for publication
    Then the news article is published when the scheduled publication time arrives

  @disable-sidekiq-test-mode
  Scenario: A writer force-schedules an edition for publication
    Given I am an editor
    And a draft scheduled news article exists
    When I force schedule the news article for publication
    Then the news article is published when the scheduled publication time arrives
