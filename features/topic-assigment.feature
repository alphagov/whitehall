Feature: Assigning editions to topics, via policies

  Background:
    Given I am a GDS editor

  @javascript
  Scenario: Editions can be assigned directly to topics
    Given a publicationesque that can be assigned to policies and topics
    When I assign the publicationesque to a topic
    Then the edition will be assigned to the topic
