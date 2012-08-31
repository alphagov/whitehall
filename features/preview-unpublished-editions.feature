Feature: Previewing unpublished editions

@wip
Scenario: Unpublished editions can be previewed
  Given a draft publication "Beard Length Review" exists
  And I am an editor
  When I preview the publication "Beard Length Review"
  Then I should see the summary of the draft publication "Beard Length Review"
