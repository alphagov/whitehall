Feature: Viewing detailed guides

Scenario: Viewing a published detailed guide related to other guides
  Given a published detailed guide "Guide A" related to published detailed guides "Guide B" and "Guide C"
  When I visit the detailed guide "Guide A"
  Then I can see links to the related detailed guides "Guide B" and "Guide C"
