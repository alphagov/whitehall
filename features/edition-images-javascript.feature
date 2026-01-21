# For an unknown reason selenium driver based image-tests began to fail in the CI workflow when executed in Github
# Running the tests from a separate feature-file seems to fix the issue
Feature: Images tab on edit edition

  Background:
    Given I am a writer

  @javascript
  Scenario: Image uploaded with cropping required
    And a draft document with images exists
    When I visit the images tab of the document with images
    Then I should see a list with 2 images
    When I upload a 960x960 image
    Then I should see the image cropper in the following edit screen
    When I update the image details and save
    Then I should see a list with 3 images
    Then I should not see that the image requires cropping

  @javascript
  Scenario: Images uploaded with cropping required
    And a draft document with images exists
    When I visit the images tab of the document with images
    Then I should see a list with 2 images
    When I upload multiple images including a 960x960 image
    Then I should see a list with 4 images
    Then I should see that the image requires cropping
    When I click to edit the details of the image that needs to be cropped
    Then I should see the image cropper in the following edit screen
    When I update the image details and save
    Then I should see a list with 4 images
    Then I should not see that the image requires cropping 

  @javascript
  Scenario: Image uploaded with no cropping required
    And a draft publication "New Draft Publication" exists
    When I visit the images tab of the document "New Draft Publication"
    And I upload a 960x640 image
    Then I should not see the image cropper in the following edit screen
    When I update the image details and save
    Then I should see a list with 1 image      

  @javascript
  Scenario: Uploading a file with a duplicated filename
    When a draft document with images exists
    And I visit the images tab of the document with images
    And I upload a 960x960 image
    When I update the image details and save
    And I upload a 960x960 image
    Then I should get 1 error message
