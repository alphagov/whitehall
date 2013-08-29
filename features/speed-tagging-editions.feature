Feature: Speed tagging editions
  I want to be able to tag new editions (especially but not exclusively imported editions) using a slimmed down version of the edit screen.

  Specifically, the page:

  - should only present policies which are associated with the org of the doc being imported
    - and only present them once, even if they are associated with multiple orgs associated with the doc
  - should only present ministers which are associated with the org of the doc being imported
  - should present mandatory data elements for that document type. (i.e. speech type, publication subtype)
  - should include first published at fields for news articles and statistical data sets
  - should include opening and closing dates for consulations
  - should include delivered on date for speeches
  - should include publication date for publications

  Background:
    Given I am a writer

  Scenario: Speed tagging a newly imported publication
    When I go to speed tag a newly imported publication "Beard length statistics 2012"
    Then I should have to select the publication sub-type
    Then I should be able to set the first published date

  Scenario: Speed tagging only shows relevant ministers
    Given "Joe Bloggs" is the "Minister" for the "DCLG"
    And "Jane Smith" is the "Minister" for the "Treasury"
    When I go to speed tag a newly imported publication for "DCLG"
    And I should be able to tag the publication with "Joe Bloggs"
    And I should not be able to tag the publication with "Jane Smith"

  Scenario: Speed tagging only shows relevant policies in the checkbox list
    Given a draft policy "Local beards" for the organisation "DCLG"
    And a published policy "Beard taxes" for the organisation "Treasury"
    When I go to speed tag a newly imported publication for "DCLG"
    And I should be able to tag the publication with "Local beards"
    And I should not be able to tag the publication with "Beard taxes"

  Scenario: Speed tagging only shows a policy once
    Given a draft policy "Local beards" for the organisations "DCLG" and "Treasury"
    When I go to speed tag a newly imported publication for "DCLG" and "Treasury"
    Then I can only tag the publication with "Local beards" once

  Scenario: Speed taggings shows all the policies as a dropdown at the end of the list
    Given a published policy "Local beards" for the organisation "DCLG"
    Given a published policy "Beard taxes" for the organisation "Treasury"
    When I go to speed tag a newly imported publication for "DCLG"
    Then I can choose "Beard taxes" from an additional list of policies
    But I can't select "Local beards" from the additional list

  Scenario: Speed tagging shows speech required fields
    When I go to speed tag a newly imported speech "Written statement on Beards"
    Then I should have to select the speech type
    And I should have to select the deliverer of the speech
    And I should be able to set the delivered date of the speech

  Scenario: Speed tagging shows world locations when relevant
    Given a world location "Uganda" exists
    When I go to speed tag a newly imported speech "Speech about Uganda"
    Then I should be able to select the world location "Uganda"

  Scenario: Speed tagging news articles allows relevant appointments to be set
    Given "Jane Smith" is the "Chancellor" for the "HM Treasury"
    And "Joe Bloggs" used to be the "Chancellor" for the "HM Treasury"
    When I go to speed tag a newly imported news article "Beards are more costly this year" for "HM Treasury"
    Then I should be able to tag the news article with "Jane Smith"
    And I should not be able to tag the news article with "Joe Bloggs"

  Scenario: Speed tagging shows document series when relevant
    Given a document series "Beard statistics"
    When I go to speed tag a newly imported publication "Beard length statistics 2012"
    Then I should be able to select the document series "Beard statistics"

  Scenario: Speed tagging news articles allows first published at to be set
    When I go to speed tag a newly imported news article "Beards are more costly this year"
    Then I should be able to set the first published date

  Scenario: Speed tagging a consulation shows the required fields
    When I go to speed tag a newly imported consultation "Review of the Ministry of Beards 2012"
    Then I should be able to set the consultation dates

  Scenario: Speed tagging statistical data sets allows first published at to be set
    When I go to speed tag a newly imported statistical data set "Beard density survey 2012"
    Then I should be able to set the first published date
