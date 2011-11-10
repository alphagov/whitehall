Feature: Creating policy editions
In order to revise a policy without affecting what the public see
A writer
Should be able to create a new edition of a published policy

Scenario: Creating a new edition
  Given I am a writer
  And a published policy "Ban beards" exists

  When I create a new edition of the published policy "Ban beards"
  And I edit the new edition

  Then the published policy "Ban beards" should remain unchanged