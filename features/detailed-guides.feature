Feature: Detailed guides

Scenario: Creating a new draft detailed guide
  Given I am a writer in the organisation "Department of Examples"
  When I draft a new detailed guide "The finer points of moustache trimming"
  Then I should see the detailed guide "The finer points of moustache trimming" in the list of draft documents

Scenario: Creating a new detailed guide with policies
  Given I am a writer in the organisation "Department of Examples"
  When I create a new detailed guide "Moustache trimming with policies" associated with "Policy 1"
  Then I should see the detailed guide "Moustache trimming with policies" associated with "Policy 1"

@javascript
Scenario: Adding multiple images
  Given I am a writer in the organisation "Department of Examples"
  Given I start drafting a new detailed guide
  When I select an image for the detailed guide
  Then I should be able to select another image for the detailed guide

Scenario: Publishing a submitted detailed guide
  Given I am an editor in the organisation "Department of Examples"
  Given two topics "Facial Hair" and "Hirsuteness" exist
  And a submitted detailed guide "Finer points of moustache trimming" exists in the "Hirsuteness" topic
  When I publish the detailed guide "Finer points of moustache trimming"
  Then I should see the detailed guide "Finer points of moustache trimming" in the list of published documents

Scenario: Viewing detailed guide publishing history
  Given I am an editor in the organisation "Department of Examples"
  Given a published detailed guide "Ban Beards" exists
  When I publish a new edition of the detailed guide "Ban Beards" with a change note "Exempted Santa Claus"
  And I publish a new edition of the detailed guide "Ban Beards" with a change note "Exempted Gimli son of Gloin"
