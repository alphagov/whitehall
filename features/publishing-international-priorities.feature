Feature: Publishing international priorities

Scenario: Publishing a submitted international priority
  Given I am an editor
  And a submitted international priority "Military officer exchange" exists
  When I publish the international priority "Military officer exchange"
  Then I should see the international priority "Military officer exchange" in the list of published documents
  And the international priority "Military officer exchange" should be visible to the public