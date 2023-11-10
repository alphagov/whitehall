Feature: Images tab on edit edition

  Background:
    Given I am a writer

  @javascript
  Scenario: Image uploaded with cropping required
    And a draft document with images exists
    When I visit the images tab of the document with images
    Then I should see a list with 2 images
    When I upload a 960x960 image
    Then I am redirected to a page for image cropping
    When I click the "Save and continue" button on the crop page
    And I update the image details and save
    Then I should see a list with 3 image

  @javascript
  Scenario: Uploading an oversized file with duplicated filename
    When a draft document with images exists
    And I visit the images tab of the document with images
    And I upload a 960x960 image
    And I am redirected to a page for image cropping
    And I click the "Save and continue" button on the crop page
    And I update the image details and save
    And I upload a 960x960 image
    Then I should get 1 error message
