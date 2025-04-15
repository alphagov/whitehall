Feature: Scheduling editions

  Background:
    Given I am an editor

  Scenario Outline: Scheduling a submitted edition
    Given I draft a new publication "Ban Beards"
    And the sidebar scheduling feature flag is <sidebar_scheduling_enabled>
    When I propose scheduling the publication "Ban Beards" to be published in one month
#    And another editor approves "Ban Beards" for scheduled publication
#    Then the publication "Ban Beards" should have a scheduled publishing date one month in the future

  Examples:
    | sidebar_scheduling_enabled |
    | enabled |
    | disabled |
