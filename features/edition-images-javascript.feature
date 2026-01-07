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
    Then I should see a list with 3 images
    Then I should see that the image requires cropping
    When I click to edit the details of the image that needs to be cropped
    When I update the image details and save
    Then I should not see that the image requires cropping
