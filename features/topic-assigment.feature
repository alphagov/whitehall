Feature: Assigning editions to topics, via policies

  Background:
    Given I am a GDS editor

  @javascript
  @not-quite-as-fake-search
  Scenario: Editions can be assigned directly to topics
    Given a publicationesque that can be assigned to policies and topics
    When I assign the publicationesque to a topic
    Then the edition will be assigned to the topic

  @javascript
  @not-quite-as-fake-search
  Scenario: Editions can be assigned to topics via their policies
    Given an announcement that can be assigned to policies and topics
    When I assign the announcement to a policy with topics
    Then the policy's topics will be copied from the policy to the announcement
    And the edition will be assigned to the topic
