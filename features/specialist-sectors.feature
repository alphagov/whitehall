Feature: Tagging content with specialist sectors
  In order to make my content available to users with specialist needs
  As a departmental content editor
  I want to be able to tag my content to one or more specialist sectors

  Scenario: writer can add tag documents with specialist sectors
    Given I am a writer
      And there are some specialist sectors
    When I start editing a draft document
    Then I can tag it to some specialist sectors
