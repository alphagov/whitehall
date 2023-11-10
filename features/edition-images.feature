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
    And a draft case study with images with the alt text "First image uploaded" and "Second image uploaded" exists
    When I visit the images tab of the document with images
    And I make the image with alt text "First image uploaded" the lead image
    Then I can see that the image with alt text "First image uploaded" is the lead image
    And I make the image with alt text "Second image uploaded" the lead image
    Then I can see that the image with alt text "Second image uploaded" is the lead image

  Scenario: Image uploaded with no cropping required
    And I start drafting a new publication "Standard Beard Lengths"
    When I visit the images tab of the document "Standard Beard Lengths"
    And I upload a 960x640 image
    And I update the image details and save
    Then I should see a list with 1 image

  Scenario: No file uploaded
    And I start drafting a new publication "Standard Beard Lengths"
    When I visit the images tab of the document "Standard Beard Lengths"
    And I click upload without attaching a file
    Then I should get the error message "Image data file cannot be uploaded. Choose a valid JPEG, PNG, SVG or GIF."
