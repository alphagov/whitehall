Feature: Viewing most recent editions in admin

  Scenario: Viewing a current edition that has since been access limited as an editor
    Given I am an editor
    Given a published document "Road accidents" exists
    When someone else creates a new edition of the published document "Road accidents" and limits access to members of "Department of Secrecy"
    And I view the current edition of document "Road accidents"
    Then I am told I do not have permissions to access this page
    And I should not see a link to edit the access

  Scenario: Viewing a current edition that has since been access limited as a GDS admin
    Given I am a GDS admin
    Given a published document "Road accidents" exists
    When someone else creates a new edition of the published document "Road accidents" and limits access to members of "Department of Secrecy"
    And I view the current edition of document "Road accidents"
    Then I am told I do not have permissions to access this page
    And I should see a link to edit the access
