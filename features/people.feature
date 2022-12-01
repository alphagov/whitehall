Feature: Managing a person

  Background:
    Given I am an admin

  Scenario: Adding a person
    When I add a new person called "Dave Cameroon"
    Then I should be able to see "Dave Cameroon" in the list of people

  Scenario: Editing a person
    Given a person called "Dave Camerine"
    When I update the person called "Dave Camerine" to have the name "Nick Clogg"
    Then I should be able to see "Nick Clogg" in the list of people

  Scenario: Removing a person
    Given a person called "Liam Fixx"
    When I remove the person "Liam Fixx"
    Then I should not be able to see "Liam Fixx" in the list of people

  Scenario: Adding a new translation
    Given a person called "Amanda Appleford" exists with the biography "She was born. She lived. She died."
    When I add a new "Français" translation to the person "Amanda Appleford" setting biography to "Ca va"
    Then I should see the translation "Français" and body text "Ca va"

  Scenario: Editing an existing translation
    Given a person called "Amanda Appleford" exists with a translation for the locale "Français"
    When I edit the "Français" translation for the person "Amanda Appleford" updating the biography to "Ca va bien"
    Then I should see the translation "Français" and body text "Ca va bien"
