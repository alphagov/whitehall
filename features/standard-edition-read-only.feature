Feature: Standard Editions - read-only mode

  Background:
    Given I am a writer
    And a published standard edition called "Published Edition" exists
    And the configurable document types feature flag is enabled

  Scenario: Viewing the document tab of the published edition
    When I view the "Document" tab
    Then the tab navigation is still visible
    And I see the "read-only view" message
    And the form is wrapped inside a disabled fieldset
    And there is no "Save" button

  Scenario: Viewing a dynamic tab of the published edition
    When I view the "Social media accounts" tab
    Then the tab navigation is still visible
    And I see the "read-only view" message
    And the form is wrapped inside a disabled fieldset
    And there is no "Save" button

  # HTML attachments aren't supported on StandardEdition
  # But are included here for completeness
  Scenario: Viewing the Attachments tab of the published edition
    When I view the "Attachments" tab
    Then the tab navigation is still visible
    And I see the "read-only view" message
    And there is no file upload form
    And there is no "Add new HTML attachment" link
    And there is no "Add new external attachment" link
    And there is no "Reorder attachments" link
    And there is no "Edit attachment" link
    And there is no "Delete attachment" link
    And there is a "View attachment" link next to the HTML attachment
    And there is a "View attachment" link next to the External attachment
    And there is a "View attachment" link next to the File attachment

  Scenario: Viewing a HTML attachment on the published edition
    When I view the "Attachments" tab
    And I click the "View attachment" link next to the HTML attachment
    Then there is a back button taking me to the "Attachments" tab
    And the form is wrapped inside a disabled fieldset
    And there is no "Save" button

  Scenario: Viewing a File attachment on the published edition
    When I view the "Attachments" tab
    And I click the "View attachment" link next to the File attachment
    Then there is a back button taking me to the "Attachments" tab
    And the form is wrapped inside a disabled fieldset
    And there is no "Save" button

  Scenario: Viewing a External attachment on the published edition
    When I view the "Attachments" tab
    And I click the "View attachment" link next to the External attachment
    Then there is a back button taking me to the "Attachments" tab
    And the form is wrapped inside a disabled fieldset
    And there is no "Save" button

  Scenario: Viewing the reorder attachments page on the published edition
    When I navigate to the reorder attachments page
    Then I can see the attachments
    And there is no "Update order" button
    And there is a back button taking me to the "Attachments" tab
    And the buttons on the form are hidden

  Scenario: Viewing the Images tab on the published edition
    When I view the "Images" tab
    Then there is no image upload form
    And I can see my uploaded lead image
    And I can see my uploaded embeddable image
    And there is no "Edit details" link
    And there is no "Delete image" link
    And there is no "Edit" link
    And there is no "Delete" link
    And there is a back button taking me to the document summary screen

  Scenario: Viewing the Features tab (and its sub-tabs)
    When I view the "Featured" tab
    Then I can see the currently featured items
    And there is no "Edit" link
    And there is no "Unfeature" link
    And there is no "Feature" link
    And there is no "Delete" link
    And there is no "Search" button
