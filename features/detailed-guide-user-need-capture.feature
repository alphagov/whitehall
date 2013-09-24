Feature: Detailed guide user-need capture
  As a GDS editor,
  I want writers to be forced to specify a user need for new/newly editioned detailed guides
  So that they are encouraged to publish only task-oriented, user-need focussed guidance for practitioners in the detailed guides format

Scenario: New guides cannot be created without one or more user needs
  Given I am a writer in the organisation "Department of Examples"
  When I start drafting a new detailed guide
  Then there should be 0 detailed guide editions
  When I try to save the detailed guide with the user need: as an "example user" I need "some functionality" so that I can "get something done"
  Then there should be 1 detailed guide edition

Scenario: Existing guides cannot have new editions without one or more user needs
  Given I am a writer in the organisation "Department of Examples"
  And a published detailed guide "Example Detailed Guide" exists
  Then there should be 1 detailed guide edition
  When I start drafting a new edition for the detailed guide "Example Detailed Guide"
  And I try to save the detailed guide with the user need: as an "example user" I need "some functionality" so that I can "get something done"
  Then there should be 2 detailed guide editions
