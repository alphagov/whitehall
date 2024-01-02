Feature: Editionable worldwide organisations
  Background:
    Given I am a writer
    And The editionable worldwide organisations feature flag is enabled
    And a world location "United Kingdom" exists

  Scenario Outline: Creating a new draft worldwide organisation
    When I draft a new worldwide organisation "Test Worldwide Organisation" assigned to world location "United Kingdom"
    Then the worldwide organisation "Test Worldwide Organisation" should have been created
    And I should see it has been assigned to the "United Kingdom" world location
    And I should see the editionable worldwide organisation "Test Worldwide Organisation" in the list of draft documents

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
