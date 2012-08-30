Feature: Previewing unpublished editions

Scenario: Previewing an unpublished edition
  Given I am an editor
  And a draft publication "Beard Length Review" exists
  When I preview the publication "Beard Length Review"
  Then I should see the summary of the draft publication "Beard Length Review"
