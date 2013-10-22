Feature: Managing attachments on editions


  Scenario: Replacing data on an attachment
    Given I am an editor
    And a published publication "Standard Beard Lengths" with a PDF attachment
    And the attachment has been virus-checked
    When I replace the data file of the attachment in a new draft of the publication
    And the attachment has been virus-checked
    Then the new data file should not be public
    When I published the draft edition
    And I log out
    Then the new data file should be public
    And the old data file should redirect to the new data file
