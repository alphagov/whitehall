@design-system-only
Feature: Images tab on edit edition

  Background:
    Given I am a writer

  Scenario: Images tab is hidden by default
    And I start drafting a new publication "Standard Beard Lengths"
    When I am on the edit page for publication "Standard Beard Lengths"
    Then the page should not have an images tab

  Scenario: Accessing the images tab with correct permissions
    And I have the "Preview images update" permission
    And I start drafting a new publication "Standard Beard Lengths"
    When I am on the edit page for publication "Standard Beard Lengths"
    Then I can navigate to the images tab

  Scenario: Images are listed on the images tab
    And I have the "Preview images update" permission
    And a draft document with images exists
    When I visit the images tab of the document with images
    Then I should see a list with 2 images

  Scenario: Images can be deleted from the images tab
    And I have the "Preview images update" permission
    And a draft document with images exists
    When I visit the images tab of the document with images
    Then I should see a list with 2 images
    When I click to delete an image
    And I confirm the deletion
    Then I should see a successfully deleted banner
    And I should see a list with 1 image

  Scenario: Images details can be updated from the images tab
    And I have the "Preview images update" permission
    And a draft document with images exists
    When I visit the images tab of the document with images
    And I click to edit the details of an image
    And I update the image details and save
    Then I should see a updated banner
    Then I should see the updated image details

  Scenario: Lead image setting can be updated from the images tab
    And I have the "Preview images update" permission
    And a draft case study with images exists
    When I visit the images tab of the document with images
    And I click to hide the lead image
    Then I should see a button to show the lead image

  Scenario: Image uploaded with no cropping required
    And I have the "Preview images update" permission
    And I start drafting a new publication "Standard Beard Lengths"
    When I am on the edit page for publication "Standard Beard Lengths"
    And I navigate to the images tab
    And I upload a 960x640 image
    And I update the image details and save
    Then the publication "Standard Beard Lengths" should have 1 image attachment

  @javascript
  Scenario: Image uploaded with cropping required
    And I have the "Preview images update" permission
    And a draft document with images exists
    When I visit the images tab of the document with images
    Then I should see a list with 2 images
    When I upload a 960x960 image
    Then I am redirected to a page for image cropping
    When I click the "Save and continue" button on the crop page
    And I update the image details and save
    Then I should see a list with 3 image

  Scenario: Small image uploaded
    And I have the "Preview images update" permission
    And I start drafting a new publication "Standard Beard Lengths"
    When I am on the edit page for publication "Standard Beard Lengths"
    And I navigate to the images tab
    And I upload a 64x96 image
    Then I should get the error message "Image data file is too small. Select an image that is 960 pixels wide and 640 pixels tall"

  Scenario: No file uploaded
    And I have the "Preview images update" permission
    And I start drafting a new publication "Standard Beard Lengths"
    When I am on the edit page for publication "Standard Beard Lengths"
    And I navigate to the images tab
    And I click upload without attaching a file
    Then I should get the error message "Image data file can't be blank"

  Scenario: Uploading a file with duplicated filename
    And I have the "Preview images update" permission
    And I start drafting a new publication "Standard Beard Lengths"
    When I am on the edit page for publication "Standard Beard Lengths"
    And I navigate to the images tab
    And I upload a 960x640 image
    And I update the image details and save
    And I upload a 960x640 image
    Then I should get the error message "Image data file name is not unique. All your file names must be different. Do not use special characters to create another version of the same file name."


