Feature: Editionable worldwide organisations
  Background:
    Given I am a GDS editor
    And The editionable worldwide organisations feature flag is enabled
    And a world location "United Kingdom" exists

  Scenario Outline: Creating a new draft worldwide organisation
    When I draft a new worldwide organisation "Test Worldwide Organisation" assigned to world location "United Kingdom"
    Then the worldwide organisation "Test Worldwide Organisation" should have been created
    And I should see it has been assigned to the "United Kingdom" world location
    And I should see the editionable worldwide organisation "Test Worldwide Organisation" in the list of draft documents

  Scenario Outline: Adding a translation to an existing worldwide organisation
    When I draft a new worldwide organisation "Test Worldwide Organisation" assigned to world location "United Kingdom"
    And I add a Welsh translation of the worldwide organisation "Test Worldwide Organisation" named "Translated Name"
    Then I should see the Welsh translated title "Translated Name" for the "Test Worldwide Organisation" worldwide organisation

  Scenario Outline: Assigning a role to a worldwide organisation
    Given a role "Prime Minister" exists
    When I draft a new worldwide organisation "Test Worldwide Organisation" assigned to world location "United Kingdom"
    And I edit the worldwide organisation "Test Worldwide Organisation" adding the role of "Prime Minister"
    Then I should see the "Prime Minister" role has been assigned to the worldwide organisation "Test Worldwide Organisation"

  Scenario Outline: Adding a social media account to a worldwide organisation
    Given a social media service "Facebook" exists
    When I draft a new worldwide organisation "Test Worldwide Organisation" assigned to world location "United Kingdom"
    And I edit the worldwide organisation "Test Worldwide Organisation" adding the social media service of "Facebook" with title "Our Facebook page" at URL "https://www.social.gov.uk"
    Then I should see the "Our Facebook page" social media site has been assigned to the worldwide organisation "Test Worldwide Organisation"

  Scenario Outline: Editing a social media account to a worldwide organisation
    Given a social media service "Facebook" exists
    When I draft a new worldwide organisation "Test Worldwide Organisation" assigned to world location "United Kingdom"
    And I edit the worldwide organisation "Test Worldwide Organisation" adding the social media service of "Facebook" with title "Our Facebook page" at URL "https://www.social.gov.uk"
    And I edit the worldwide organisation "Test Worldwide Organisation" changing the social media account with title "Our Facebook page" to "Our new Facebook page"
    Then I should see the "Our new Facebook page" social media site has been assigned to the worldwide organisation "Test Worldwide Organisation"

  Scenario Outline: Deleting a social media account assigned to a worldwide organisation
    Given a social media service "Facebook" exists
    When I draft a new worldwide organisation "Test Worldwide Organisation" assigned to world location "United Kingdom"
    And I edit the worldwide organisation "Test Worldwide Organisation" adding the social media service of "Facebook" with title "Our Facebook page" at URL "https://www.social.gov.uk"
    And I edit the worldwide organisation "Test Worldwide Organisation" deleting the social media account with title "Our Facebook page"
    Then I should see the worldwide organisation "Test Worldwide Organisation" has no social media accounts

  Scenario: Managing office information
    Given an editionable worldwide organisation "Test Worldwide Organisation"
    When I add an editionable worldwide organisation "Test office" office for the home page with address, phone number, and some services
    Then I should be able to remove all services from the editionable worldwide organisation "Test office" office

  Scenario: Choosing the main office for a worldwide organisation with multiple offices
    Given an editionable worldwide organisation "Test Worldwide Organisation" with offices "Head office" and "Branch office"
    When I choose "Branch office" to be the main office for the editionable worldwide organisation
    Then the "Branch office" should be marked as the main office for the editionable worldwide organisation
    When I choose "Head office" to be the main office for the editionable worldwide organisation
    Then the "Head office" should be marked as the main office for the editionable worldwide organisation

  Scenario: Deleting an office for a worldwide organisation
    Given an editionable worldwide organisation "Test Worldwide Organisation"
    When I delete the "Main office for Test Worldwide Organisation" office for the worldwide organisation
    Then I should see that the list of offices for the worldwide organisation is empty
    And The "Test Worldwide Organisation" worldwide organisation should have no offices

  @javascript
  Scenario: Reordering home page offices for a worldwide organisation
    Given An editionable worldwide organisation "Test Worldwide Organisation" with home page offices "Home page office 1" and "Home page office 2"
    When I visit the reorder offices page
    Then I should see that the list of offices are ordered "Home page office 1" then "Home page office 2"
    When I reorder the offices
    And I visit the reorder offices page
    Then I should see that the list of offices are ordered "Home page office 2" then "Home page office 1"

  Scenario: Adding a corporate information page to a worldwide organisation
    Given a published editionable worldwide organisation "Test Worldwide Organisation"
    When I add a "Terms of reference" corporate information page to the editionable worldwide organisation
    Then I should see the corporate information on the editionable worldwide organisation document page
    And I should see the corporate information page "Terms of reference" in the list of "draft" documents
    When I force-publish the "Terms of reference" corporate information page for the editionable worldwide organisation "Test Worldwide Organisation"
    Then I should see the corporate information on the editionable worldwide organisation document page
    And I should see the corporate information page "Terms of reference" in the list of "published" documents
    When I create a new draft of the "Terms of reference" corporate information page for the worldwide organisation "Test Worldwide Organisation"
    Then I should see the corporate information page "Terms of reference" in the list of "draft" documents

  Scenario: Deleting a corporate information page from a worldwide organisation
    Given an editionable worldwide organisation "Test Worldwide Organisation"
    When I add a "Terms of reference" corporate information page to the editionable worldwide organisation
    And I delete the draft "Terms of reference" corporate information page for the editionable worldwide organisation "Test Worldwide Organisation"
    Then I should not see the corporate information page "Terms of reference" in the list of "draft" documents

  Scenario: Deleting a draft worldwide organisation that has not been published
    Given an editionable worldwide organisation "Test Worldwide Organisation"
    When I add a "Terms of reference" corporate information page to the editionable worldwide organisation
    And I delete the draft "Test Worldwide Organisation" worldwide organisation
    Then I should not see the editionable worldwide organisation "Test Worldwide Organisation" in the list of "draft" documents
    And I should not see the corporate information page "Terms of reference" in the list of "draft" documents

  Scenario: Deleting a draft worldwide organisation that was previously published
    Given a published editionable worldwide organisation "Test Worldwide Organisation"
    When I create a new draft for the "Test Worldwide Organisation" editionable worldwide organisation
    When I add a "Terms of reference" corporate information page to the editionable worldwide organisation
    And I delete the draft "Test Worldwide Organisation" worldwide organisation
    And I visit the list of draft documents
    And I should see the corporate information page "Terms of reference" in the list of "draft" documents
