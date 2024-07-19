Feature: Editionable worldwide organisations
  Background:
    Given I am a writer
    And The editionable worldwide organisations feature flag is enabled
    And a world location "United Kingdom" exists

  Scenario: Creating a new draft worldwide organisation
    When I draft a new worldwide organisation "Test Worldwide Organisation" assigned to world location "United Kingdom"
    Then the worldwide organisation "Test Worldwide Organisation" should have been created
    And I should see it has been assigned to the "United Kingdom" world location
    When I select the "Worldwide organisations" edition filter
    Then I should see the editionable worldwide organisation "Test Worldwide Organisation" in the list of draft documents

  Scenario: Unpublishing a published worldwide organisation
    Given a published editionable worldwide organisation "Test Worldwide Organisation"
    When I unpublish the document and ask for a redirect to "https://www.test.gov.uk/example"
    Then the unpublishing should redirect to "https://www.test.gov.uk/example"

  Scenario: Withdrawing a published worldwide organisation
    Given a published editionable worldwide organisation "Test Worldwide Organisation"
    When I withdraw the worldwide organisation "Test Worldwide Organisation" with the explanation "Closed for business"
    Then there should be an unpublishing explanation of "Closed for business" and a reason of "No longer current government policy/activity"
    And the withdrawal date should be today

  Scenario: Adding a translation to an existing worldwide organisation
    When I draft a new worldwide organisation "Test Worldwide Organisation" assigned to world location "United Kingdom"
    And I add a Welsh translation of the worldwide organisation "Test Worldwide Organisation" named "Translated Name"
    Then I should see the Welsh translated title "Translated Name" for the "Test Worldwide Organisation" worldwide organisation

  Scenario: Removing a translation to an existing worldwide organisation
    Given an editionable worldwide organisation in draft with a translation in French
    And I add an associated office, also with a translation in French
    When I remove the French translation from the main document
    Then I should see the main document translation is gone
    And I visit the "Offices" tab
    Then I should see that the translated office is gone

  Scenario: Adding a translation to an existing worldwide office
    Given an editionable worldwide organisation in draft with a translation in French
    When I visit the "Offices" tab
    And I add a new translation with a title of "French Title"
    Then I should see the "Translated" subheading in the "Offices" tab with my new translation

  Scenario: Assigning a role to a worldwide organisation
    Given a role "Prime Minister" exists
    When I draft a new worldwide organisation "Test Worldwide Organisation" assigned to world location "United Kingdom"
    And I edit the worldwide organisation "Test Worldwide Organisation" adding the role of "Prime Minister"
    Then I should see the "Prime Minister" role has been assigned to the worldwide organisation "Test Worldwide Organisation"

  Scenario: Adding a social media account to a worldwide organisation
    Given a social media service "Facebook" exists
    When I draft a new worldwide organisation "Test Worldwide Organisation" assigned to world location "United Kingdom"
    And I edit the worldwide organisation "Test Worldwide Organisation" adding the social media service of "Facebook" with title "Our Facebook page" at URL "https://www.social.gov.uk"
    Then I should see the "Our Facebook page" social media site has been assigned to the worldwide organisation "Test Worldwide Organisation"

  Scenario: Editing a social media account to a worldwide organisation
    Given a social media service "Facebook" exists
    When I draft a new worldwide organisation "Test Worldwide Organisation" assigned to world location "United Kingdom"
    And I edit the worldwide organisation "Test Worldwide Organisation" adding the social media service of "Facebook" with title "Our Facebook page" at URL "https://www.social.gov.uk"
    And I edit the worldwide organisation "Test Worldwide Organisation" changing the social media account with title "Our Facebook page" to "Our new Facebook page"
    Then I should see the "Our new Facebook page" social media site has been assigned to the worldwide organisation "Test Worldwide Organisation"

  Scenario: Deleting a social media account assigned to a worldwide organisation
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

  Scenario: Adding a page to a worldwide organisation
    Given an editionable worldwide organisation "Test Worldwide Organisation"
    When I visit the pages tab for the worldwide organisation
    Then I should see that the list of pages for the worldwide organisation is empty
    When I click the link to create a new page
    And I correctly fill out the worldwide organisation page fields for a "Personal information charter" with:
      | Summary | Some summary |
      | Body (required) | Some body |
    Then I should see the "Personal information charter" page on the list of pages with the details:
      | Summary | Some summary |
      | Body | Some body |

  Scenario: Editing an existing worldwide organisation page
    Given an editionable worldwide organisation "Test Worldwide Organisation" with a "Personal information charter" page
    When I visit the pages tab for the worldwide organisation
    Then I should see the "Personal information charter" page on the list of pages with the details:
      | Summary | Some summary |
      | Body | Some body |
    When I click the "Edit" link for the "Personal information charter" page
    And I correctly fill out the worldwide organisation page fields for a "Personal information charter" with:
      | Summary | Some updated summary |
      | Body (required) | Some updated body |
    Then I should see the "Personal information charter" page on the list of pages with the details:
      | Summary | Some updated summary |
      | Body | Some updated body |

  Scenario: Deleting a worldwide organisation page
    Given an editionable worldwide organisation "Test Worldwide Organisation" with a "Personal information charter" page
    When I visit the pages tab for the worldwide organisation
    Then I should see the "Personal information charter" page on the list of pages with the details:
      | Summary | Some summary |
      | Body | Some body |
    When I click the "Delete" link for the "Personal information charter" page
    And I submit the confirmation form to delete the "Personal information charter" page
    And I visit the pages tab for the worldwide organisation
    Then I should see that the list of pages for the worldwide organisation is empty

  Scenario: Managing attachments for a worldwide organisation page
    Given an editionable worldwide organisation "Test Worldwide Organisation" with a "Personal information charter" page
    When I visit the pages tab for the worldwide organisation
    And I click the "Edit" link for the "Personal information charter" page
    And I click the Attachments tab
    And I upload a file attachment with the title "Beard Length Statistics 2014" and the file "dft_statistical_data_set_sample.csv"
    Then The "Beard Length Statistics 2014" attachment should have uploaded successfully

  Scenario: Adding a translation to an existing worldwide organisation page
    Given an editionable worldwide organisation "Test Worldwide Organisation" with a "Personal information charter" page and a translation in French
    When I visit the "Pages" tab
    And I add a new page translation with a body of "French Body"
    Then I should see the "Translated" subheading in the "Offices" tab with my new translation

  Scenario: Removing a translation to an existing worldwide organisation with pages
    Given an editionable worldwide organisation "Test Worldwide Organisation" with a "Personal information charter" page and a translation in French
    When I visit the "Pages" tab
    And I add a new page translation with a body of "French Body"
    When I remove the French translation from the main document
    Then I should see the main document translation is gone
    And I visit the "Pages" tab
    Then I should see that the translated page with body "French Body" is gone

  Scenario: Viewing audit history for the worldwide organisation and associated pages
    Given a published editionable worldwide organisation "Test Worldwide Organisation" with a "Personal information charter" page
    When I create a new edition of the "Test Worldwide Organisation" worldwide organisation
    And I visit the pages tab for the worldwide organisation
    And I click the "Edit" link for the "Personal information charter" page
    And I correctly fill out the worldwide organisation page fields for a "Personal information charter" with:
      | Summary | Some updated summary |
      | Body (required) | Some updated body |
    And I click the link to create a new page
    And I correctly fill out the worldwide organisation page fields for a "Complaints procedure" with:
      | Summary | An interesting summary |
      | Body (required) | An interesting body |
    Then The audit history for the pages should be displayed on the document history page with:
      | Personal information charter | Some summary | Some updated summary | Some body | Some updated body |
      | Complaints procedure | | An interesting summary | | An interesting body |

  @javascript
  Scenario: Reordering home page offices for a worldwide organisation
    Given An editionable worldwide organisation "Test Worldwide Organisation" with home page offices "Home page office 1" and "Home page office 2"
    When I visit the reorder offices page
    Then I should see that the list of offices are ordered "Home page office 1" then "Home page office 2"
    When I reorder the offices
    And I visit the reorder offices page
    Then I should see that the list of offices are ordered "Home page office 2" then "Home page office 1"
