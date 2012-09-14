Feature: Publishing specialist guides

Scenario: Publishing a submitted specialist guide
  Given I am an editor
  Given two topics "Facial Hair" and "Hirsuteness" exist
  And a submitted specialist guide "Finer points of moustache trimming" exists in the "Hirsuteness" topic
  When I publish the specialist guide "Finer points of moustache trimming"
  Then I should see the specialist guide "Finer points of moustache trimming" in the list of published documents
  And the specialist guide "Finer points of moustache trimming" should be visible to the public

Scenario: Publishing a submitted specialist guide to a mainstream category
  Given I am an editor
  Given a mainstream category "Finer points of yak shaving" exists
  And a submitted specialist guide "Yak shaving tools" exists in the "Finer points of yak shaving" mainstream category
  When I publish the specialist guide "Yak shaving tools"
  Then the specialist guide "Yak shaving tools" should be visible to the public in the mainstream category "Finer points of yak shaving"
