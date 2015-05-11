Feature: Featured topics and policies for an org
  As an interested citizen
  I would like know the priorities of the governments executive offices
  So that I can be informed

  ~~

  This would appear under the heading "Featured topics and policies" on the executive office page

  Admin can:

  * enter a summary text (plain text, respecting newlines)
  * select an ordered list of topics, policies and topical events.

  DPM requested the extra ability to put a link to 'see all our policies' which I haven't visualised in the mock-ups. I imagine it
  sitting just underneath the ordered list of featured items.

  Background:
    Given I am a GDS editor
    And the executive office "Office of the Beard-Shaper General" exists

  Scenario: I can feature topics and policies for an org and it retains my ordering when they are displayed
    When I write some copy to describe the featured topics and policies for the executive office "Office of the Beard-Shaper General"
    And I feature some topics and policies for the executive office in a specific order
    Then I see my copy on the executive office page
    And the featured topics and policies are in my specified order
    And I am invited to click through to see all the policies the executive office is involved with

  Scenario: I can remove things from the list of featured topics and policies for an org and it no longer displays them
    Given there are some topics and policies featured for the executive office "Office of the Beard-Shaper General"
    When I remove some items from the featured topics and policies list for the executive office
    Then the removed items are no longer displayed on the executive office page
