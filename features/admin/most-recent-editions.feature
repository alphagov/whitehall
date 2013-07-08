Feature: Viewing most recent editions in admin

  Background:
    Given I am an editor

  Scenario: Viewing an old edition I am prompted to view the most recent one
    Given a published document "Road accidents" exists
    When someone else creates a new edition of the published document "Road accidents"
    And I view the old edition of document "Road accidents"
    Then I can click through to the most recent version of document "Road accidents"

  Scenario: Viewing an old edition that has since been access limited
    Given a published document "Road accidents" exists
    When someone else creates a new edition of the published document "Road accidents" and limits access to members of "Department of Secrecy"
    And I view the old edition of document "Road accidents"
    Then I cannot click through to the most recent version of document "Road accidents"
