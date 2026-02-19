Feature: Images tab on edit edition

  Background:
    Given I am a writer

  Scenario: Images are listed on the images tab
    And a draft document with images exists
    When I visit the images tab of the document with images
    Then I should see a list with 2 images

  Scenario: Images can be deleted from the images tab
    And a draft document with images exists
    When I visit the images tab of the document with images
    Then I should see a list with 2 images
    When I click to delete an image
    And I confirm the deletion
    Then I should see a successfully deleted banner
    And I should see a list with 1 image

  Scenario: Images details can be updated from the images tab
    And a draft document with images exists
    When I visit the images tab of the document with images
    And I click to edit the details of an image
    And I update the image details and save
    Then I should see a updated banner
    Then I should see the updated image details

  Scenario: Lead image setting can be updated from the images tab
    And an organisation with a default news image exists
    And the organisation has a draft case study with images
    When I visit the images tab of the document with images
    Then I should see the organisations default news image
    When I click to hide the lead image
    Then I should see a button to select a custom lead image
    And I should see a button to choose to use the default image

  Scenario: User selects a new lead image
    And a draft case study with images with the captions "First image uploaded" and "Second image uploaded" exists
    When I visit the images tab of the document with images
    And I make the image with caption "First image uploaded" the lead image
    Then I can see that the image with caption "First image uploaded" is the lead image
    And I make the image with caption "Second image uploaded" the lead image
    Then I can see that the image with caption "Second image uploaded" is the lead image

Scenario: User uploads a header image
    And the configurable document types feature flag is enabled
    And I draft a new "Test configurable document type" configurable document titled "The history of GOV.UK"
    When I visit the images tab of the document "The history of GOV.UK"
    Then I should see a card associated with the header image usage
    When I click to add a header image
    And I upload a 960x960 header image
    And I update the image details and save
    Then I should see the header image is uploaded

  Scenario: User uploads multiple images for a usage
    Given the configurable document types feature flag is enabled
    And I draft a new "Test configurable document type" configurable document titled "The history of GOV.UK"
    When I visit the images tab of the document "The history of GOV.UK"
    When I upload multiple images including a 960x960 image
    Then I should see a list with 2 images