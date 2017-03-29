require 'test_helper'

class UrlToSubscriberListMigrationTest < ActiveSupport::TestCase
  test "skips policy activities urls" do
    csv_data = [
      { topic_id: 'TOPIC_123', url: "http://test.com/government/policies/energy/activity.atom", created: Time.zone.now },
    ]
    output = run_migration_on(csv_data)
    assert_match %r(Skipped: {:policy_activity=>1}), output
  end

  test "skips policies urls" do
    csv_data = [
      { topic_id: 'TOPIC_123', url: "http://test.com/government/policies.atom", created: Time.zone.now },
    ]
    output = run_migration_on(csv_data)
    assert_match %r(Skipped: {:policy=>1}), output
  end

  test "skips official_document_status urls" do
    csv_data = [
      { topic_id: 'TOPIC_123', url: "http://test.com/government/publication.atom?official_document_status=act_papers", created: Time.zone.now }
    ]
    output = run_migration_on(csv_data)
    assert_match %r(Skipped: {:official_document_status=>1}), output
  end

  test "skips relevant_to_local_government urls" do
    csv_data = [
      { topic_id: 'TOPIC_123', url: "http://test.com/government/publication.atom?relevant_to_local_government=1", created: Time.zone.now }
    ]
    output = run_migration_on(csv_data)
    assert_match %r(Skipped: {:relevant_to_local_government=>1}), output
  end

  test "skips finder urls" do
    csv_data = [
      { topic_id: 'TOPIC_123', url: "http://finder-frontend.production.alphagov.co.uk/", created: Time.zone.now },
    ]
    output = run_migration_on(csv_data)
    assert_match %r(Skipped: {:finder=>1}), output
  end

  test "logs when missing content ID lookup" do
    csv_data = [
      { topic_id: 'TOPIC_123', url: "http://test.com/government/publications.atom?topic[]=other", created: Time.zone.now },
    ]
    static_data = mock('StaticData', content_id: UrlToSubscriberListCriteria::MISSING_LOOKUP)
    output = run_migration_on(csv_data, static_data)
    assert_match %r(Missing lookups\ntopic: other\nTOPIC_123 - http://test.com/government/publications\.atom\?topic\[\]=other)m, output
  end

  test "logs when dry run migration" do
    csv_data = [
      { topic_id: 'TOPIC_123', url: "http://test.com/government/publications.atom?topic[]=energy", created: Time.zone.now },
    ]
    stub_request(:get, %r{email-alert-api.test.alphagov.co.uk/subscriber-lists}).to_return(
      body: {'subscriber_list' => { 'gov_delivery_id' => 'TOPIC_123' } }.to_json
    )
    static_data = mock('StaticData', content_id: "a1234")
    output = run_migration_on(csv_data, static_data)
    expected_output = <<-STR.strip_heredoc
      ******* GovUkDelivery details
      Parsing TOPIC_123 - http://test.com/government/publications.atom?topic[]=energy
      ******* Converted Hash values
      {"links"=>{"topic"=>["energy"]}, "email_document_supertype"=>"publications"}
      {"links"=>{"topic"=>["a1234"]}, "email_document_supertype"=>"publications"}
      ******* EmailAlertApi details
      {"gov_delivery_id"=>"TOPIC_123"}

      1 parsed
      Skipped: {}
    STR
    assert_equal expected_output, output
  end

  test "migration fails if topic ID mismatch" do
    csv_data = [
      { topic_id: 'TOPIC_123', url: "http://test.com/government/publications.atom?topic[]=energy", created: Time.zone.now },
    ]
    stub_request(:get, %r{email-alert-api.test.alphagov.co.uk/subscriber-lists}).to_return(
      body: {'subscriber_list' => { 'gov_delivery_id' => 'OTHER_TOPIC' } }.to_json
    )
    static_data = mock('StaticData', content_id: "a1234")
    output = run_migration_on(csv_data, static_data, "true")
    expected_output = <<-STR.strip_heredoc
      ******* Error
      {"links"=>{"topic"=>["a1234"]},
       "email_document_supertype"=>"publications",
       "gov_delivery_id"=>"TOPIC_123",
       "created_at"=>"2011-11-11 11:11:11 +0000"}
      {"gov_delivery_id"=>"OTHER_TOPIC"}
      {"topic_id"=>"TOPIC_123",
       "_id"=>"http://test.com/government/publications.atom?topic[]=energy",
       "created"=>"2011-11-11 11:11:11 +0000"}

      1 parsed
      Skipped: {}
    STR
    assert_equal expected_output, output
  end

  test "migration success" do
    csv_data = [
      { topic_id: 'TOPIC_123', url: "http://test.com/government/publications.atom?topic[]=energy", created: Time.zone.now },
    ]
    stub_request(:get, %r{email-alert-api.test.alphagov.co.uk/subscriber-lists}).to_return(
      body: {'subscriber_list' => { 'gov_delivery_id' => 'TOPIC_123', updated_at: '2011-11-11' } }.to_json
    )
    static_data = mock('StaticData', content_id: "a1234")
    output = run_migration_on(csv_data, static_data, "true")
    expected_output = <<-STR.strip_heredoc
      .
      1 parsed
      Skipped: {}
    STR
    assert_equal expected_output, output
  end

  test "Correctly look up values using `UrlToSubscriberListCriteria::StaticData` class" do
    database_lookup_test(UrlToSubscriberListCriteria::StaticData)
  end

  test "Correctly look up values using `UrlToSubscriberListCriteria::BulkStaticData` class" do
    database_lookup_test(UrlToSubscriberListCriteria::BulkStaticData.new)
  end

  def database_lookup_test(static_data)
    url = "https://www.gov.uk/government/publications.atom" +
      "?departments%5B%5D=academy-for-justice-commissioning" +
      "&world_locations%5B%5D=united-kingdom" +
      "&topics%5B%5D=defence-and-armed-forces"

    url_people = "https://www.gov.uk/government/people/david-cameron.atom"
    url_role = "https://www.gov.uk/government/ministers/chancellor-of-the-exchequer.atom"
    url_topic_event = "https://www.gov.uk/government/topical-events/autumn-statement-2016.atom"

    csv_data = [
      { topic_id: 'TOPIC_A', url: url, created: Time.zone.now },
      { topic_id: 'TOPIC_B', url: url_people, created: Time.zone.now },
      { topic_id: 'TOPIC_C', url: url_role, created: Time.zone.now },
      { topic_id: 'TOPIC_D', url: url_topic_event, created: Time.zone.now },
    ]

    responses = csv_data.map do |row|
      { body: {'subscriber_list' => { 'gov_delivery_id' => row[:topic_id], updated_at: '2011-11-11' } }.to_json }
    end

    stub_request(:get, %r{email-alert-api.test.alphagov.co.uk/subscriber-lists}).to_return(*responses)

    organisation = create(:organisation, slug: 'academy-for-justice-commissioning')
    world_location = create(:world_location, slug: 'united-kingdom')
    policy_area = create(:topic, slug: 'defence-and-armed-forces')
    person = create(:person, slug: 'david-cameron')
    role = create(:role, slug: 'chancellor-of-the-exchequer')
    topical_event = create(:topical_event, slug: 'autumn-statement-2016')

    output = run_migration_on(csv_data, static_data)
    expected_output = <<-STR.strip_heredoc
      ******* GovUkDelivery details
      Parsing TOPIC_A - https://www.gov.uk/government/publications.atom?departments%5B%5D=academy-for-justice-commissioning&world_locations%5B%5D=united-kingdom&topics%5B%5D=defence-and-armed-forces
      ******* Converted Hash values
      {"links"=>
        {"world_locations"=>["united-kingdom"],
         "organisations"=>["academy-for-justice-commissioning"],
         "policy_areas"=>["defence-and-armed-forces"]},
       "email_document_supertype"=>"publications"}
      {"links"=>
        {"world_locations"=>["#{world_location.content_id}"],
         "organisations"=>["#{organisation.content_id}"],
         "policy_areas"=>["#{policy_area.content_id}"]},
       "email_document_supertype"=>"publications"}
      ******* EmailAlertApi details
      {"gov_delivery_id"=>"TOPIC_A", "updated_at"=>"2011-11-11"}

      ******* GovUkDelivery details
      Parsing TOPIC_B - https://www.gov.uk/government/people/david-cameron.atom
      ******* Converted Hash values
      {"links"=>{"people"=>["david-cameron"]}}
      {"links"=>{"people"=>["#{person.content_id}"]}}
      ******* EmailAlertApi details
      {"gov_delivery_id"=>"TOPIC_B", "updated_at"=>"2011-11-11"}

      ******* GovUkDelivery details
      Parsing TOPIC_C - https://www.gov.uk/government/ministers/chancellor-of-the-exchequer.atom
      ******* Converted Hash values
      {"links"=>{"roles"=>["chancellor-of-the-exchequer"]}}
      {"links"=>{"roles"=>["#{role.content_id}"]}}
      ******* EmailAlertApi details
      {"gov_delivery_id"=>"TOPIC_C", "updated_at"=>"2011-11-11"}

      ******* GovUkDelivery details
      Parsing TOPIC_D - https://www.gov.uk/government/topical-events/autumn-statement-2016.atom
      ******* Converted Hash values
      {"links"=>{"topical_events"=>["autumn-statement-2016"]}}
      {"links"=>{"topical_events"=>["#{topical_event.content_id}"]}}
      ******* EmailAlertApi details
      {"gov_delivery_id"=>"TOPIC_D", "updated_at"=>"2011-11-11"}

      4 parsed
      Skipped: {}
    STR
    assert_equal expected_output, output
  end

  def run_migration_on(data, static_data = mock, perform_migration = nil)
    io = StringIO.new
    t = Tempfile.new('csv')

    t.write "topic_id,_id,created\n"
    data.each do |row|
      t.write [row[:topic_id], row[:url], row[:created].to_s].join(',')
      t.write "\n"
    end
    t.rewind
    migrator = UrlToSubscriberListCriteriaMigration.new(t.path, perform_migration, io)
    migrator.run(static_data)
    migrator.report
    io.rewind
    io.read
  ensure
    t.close
  end
end
