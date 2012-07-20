Feature: Viewing specialist guides

@wip
Scenario: Viewing a published specialist guide related to other guides
  Given a published specialist guide "Guide A" related to published specialist guides "Guide B" and "Guide C"
  When I visit the specialist guide "Guide A"
  Then I can see links to the related specialist guides "Guide B" and "Guide C"
