Feature: Importing new editions
  We want to be able to import editions into our database which don't have all the data filled in. The idea is to then 'speed tag' them with all the associations they need, and send them direct to draft state.

  Future:
  - Can specify the Organisation that is being imported on the import page

  - column required: should fail csv upload without the column
  - required: should fail row import without it, implies column required
  - unique: should fail csv upload if any duplicates of this field in the file, implies required
  - optional: import if avaialable, leave blank if not
  - default: import if available, set to a default if not

  All types:
  old_url: column required + data unique
  title: required
  summary: optional
  body: required
  organisation: required, ideally default blank to SELECTED, reject anything that is non-blank can't be found

  Publications:
  publication_date: required
  publication_type: required, ideally default blank to UNKNOWN, reject anything non-blank that can't be found
  policy_1..4: 1 column required, data optional
  document_series: column required, data optional
  attachment_1..n_*: 1 column required, data required (should stay as is)
  json_attachments: optional, leave as is
  country_1..4: 1 column required, data optional

  Consultations:
  opening_on: required
  closing_on: required
  response_date: optional
  response_summary: optional
  response_attachments_1..n_*: 1 column required, optional (should stay as is)

  News:
  first_published_at: required
  policy_1..4: 1 column required, data optional
  minister_1..2: optional
  country_1..4: 1 column required, data optional

  Speeches:
  speech_type: required, ideally default blank to UNKNOWN, reject anything non-blank that can't be found
  delivered_by: required, ideally default blank, reject anything non-black that can't be found
  event_and_location: optional
  country_1..4: 1 column required, data optional

  StatisitcalDataSets:
  document_series: column required, data optional

  FatalityNotices:
  field_of_operation: required

  Scenario: Importing data which requires transformation
    Given I am an importer
    When I import the following data as CSV as "Publication":
      |old_url|title|summary|body|organisation|policy_1|publication_type|document_series|publication_date|minister_1|minister_2|order_url|price|isbn|urn|command_paper_number|ignore_1|attachment_1_url|attachment_1_title|country_1|
      |http://example.com/1|title|summary|body|department-for-transport|||||Joe Bloggs|||||||||||
    Then the import should fail and no editions are created
    When I replace "Joe Bloggs" with "joe-bloggs" in the "minister_1" column
    Then the import succeeds

  Scenario: Importing data which requires addition of new metadata

  Scenario: Importing slightly broken files will succeed
    Given I am an importer
    When I import the following data as CSV as "Publication":
      |old_url|title|summary|body|organisation|policy_1|publication_type|document_series|publication_date|order_url|price|isbn|urn|command_paper_number|ignore_1|attachment_1_url|attachment_1_title|country_1|
      |http://example.com/1|Hello|Hi there|A more formal, and longer, greeting|Department Of Grooming|        |                |               |                |         |     |    |   |                    |        |                |                  |         |
    Then the import succeeds, creating 1 imported edition with validation problems
    When I fix the issues with the "Hello" edition
    Then the "Hello" edition is available as a draft

  Scenario: Importing correct files
    Given I am an importer
    # TODO: what is a minimally correct set of data for a csv?
    When I import the following data as CSV as "Publication":
      |old_url|title|summary|body|organisation|policy_1|publication_type|document_series|publication_date|order_url|price|isbn|urn|command_paper_number|ignore_1|attachment_1_url|attachment_1_title|country_1|
      |http://example.com/1|Hello|Hi there|A more formal, and longer, greeting|Department Of Grooming|        |                |               |                |         |     |    |   |                    |        |                |                  |         |
    Then the import succeeds, creating 1 draft edition without validation problems
