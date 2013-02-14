Feature: Viewing worldwide offices

Scenario: View priorities of a worldwide office
  Given the worldwide office "Embassy in Spain" exists
  And a published international priority "Oil field exploitation" exists relating to the worldwide office "Embassy in Spain"
  When I view the worldwide office page
  Then I should see the international priority "Oil field exploitation"
