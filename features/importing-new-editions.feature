@import
Feature: Importing new editions
  We want to be able to import editions into our database which don't have all
  the data filled in. The idea is to enable editors to 'speed tag' them with
  all the associations they need, and send them directly to draft state.

  - Can specify the Organisation that is being imported on the import page
  - When importing:
    - The state of the new editions is set to imported
    - Depending on the main document type, the publication sub type and the speech type default to ImportedAwaitingType if the data field is unfilled
    - The organisation is defaulted to the selected organisation if not filled in. If filled in and valid, we use that organisation in preference. If the field is filled in and unrecognised then the import will fail. If the column is missing we default all rows to the selected organisation.
    - The speech "delivered by" field is left unfilled if not filled in
    - Unrecognised non-blank "tag" fields will cause an import failure
  - The following validation differences from draft editions apply to imported editions:
    - The publication sub type can be ImportedAwaitingType for publications
    - "Delivered by" is allowed to be blank for speeches
    - Speech type can be ImportedAwaitingType for speeches
  - The normal validation rules apply when converting this into draft - ImportedAwaitingType is not a valid type for non-imported editions
  - The "convert to draft" button will give a descriptive error if the above validation exceptions for imported editions haven't been corrected

  More detail on how we deal with individual fields:
  ---

  Terms:

  - column required: should fail csv upload without the column
  - required: should fail row import without it, implies column required
  - unique: should fail csv upload if any duplicates of this field in the file, implies required
  - optional: import if available, leave blank if not
  - default: import if available, set to a default if not

  All types:

  - old_url: column required + data unique
  - title: required
  - summary: optional
  - body: required
  - body_1..9: optional - allows long bodies to be split across multiple columns. body + body_1..9 are concatinated to form the complete body
  - organisation: required, ideally default blank to SELECTED, reject anything that is non-blank that can't be found

  Publications:

  - publication_date: column required, data optional (required before draft)
  - publication_type: required, ideally default blank to ImportedAwaitingType, reject anything non-blank that can't be found
  - policy_1..4: 1 column required, data optional
  - document_collection_1: column required, data optional
  - attachment_1..n_*: 1 column required, data required (should stay as is)
  - json_attachments: optional, leave as is
  - country_1..4: 1 column required, data optional
  - html_title: optional
  - html_body: optional
  - html_body_1..50: optional, allows long html bodies to be split across multiple columns. html_body + html_body_1..50 are concatinated to form the complete html body

  Consultations:

  - opening_at: required
  - closing_at: required
  - response_date: optional
  - response_summary: optional
  - response_attachments_1..n_*: 1 column required, optional (should stay as is)

  News:

  - first_published: column required, data optional (required before draft)
  - news_article_type: required, ideally default blank to ImportedAwaitingType, reject anything non-blank that can't be found
  - policy_1..4: 1 column required, data optional
  - minister_1..2: optional
  - country_1..4: 1 column required, data optional
  - attachment_(0..Row::ATTACHMENT_LIMIT)_url: optional
  - attachment_(0..Row::ATTACHMENT_LIMIT)_title: optional
  - json_attachments: optional (allows attachments to be supplied as a json array)

  Speeches:

  - speech_type: required, ideally default blank to ImportedAwaitingType, reject anything non-blank that can't be found
  - delivered_by: required, ideally default blank, reject anything non-black that can't be found
  - delivered_on: column required, data optional (required before draft)
  - event_and_location: optional
  - country_1..4: 1 column required, data optional

  StatisticalDataSets:

  - document_collection_1: column required, data optional

  FatalityNotices:

  - field_of_operation: required

  DetailedGuides:

  - topic_1..4: 1 column required, data optional
  - document_collection_1..4: 1 column required, data optional
  - detailed_guidance_category_1..4: 1 column required, data optional
  - related_detailed_guidance_1..4: 1 column required, data optional
  - related_mainstream_content_url_1..2: 1 column required, data optional
  - related_mainstream_content_title_1..2: 1 column required, data optional
  - first_published: optional
  - attachment_(0..Row::ATTACHMENT_LIMIT)_url: optional
  - attachment_(0..Row::ATTACHMENT_LIMIT)_title: optional
  - json_attachments: optional (allows attachments to be supplied as a json array)

  CaseStudies:

  - policy_1..4: 1 column required, data optional
  - document_collection_1..4: 1 column required, data optional
  - first_published: column required, data optional (required before draft)

  Background:
    Given I am an importer

  Scenario: Importing publications with unrecognised types will be rejected
    When I import the following data as CSV as "Publication" for "Department for Transport":
      """
      old_url,title,summary,body,organisation,policy_1,publication_type,document_collection_1,publication_date,order_url,price,isbn,urn,command_paper_number,ignore_1,attachment_1_url,attachment_1_title,country_1
      http://example.com/1,title,summary,body,weird organisation,,weird type,,14-Dec-2011,,,,,,,,,
      """
    Then the import should fail with errors about organisation and sub type and no editions are created

  Scenario: Importing publication with organisation already set in the data
    Given the organisation "Foreign Commonwealth Office" exists
    When I import the following data as CSV as "Publication" for "Department for Transport":
      """
      old_url,title,summary,body,organisation,policy_1,publication_type,document_collection_1,publication_date,order_url,price,isbn,urn,command_paper_number,ignore_1,attachment_1_url,attachment_1_title,country_1
      http://example.com/1,title,summary,body,foreign-commonwealth-office,,,,14-Dec-2011,,,,,,,,,
      """
    Then the import succeeds, creating 1 imported publication for "Foreign Commonwealth Office" with "imported-awaiting-type" publication type

  Scenario: Attempt to import a publication with unrecognised policy slug is rejected
    Given the organisation "Foreign Commonwealth Office" exists
    When I import the following data as CSV as "Publication" for "Department for Transport":
      """
      old_url,title,summary,body,organisation,policy_1,publication_type,document_collection_1,publication_date,order_url,price,isbn,urn,command_paper_number,ignore_1,attachment_1_url,attachment_1_title,country_1
      http://example.com/1,title,summary,body,foreign-commonwealth-office,non-existent-policy,,,14-Dec-2011,,,,,,,,,
      """
    Then the import should fail with errors about an unrecognised policy

  Scenario: Importing publications sets imported state, ImportedAwaitingType type and default organisation, to be filled in later
    Given a topic with the slug "my-topic" exists
    When I import the following data as CSV as "Publication" for "Department for Transport":
      """
      old_url,title,summary,body,organisation,policy_1,publication_type,document_collection_1,publication_date,order_url,price,isbn,urn,command_paper_number,ignore_1,attachment_1_url,attachment_1_title,country_1,topic_1
      http://example.com/1,title,summary,body,,,,,14-Dec-2011,,,,,,,,,,my-topic
      """
    Then the import succeeds, creating 1 imported publication for "Department for Transport" with "imported-awaiting-type" publication type
    And I can't make the imported publication into a draft edition yet
    When I set the imported publication's type to "Policy paper"
    Then I can make the imported publication into a draft edition

  Scenario: Importing publications with blank publication dates allows them to be filled in later
    Given a topic with the slug "my-topic" exists
    When I import the following data as CSV as "Publication" for "Department for Transport":
      """
      old_url,title,summary,body,organisation,policy_1,publication_type,document_collection_1,publication_date,order_url,price,isbn,urn,command_paper_number,ignore_1,attachment_1_url,attachment_1_title,country_1,topic_1
      http://example.com/1,title,summary,body,department-for-transport,,policy-papers,,,,,,,,,,,,my-topic
      """
    Then the import succeeds, creating 1 imported publication for "Department for Transport" with no publication date
    And I can't make the imported publication into a draft edition yet
    When I set the imported publication's publication date to "14-Dec-2011"
    Then I can make the imported publication into a draft edition

  Scenario: Importing publications with an html attachment
    When I import the following data as CSV as "Publication" for "Department for Transport":
      """
      old_url,title,summary,body,organisation,policy_1,publication_type,document_collection_1,publication_date,order_url,price,isbn,urn,command_paper_number,ignore_1,attachment_1_url,attachment_1_title,country_1,html_title,html_body,html_body_1
      http://example.com/1,title,summary,body,department-for-transport,,policy-papers,,,,,,,,,,,,HTML attachment title,Body part one, plus body part two
      """
    Then the import succeeds, creating 1 imported publication for "Department for Transport"
    And the imported publication has an html attachment with the title "HTML attachment title" and body "Body part one plus body part two"

  Scenario: Importing news article sets imported state, ImportedAwaitingType type and default organisation, to be filled in later
    Given a topic with the slug "my-topic" exists
    When I import the following data as CSV as "News article" for "Department for Transport":
      """
      old_url,title,summary,body,organisation,policy_1,minister_1,first_published,country_1,news_article_type,topic_1
      http://example.com/1,title,summary,body,,,,14-Dec-2011,,,my-topic
      """
    Then the import succeeds, creating 1 imported news article for "Department for Transport" with "imported-awaiting-type" news article type
    And I can't make the imported news article into a draft edition yet
    When I set the imported news article's type to "Government response"
    Then I can make the imported news article into a draft edition

  Scenario: Importing news article with blank first published allows them to be filled in later
    Given a topic with the slug "my-topic" exists
    When I import the following data as CSV as "News article" for "Department for Transport":
      """
      old_url,title,summary,body,organisation,policy_1,minister_1,first_published,country_1,news_article_type,topic_1
      http://example.com/1,title,summary,body,department-for-transport,,,,,news-stories,my-topic
      """
    Then the import succeeds, creating 1 imported news article for "Department for Transport" with no first published date
    And I can't make the imported news article into a draft edition yet
    When I set the imported news article's first published date to "14-Dec-2011"
    Then I can make the imported news article into a draft edition

  Scenario: Importing speeches sets ImportedAwaitingType speech type and blank "delivered by", to be filled in later
    Given a topic with the slug "my-topic" exists
    When I import the following data as CSV as "Speech" for "Department for Transport":
      """
      old_url,title,summary,body,organisation,policy_1,type,delivered_by,delivered_on,event_and_location,country_1,topic_1
      http://example.com/1,title,summary,body,,,,,14-Dec-2011,location,,my-topic
      """
    Then the import succeeds, creating 1 imported speech with "imported-awaiting-type" speech type and with no deliverer set
    And the imported speech's organisation is set to "Department for Transport"
    Then I can't make the imported speech into a draft edition yet
    When I set the imported speech's type to "Transcript"
    Then I can't make the imported speech into a draft edition yet
    When I set the deliverer of the speech to "Joe Bloggs" from the "Foreign Commonwealth Office"
    Then I can make the imported speech into a draft edition
    And the speech's organisation is set to "Foreign Commonwealth Office"

  Scenario: Importing speeches with blank delivered on means it must be filled in later, along with the deliverer
    Given a person called "Joe Bloggs"
    And a topic with the slug "my-topic" exists
    When I import the following data as CSV as "Speech" for "Department for Transport":
      """
      old_url,title,summary,body,organisation,policy_1,type,delivered_by,delivered_on,event_and_location,country_1,topic_1
      http://example.com/1,title,summary,body,department-for-transport,,transcript,joe-bloggs,,location,,my-topic
      """
    Then the import succeeds, creating 1 imported speech for "Department for Transport" with no delivered on date
    Then I can't make the imported speech into a draft edition yet
    When I set the imported speech's delivered on date to "14-Dec-2011"
    Then I can't make the imported speech into a draft edition yet
    When I set the deliverer of the speech to "Joe Bloggs" from the "Depertment for Transport"
    Then I can make the imported speech into a draft edition

  Scenario: Importing consultations with blank dates allows them to be filled in later
    Given a topic with the slug "my-topic" exists
    When I import the following data as CSV as "Consultation" for "Department for Transport":
      """
      old_url,title,summary,body,organisation,policy_1,opening_date,closing_date,response_date,response_summary,topic_1
      http://example.com/1,title,summary,body,department-for-transport,,,,,,my-topic
      """
    Then the import succeeds, creating 1 imported consultation for "Department for Transport" with no opening or closing date
    And I can't make the imported publication into a draft edition yet
    When I set the imported consultation's opening date to "14-Dec-2011"
    Then I can't make the imported publication into a draft edition yet
    When I set the imported consultation's closing date to "20-Dec-2011"
    Then I can make the imported consultation into a draft edition

  Scenario: Importing edition and then deleting it
    When I import the following data as CSV as "Speech" for "Department for Transport":
      """
      old_url,title,summary,body,organisation,policy_1,type,delivered_by,delivered_on,event_and_location,country_1
      http://example.com/1,title,summary,body,,,,,14-Dec-2011,location,
      """
    Then I can delete the imported edition if I choose to

  Scenario: Importing detailed guides with topic, detailed guidance category, related detailed guide and related mainstream content
    Given a topic with the slug "my-topic" exists
    And a published document collection "My document collection" exists
    And a mainstream category with the slug "my-detailed-guidance-category" exists
    And a published detailed guide "My related detailed guide" for the organisation "Foreign Commonwealth Office"
    When I import the following data as CSV as "Detailed guide" for "Home Office":
      """
      old_url,title,summary,body,organisation,topic_1,document_collection_1,detailed_guidance_category_1,related_detailed_guide_1,related_mainstream_content_url_1,related_mainstream_content_title_1
      "[""http://example.com/1"",""http://example.com/2""]",title,summary,body,,my-topic,my-document-collection,my-detailed-guidance-category,my-related-detailed-guide,,
      """
    Then the import succeeds creating 1 detailed guidance document
    And the imported detailed guidance document has the following associations:
      | Name                             | Slugs                         |
      | topics                           | my-topic                      |
      | document_collections             | my-document-collection        |
      | mainstream_categories            | my-detailed-guidance-category |
      | outbound_related_documents       | my-related-detailed-guide     |


  Scenario: Importing case study with related policies and document collection
    Given a document collection "My document collection" exists
    And a published policy "policy-one"
    When I import the following data as CSV as "Case study" for "Department for Beards":
      """
      old_url,title,summary,body,organisation,policy_1,document_collection_1,first_published,ignore_this
      http://example.com/1,title,summary,body,,policy-one,my-document-collection,14-Dec-2011
      """
    Then the import succeeds creating 1 case study
    And the imported case study has the following associations:
      | Name                             | Slugs                         |
      | related_policies                 | policy-one                    |
      | document_collections             | my-document-collection        |

  Scenario: Importing a news article with a translated version present
    When I import the following data as CSV as "News article" for "Department for Transport":
      """
      old_url,title,summary,body,organisation,policy_1,minister_1,first_published,country_1,news_article_type,locale,translation_url,title_translation,summary_translation,body_translation
      http://example.com/1,title,summary,body,,,,14-Dec-2011,,,es,http://example.com/1.es,spanish title,spanish summary,spanish body
      """
    Then the import succeeds, creating 1 imported news article for "Department for Transport" with "imported-awaiting-type" news article type
    And the imported news article has an "es" locale translation
