Feature: Administering world location news information
  Background:
    Given I am a GDS admin
    And a world location news exists

  Scenario: Viewing the list presents no world location news message, when no news exists
    Given no world locations exist
    When I visit the world location news index page
    Then I should see the "No active world location news" message
    When I click the Inactive tab
    Then I should see the "No inactive world location news" message

  Scenario: Reordering currently featured documents
    Given the world location has a feature list with 2 featured documents
    When I visit the world location news page
    And I set the order of the featured documents to:
      | title      | order |
      | Document 2 | 0     |
      | Document 1 | 1     |
    Then the featured documents should be in the following order:
      | title      |
      | Document 2 |
      | Document 1 |

    Scenario: Unfeaturing a document
      Given the world location has a feature list with 1 featured document
      When I visit the world location news page
      And I unfeature the document
      Then I see that I have no featured documents

    Scenario: Featuring a document
      Given there is a published document with the title "Featured document"
      When I visit the world location news page
      And filter documents by all organisations
      And I feature "Featured document"
      Then I see that "Featured document" has been featured

    Scenario: Searching for a non-English document to feature on a non-English world location news
      Given a world location news exists and has a Spanish translation
      And there is a published document, with a Spanish translation, tagged to the world location
      When I visit the world location news page
      And select the "Features (Español)" tab
      And select the "Documents" child tab
      And search for "Documento destacado"
      Then I should be on the Spanish search results page
      And I should see "Featured document" in the document list

    Scenario: Featuring a topical event
      Given there is an active topical event with the name "Featured topical event"
      When I visit the world location news page
      And I feature "Featured topical event"
      Then I see that "Featured topical event" has been featured

    Scenario: Featuring a non-GOV.UK link
      Given the world location has an offsite link with the title "Featured link"
      When I visit the world location news page
      And I feature "Featured link"
      Then I see that "Featured link" has been featured

    Scenario: Creating a non-GOV.UK link
      When I visit the world location news page
      And I create a new a non-GOV.UK link with the title "Featured link"
      Then I can see the non-GOV.UK link with the title "Featured link"

    Scenario: Editing a non-GOV.UK link
      Given the world location has an offsite link with the title "Featured link"
      When I visit the world location news page
      And I update the title of a featured link from "Featured link" to "New title"
      Then I can see the non-GOV.UK link with the title "New title"

    Scenario: Deleting a non-GOV.UK link
      Given the world location has an offsite link with the title "Featured link"
      When I visit the world location news page
      And I delete "Featured link"
      Then I can see that "Featured link" has been deleted
