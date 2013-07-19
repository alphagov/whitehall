Feature: Detailed guides

Scenario: Creating a new draft detailed guide
  Given I am a writer
  When I draft a new detailed guide "The finer points of moustache trimming"
  Then I should see the detailed guide "The finer points of moustache trimming" in the list of draft documents

Scenario: Creating a new draft detailed guide in multiple topics
  Given I am a writer
  Given two topics "Facial Hair" and "Hirsuteness" exist
  When I draft a new detailed guide "Outlaw Moustaches" in the "Facial Hair" and "Hirsuteness" topics
  Then I should see in the preview that "Outlaw Moustaches" should be in the "Facial Hair" and "Hirsuteness" topics

Scenario: Creating a new draft detailed guide related to other detailed guides
  Given I am a writer
  Given a submitted detailed guide "Deep Sea Diving" exists
  When I draft a new detailed guide "Plundering Treasure" related to the detailed guide "Deep Sea Diving"
  Then I should see in the preview that "Plundering Treasure" is related to the detailed guide "Deep Sea Diving"
  And I should see in the preview that "Deep Sea Diving" is related to the detailed guide "Plundering Treasure"

@javascript
Scenario: Adding multiple images
  Given I am a writer
  Given I start drafting a new detailed guide
  When I select an image for the detailed guide
  Then I should be able to select another image for the detailed guide

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

Scenario: Viewing a published detailed guide related to other guides
  Given a published detailed guide "Guide A" related to published detailed guides "Guide B" and "Guide C"
  When I visit the detailed guide "Guide A"
  Then I can see links to the related detailed guides "Guide B" and "Guide C"
