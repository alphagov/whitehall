Feature: Administering historical accounts

  As a citizen
  I want to be able to read a historical account of a notable person's contribution to government
  So I can find out more about the history of government and understand government today in the
  context of what preceding government leaders have achieved

  Background:
    Given I am a GDS editor
    And a person called "Barry White" exists
    And the role "Minister of Love" exists

    Scenario: I can add an historical account to a person
      When I add an historical account to "Barry White" for his role as "Minister of Love"
      Then I should see a historical account for him in that role
