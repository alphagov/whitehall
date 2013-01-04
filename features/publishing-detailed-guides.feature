Feature: Publishing detailed guides

Scenario: Publishing a submitted detailed guide
  Given I am an editor
  Given two topics "Facial Hair" and "Hirsuteness" exist
  And a submitted detailed guide "Finer points of moustache trimming" exists in the "Hirsuteness" topic
  When I publish the detailed guide "Finer points of moustache trimming"
  Then I should see the detailed guide "Finer points of moustache trimming" in the list of published documents
  And the detailed guide "Finer points of moustache trimming" should be visible to the public

Scenario: Publishing a submitted detailed guide to a mainstream category
  Given I am an editor
  Given a mainstream category "Finer points of yak shaving" exists
  And a submitted detailed guide "Yak shaving tools" exists in the "Finer points of yak shaving" mainstream category
  When I publish the detailed guide "Yak shaving tools"
  Then the detailed guide "Yak shaving tools" should be visible to the public in the mainstream category "Finer points of yak shaving"

Scenario: Viewing detailed guide publishing history
  Given I am an editor
  Given a published detailed guide "Ban Beards" exists
  When I publish a new edition of the detailed guide "Ban Beards" with a change note "Exempted Santa Claus"
  And I publish a new edition of the detailed guide "Ban Beards" with a change note "Exempted Gimli son of Gloin"
  Then the detailed guide "Ban Beards" should be visible to the public
  And the change notes should appear in the history for the detailed guide "Ban Beards" in reverse chronological order

