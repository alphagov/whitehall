Feature: Publishing worldwide priorities

Scenario: Publishing a submitted worldwide priority
  Given I am a GDS editor
  And a submitted worldwide priority "Military officer exchange" exists
  When I publish the worldwide priority "Military officer exchange"
  Then I should see the worldwide priority "Military officer exchange" in the list of published documents
  And the worldwide priority "Military officer exchange" should be visible to the public
