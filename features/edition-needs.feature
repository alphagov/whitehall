Feature: Managing needs on editions
  In order to edit the needs of a document
  An editor
  Should be able to go to the Edit needs page

  Scenario: Adding and removing needs
    Given a submitted publication "Extended goatee for the modern man" with a PDF attachment
    When I visit the list of documents awaiting review
    And I view the publication "Extended goatee for the modern man"
    And I start editing the needs from the publication page
    And I choose the first need in the dropdown
    Then I should see the first need in the list of associated needs
