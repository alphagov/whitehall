Feature: Historical accounts

  As a citizen
  I want to be able to read a historical account of a notable person's contribution to government
  So I can find out more about the history of government and understand government today in the
  context of what preceding government leaders have achieved

  Scenario: I can add an historical account to a person
    Given I am a GDS editor
    And a person called "Barry White" exists in the role of "Prime Minister"
    When I add an historical account to "Barry White" for his role as "Prime Minister"
    Then I should see a historical account for him in that role

  Scenario: Viewing historic appointments
    Given there are previous prime ministers
    When I view the past prime ministers page
    Then I should see the previous prime ministers listed according the century in which they served
    When I view the most recent past prime minister
    Then I should see the most recent past priminister's historical account on the page
