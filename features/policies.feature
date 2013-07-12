Feature: Editing draft policies
In order to allow the public to view policies
A writer should be able to edit and save draft policies
A departmental editor should be able to publish policies
In order to obtain useful information about government
A member of the public Should be able to view policies

Background:
  Given I am a writer

Scenario: Creating a new draft policy
  When I draft a new policy "Outlaw Moustaches"
  Then I should see the policy "Outlaw Moustaches" in the list of draft documents

Scenario: Creating a new draft policy in multiple topics
  Given two topics "Facial Hair" and "Hirsuteness" exist
  When I draft a new policy "Outlaw Moustaches" in the "Facial Hair" and "Hirsuteness" topics
  Then I should see in the preview that "Outlaw Moustaches" should be in the "Facial Hair" and "Hirsuteness" topics

Scenario: Creating a new draft policy in multiple organisations
  Given two organisations "Department of Paperclips" and "Stationery Standards Authority" exist
  When I draft a new policy "Ban Tinfoil Paperclips" produced by the "Department of Paperclips" and "Stationery Standards Authority" organisations
  Then I should see in the preview that "Ban Tinfoil Paperclips" was produced by the "Department of Paperclips" and "Stationery Standards Authority" organisations

Scenario: Creating a new draft policy that's the responsibility of multiple ministers
  Given ministers exist:
    | Ministerial Role    | Person     |
    | Minister of Finance | John Smith |
    | Treasury Secretary  | Jane Doe   |
  When I draft a new policy "Pinch more pennies" associated with "John Smith" and "Jane Doe"
  Then I should see in the preview that "Pinch more pennies" is associated with "Minister of Finance" and "Treasury Secretary"

Scenario: Creating a new draft policy that applies to multiple nations
  When I draft a new policy "Outlaw Moustaches" that does not apply to the nations:
    | Scotland | Wales |
  Then I should see in the preview that "Outlaw Moustaches" does not apply to the nations:
    | Scotland | Wales |

Scenario: Creating a new policy related to multiple worldwide prioirites
  Given a published worldwide priority "Fish Exchange Programme" exists
  And a published worldwide priority "Supporting British Fish Abroad" exists
  When I draft a new policy "Fishy Business" relating it to the worldwide_priorities "Fish Exchange Programme" and "Supporting British Fish Abroad"
  Then I should see in the preview that "Fishy Business" should related to "Fish Exchange Programme" and "Supporting British Fish Abroad" worldwide priorities

Scenario: Adding a supporting page to a draft policy
  Given a draft policy "Outlaw Moustaches" exists
  When I add a supporting page "Handlebar Waxing" to the "Outlaw Moustaches" policy
  Then I should see in the preview that "Outlaw Moustaches" includes the "Handlebar Waxing" supporting page
  And I should see in the list of draft documents that "Outlaw Moustaches" has supporting page "Handlebar Waxing"

Scenario: Adding a supporting page with an attachment to a draft policy
  Given a draft policy "Outlaw Moustaches" exists
  When I add a supporting page "Handlebar Waxing" with an attachment to the "Outlaw Moustaches" policy
  And I should see that the "Outlaw Moustaches" policy's "Handlebar Waxing" supporting page has an attachment

Scenario: Removing a supporting page from a draft policy
  Given a draft policy "Bigger Brass" with supporting pages "Massive Trumpets" and "Giant Cornets"
  When I remove the supporting page "Massive Trumpets" from "Bigger Brass"
  Then I should see in the preview that the only supporting page for "Bigger Brass" is "Giant Cornets"

Scenario: Editing an existing draft policy
  Given a draft policy "Outlaw Moustaches" exists
  When I edit the policy "Outlaw Moustaches" changing the title to "Ban Moustaches"
  Then I should see the policy "Ban Moustaches" in the list of draft documents

Scenario: Editing an existing draft policy assigning multiple topics
  Given two topics "Facial Hair" and "Hirsuteness" exist
  And a draft policy "Outlaw Moustaches" exists in the "Facial Hair" topic
  When I edit the policy "Outlaw Moustaches" adding it to the "Hirsuteness" topic
  Then I should see in the preview that "Outlaw Moustaches" should be in the "Facial Hair" and "Hirsuteness" topics

Scenario: Editing an existing supporting page
  Given a supporting page "Handlebar Waxing" exists on a draft policy "Outlaw Moustaches"
  When I edit the supporting page "Handlebar Waxing" changing the title to "Waxing Dangers"
  Then I should see in the preview that "Outlaw Moustaches" includes the "Waxing Dangers" supporting page

Scenario: Trying to save a policy that has been changed by another user
  Given a draft policy "Outlaw Moustaches" exists
  And I start editing the policy "Outlaw Moustaches" changing the title to "Ban Moustaches"
  And another user edits the policy "Outlaw Moustaches" changing the title to "Ban Beards"
  When I save my changes to the policy
  Then I should see the conflict between the policy titles "Ban Moustaches" and "Ban Beards"
  When I edit the policy changing the title to "Ban Moustaches and Beards"
  Then I should see the policy "Ban Moustaches and Beards" in the list of draft documents

Scenario: Trying to save a supporting page that has been changed by another user
  Given a supporting page "Handlebar Waxing" exists on a draft policy "Outlaw Moustaches"
  And I start editing the supporting page "Handlebar Waxing" changing the title to "Waxing Dangers"
  And another user edits the supporting page "Handlebar Waxing" changing the title to "Something Else"
  When I save my changes to the supporting page
  Then I should see the conflict between the supporting page titles "Waxing Dangers" and "Something Else"
  When I edit the supporting page changing the title to "Waxing Dangers and Something Else"
  Then I should see in the preview that "Outlaw Moustaches" includes the "Waxing Dangers and Something Else" supporting page

Scenario: Submitting a draft policy to a second pair of eyes
  Given a draft policy "Outlaw Moustaches" exists
  When I submit the policy "Outlaw Moustaches"
  Then I should see the policy "Outlaw Moustaches" in the list of submitted documents

Scenario: Deleting a draft policy that has not been published
  Given a draft policy "Outlaw All Body Hair" exists
  When I delete the draft policy "Outlaw All Body Hair"
  Then I should not see the policy "Outlaw All Body Hair" in the list of draft documents

Scenario: Editing a draft policy that's been submitted to a second pair of eyes
  Given a submitted policy titled "The policy"
  And I am an editor
  When I edit the policy "The policy" changing the title to "The new policy"
  Then I should see the policy "The new policy" in the list of submitted documents

@not-quite-as-fake-search
Scenario: Publishing a submitted publication
  Given I am an editor
  And a submitted policy "Ban Beards" exists
  When I publish the policy "Ban Beards"
  Then my attempt to publish "Ban Beards" should succeed
  And I should see the policy "Ban Beards" in the list of published documents
  And the policy "Ban Beards" should be visible to the public
  And the writers who worked on the policy titled "Ban Beards" should be emailed about the publication

Scenario: Trying to publish a policy that has been changed by another user
  Given I am an editor
  And a submitted policy "Ban Beards" exists
  When I publish the policy "Ban Beards" but another user edits it while I am viewing it
  Then my attempt to publish "Ban Beards" should fail

Scenario: Maintain existing relationships
  Given I am an editor
  And a published news article "Government to reduce hirsuteness" with related published policies "Ban Beards" and "Unimportant"
  When I publish a new edition of the policy "Ban Beards" with the new title "Ban Facial Hair"
  And I visit the news article "Government to reduce hirsuteness"
  Then I can see links to the related published policies "Ban Facial Hair" and "Unimportant"

@not-quite-as-fake-search
Scenario: Publishing a first edition without a change note
  Given I am an editor
  And a submitted policy "Ban Beards" exists
  When I publish the policy "Ban Beards" without a change note
  Then my attempt to publish "Ban Beards" should succeed
  And I should see the policy "Ban Beards" in the list of published documents
  And the policy "Ban Beards" should be visible to the public

Scenario: Publishing a subsequent edition without a change note
  Given I am an editor
  And a published policy "Ban Beards" exists
  When I create a new edition of the published policy "Ban Beards"
  Then my attempt to save it should fail with error "Change note can't be blank"

Scenario: Publishing a subsequent edition as a minor edit
  Given I am an editor
  And a published policy "Ban Beards" exists
  When I publish a new edition of the policy "Ban Beards" as a minor change
  Then my attempt to publish "Ban Beards" should succeed

@not-quite-as-fake-search
Scenario: Publishing a subsequent edition with a change note
  Given I am an editor
  And a published policy "Ban Beards" exists
  When I publish a new edition of the policy "Ban Beards" with a change note "Exempted Santa Claus"
  Then my attempt to publish "Ban Beards" should succeed
  And I should see the policy "Ban Beards" in the list of published documents
  And the policy "Ban Beards" should be visible to the public
  And the change notes should appear in the history for the policy "Ban Beards" in reverse chronological order

Scenario: Viewing a policy that's been submitted for review
  Given "Ben Beardson" submitted "Legalise beards" with body "Beards for everyone!"
  When I visit the list of documents awaiting review
  And I view the policy "Legalise beards"
  And I should see that "Beards for everyone!" is the policy body

@not-quite-as-fake-search
Scenario: Viewing policy publishing history
  Given I am an editor
  And a published policy "Ban Beards" exists
  When I publish a new edition of the policy "Ban Beards" with a change note "Exempted Santa Claus"
  And I publish a new edition of the policy "Ban Beards" with a change note "Exempted Gimli son of Gloin"
  Then the policy "Ban Beards" should be visible to the public
  And the change notes should appear in the history for the policy "Ban Beards" in reverse chronological order

Scenario: Viewing a policy that appears in multiple topics
  Given a published policy "Policy" that appears in the "Education" and "Work and pensions" topics
  When I visit the policy "Policy"
  Then I should see links to the "Education" and "Work and pensions" topics

Scenario: Viewing a policy that has multiple responsible ministers
  Given a published policy "Policy" that's the responsibility of:
    | Ministerial Role  | Person          |
    | Attorney General  | Colonel Mustard |
    | Solicitor General | Professor Plum  |
  When I visit the policy "Policy"
  Then I should see that those responsible for the policy are:
    | Ministerial Role  | Person          |
    | Attorney General  | Colonel Mustard |
    | Solicitor General | Professor Plum  |

Scenario: Viewing a policy that is applicable to certain nations
  Given a published policy "Haggis for every meal" that does not apply to the nations:
    | Northern Ireland | Wales |
  When I visit the policy "Haggis for every meal"
  Then I should see that the policy only applies to:
    | England | Scotland |

Scenario: Viewing the activity around a policy
  Given a published policy "What Makes A Beard" exists
  And a published publication "Standard Beard Lengths" related to the policy "What Makes A Beard"
  And a published consultation "Measuring Beard Length" related to the policy "What Makes A Beard"
  And a published news article "Beards Give You Cancer" related to the policy "What Makes A Beard"
  And a published speech "My Kingdom For A Beard" related to the policy "What Makes A Beard"
  When I visit the activity of the published policy "What Makes A Beard"
  Then I can see links to the recently changed document "Standard Beard Lengths"
  And I can see links to the recently changed document "Measuring Beard Length"
  And I can see links to the recently changed document "Beards Give You Cancer"
  And I can see links to the recently changed document "My Kingdom For A Beard"
