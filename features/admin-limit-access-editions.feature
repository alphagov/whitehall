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

  Scenario: Attempting to access limit a new (unpersisted) document against a different org
    Given I am an editor
    When I begin drafting a new document
    And I set the Lead organisation to an org I am not in
    And I check the "Limit access to publishers from organisations associated with this document before you publish" box
    When I click "Save"
    Then I should see the validation error "Access can only be limited by users belonging to an organisation tagged to the document"

  Scenario: Attempting to change organisation when document is access limited
    Given I am an editor in the organisation "Foo"
    And I create an access limited document
    When I set the Lead organisation to an org I am not in
    When I click "Save"
    Then I should see the validation error "Access can only be limited by users belonging to an organisation tagged to the document"
    And I should still be able to access the document
