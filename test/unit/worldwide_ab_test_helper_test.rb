require 'test_helper'

class WorldwideAbHelperTest < ActiveSupport::TestCase
  def subject(file_path = nil)
    WorldwideAbTestHelper.new(file_path)
  end

  def with_fixture_file
    content = <<-CONTENT.strip_heredoc
      --- !map:HashWithIndifferentAccess
      india:
        translations:
          - name: Samplese
            code: zz
        taxonomy:
          - title: Help for British nationals in Sample
            description: Travel documents and help with emergencies.
            base_path: help-for-british-nationals
            tagged_content:
              - title: Get a new or replacement UK passport
                description: Forms, prices and application details you need if you're a British national and you want to renew or apply for a British passport.
                base_path: /apply-renew-passport
              - title: Get emergency UK travel documents
                description: If you're abroad, need to travel and can't get a passport in time.
                base_path: /emergency-travel-document
        embassies:
          british-high-commission-new-delhi:
            - title: British High Commission New Delhi
              summary: The summary
              body: |
                The British High Commission in New Delhi represents the UK government and provides services to British nationals in India.
                We help sustain and develop the important relationship between the UK and India.
                You can access UK government services while in [India](https://www.gov.uk/government/world/india)
                ##Urgent assistance
                If you’re in India and you need urgent help (for example, you’ve been attacked, arrested or someone has died), call +41 (12) 345 6789. If you’re in the UK and worried about a British national in Sample, call 020 7008 1500.
                [Contact the High Commission](#contact-us) for information about our other services.
          british-deputy-high-commission-kolkata:
            - title: British Deputy High Commission Kolkata
              summary: The summary
              body: |
                The British High Commission in Kolkata represents the UK government and provides services to British nationals in India.
                We help sustain and develop the important relationship between the UK and India.
                You can access UK government services while in [India](https://www.gov.uk/government/world/india)
                ##Urgent assistance
                If you’re in India and you need urgent help (for example, you’ve been attacked, arrested or someone has died), call +41 (12) 345 6789. If you’re in the UK and worried about a British national in Sample, call 020 7008 1500.
                [Contact the High Commission](#contact-us) for information about our other services.

    CONTENT

    Tempfile.open("ww_content_fixture") do |f|
      f.write content
      f.rewind
      yield f.path
    end
  end

  test "content returns the parsed file " do
    with_fixture_file do |file_path|
      result = subject(file_path).content
      assert result[:india].present?
    end
  end

  test "has_content_for? returns true if the key is present" do
    with_fixture_file do |file_path|
      assert subject(file_path).has_content_for?(:india)
    end
  end

  test "has_content_for? returns true if the string key is present" do
    with_fixture_file do |file_path|
      assert subject(file_path).has_content_for?("india")
    end
  end

  test "has_content_for? returns false if the key is not present" do
    with_fixture_file do |file_path|
      refute subject(file_path).has_content_for?("eggnogg")
    end
  end

  test "content_for returns content for the key if present" do
    with_fixture_file do |file_path|
      assert_not_nil subject(file_path).content_for("india")
    end
  end

  test "content_for returns nil if the key is not present" do
    with_fixture_file do |file_path|
      assert_nil subject(file_path).content_for("booyah")
    end
  end

  test "location_for returns the first worldwide_location" do
    with_fixture_file do |file_path|
      location = stub(slug: "turkey")
      org = stub(
        slug: "british-embassy-turkey",
        world_locations: [location]
      )

      assert_equal location, subject(file_path).location_for(org)
    end
  end

  test "location_for returns hard coded location where present" do
    with_fixture_file do |file_path|
      location = stub(slug: "turkey")
      hard_coded_location = stub(slug: "india")
      organisation = stub(
        slug: "british-deputy-high-commission-kolkata",
        world_locations: [location, hard_coded_location]
      )

      assert_equal hard_coded_location, subject(file_path).location_for(organisation)
    end
  end

  test "is_under_test? returns true if location is first location" do
    with_fixture_file do |file_path|
      location = stub(slug: "india")
      organisation = stub(
        slug: "british-high-commission-new-delhi",
        world_locations: [location]
      )

      assert subject(file_path).is_under_test?(organisation)
    end
  end

  test "is_under_test? returns true if organisation slug is hard coded" do
    with_fixture_file do |file_path|
      location = stub(slug: "embassy")
      other_location = stub(slug: "india")
      organisation = stub(
        slug: "british-deputy-high-commission-kolkata",
        world_locations: [location, other_location]
      )

      assert subject(file_path).is_under_test?(organisation)
    end
  end

  test "is_under_test? returns false if the organisation isn't related to a location under test" do
    with_fixture_file do |file_path|
      location = stub(slug: "germany")
      organisation = stub(
        slug: "embassy-in-germany",
        world_locations: [location]
      )

      refute subject(file_path).is_under_test?(organisation)
    end
  end

  test "is_under_test? returns true if supplied with a location with content" do
    with_fixture_file do |file_path|
      location = stub(slug: "india")
      assert subject(file_path).is_under_test?(location)
    end
  end

  test "is_under_test? return false if the supplied with a location without content" do
    with_fixture_file do |file_path|
      location = WorldLocation.new(slug: "germany")
      refute subject(file_path).is_under_test?(location)
    end
  end

  test "is_under_test? returns false if the organisation is not listed under the location under test" do
    with_fixture_file do |file_path|
      location = stub(slug: "india")
      organisation = stub(
        slug: "organisation-which-is-not-listed-in-the-yml",
        world_locations: [location]
      )

      refute subject(file_path).is_under_test?(organisation)
    end
  end

  test "is_under_test? returns false if the testable_object is nil" do
    refute subject.is_under_test?(nil)
  end

  test "is_under_test? returns false if the testable_object is a string" do
    refute subject.is_under_test?("world-location-test-string-1")
  end
end
