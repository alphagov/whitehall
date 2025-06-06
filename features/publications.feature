Feature: Publications
  In order to allow the public to view publications
  A writer and editor
  Should be able to draft and publish publications

  Background:
    Given I am a writer

  Scenario: Creating a new draft publication
    When I draft a new publication "Standard Beard Lengths"
    Then I should see the publication "Standard Beard Lengths" in the list of draft documents

  Scenario: Submitting a draft publication to a second pair of eyes
    Given a draft publication "Standard Beard Lengths" exists
    When I submit the publication "Standard Beard Lengths"
    Then I should see the publication "Standard Beard Lengths" in the list of submitted documents

  Scenario: Publishing an edition I submitted is forbidden
    Given I am an editor
    And there is a user called "Beardy"
    And "Beardy" drafts a new publication "Britain's Hairiest Ministers"
    When I submit the publication "Britain's Hairiest Ministers"
    Then I should not be able to publish the publication "Britain's Hairiest Ministers"

  @not-quite-as-fake-search
  Scenario: Publishing an edition I created but did not submit
    Given I am an editor
    And there is a user called "Beardy"
    And I draft a new publication "Britain's Hairiest Ministers"
    When "Beardy" submits the publication "Britain's Hairiest Ministers"
    And I publish the publication "Britain's Hairiest Ministers"
    Then I should see the publication "Britain's Hairiest Ministers" in the list of published documents

  @disable-sidekiq-test-mode
  Scenario: Viewing a publication that's been submitted for review with a PDF attachment
    Given a submitted publication "Legalise beards" with a PDF attachment
    And I am an editor
    When I visit the list of documents awaiting review
    And I view the publication "Legalise beards"
    And I should see a link to the PDF attachment
