Feature: Publishing specialist guides

Scenario: Publishing a submitted specialist guide
  Given I am an editor
  Given two topics "Facial Hair" and "Hirsuteness" exist
  And a submitted specialist guide "Finer points of moustache trimming" exists in the "Hirsuteness" topic
  When I publish the specialist guide "Finer points of moustache trimming"
  Then I should see the specialist guide "Finer points of moustache trimming" in the list of published documents
  And the specialist guide "Finer points of moustache trimming" should be visible to the public