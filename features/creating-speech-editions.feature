Feature: Creating speech editions

Scenario: Creating a new edition
  Given I am a writer
  And a published speech exists

  When I create a new edition of the published speech
  And I edit the new edition

  Then the published speech should remain unchanged