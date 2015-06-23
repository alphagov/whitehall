Feature: Assigning editions to policy areas, via policies

  Background:
    Given I am a GDS editor

  @javascript
  Scenario: Editions can be assigned directly to policy areas
    Given a publicationesque that can be assigned to policies and policy areas
    When I assign the publicationesque to a policy area
    Then the edition will be assigned to the policy area
