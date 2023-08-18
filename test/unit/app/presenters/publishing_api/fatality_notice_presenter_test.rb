require "test_helper"

class PublishingApi::FatalityNoticePresenterTest < ActiveSupport::TestCase
  setup do
    @fatality_notice = create(
      :fatality_notice,
      document: create(:document, id: 12_345, slug: "fatality-notice-title"),
      title: "Fatality Notice title",
      summary: "Fatality Notice summary",
      first_published_at: @first_published_at = Time.zone.now,
      updated_at: 1.year.ago,
    )

    @presented_fatality_notice = PublishingApi::FatalityNoticePresenter.new(@fatality_notice)
    @presented_content = I18n.with_locale("de") { @presented_fatality_notice.content }
    @presented_links = I18n.with_locale("de") { @presented_fatality_notice.links }
  end

  test "it presents a valid fatality_notice content item" do
    assert_valid_against_publisher_schema @presented_content, "fatality_notice"
    assert_valid_against_links_schema({ links: @presented_links }, "fatality_notice")
  end

  test "it delegates the content id" do
    assert_equal @fatality_notice.content_id, @presented_fatality_notice.content_id
  end

  test "it presents the title" do
    assert_equal "Fatality Notice title", @presented_content[:title]
  end

  test "it presents the summary as the description" do
    assert_equal "Fatality Notice summary", @presented_content[:description]
  end

  test "it presents the base_path" do
    assert_equal "/government/fatalities/fatality-notice-title.de", @presented_content[:base_path]
  end

  test "it presents updated_at if public_timestamp is nil" do
    @fatality_notice.update_columns(public_timestamp: nil)
    @presented_content = I18n.with_locale("de") { @presented_fatality_notice.content }
    assert_equal @fatality_notice.updated_at, @presented_content[:public_updated_at]
  end

  test "it presents the publishing_app as whitehall" do
    assert_equal Whitehall::PublishingApp::WHITEHALL, @presented_content[:publishing_app]
  end

  test "it presents the rendering_app as government-frontend" do
    assert_equal "government-frontend", @presented_content[:rendering_app]
  end

  test "it presents the schema_name as fatality_notice" do
    assert_equal "fatality_notice", @presented_content[:schema_name]
  end

  test "it presents the document type as fatality_notice" do
    assert_equal "fatality_notice", @presented_content[:document_type]
  end

  test "it presents the global process wide locale as the locale of the fatality_notice" do
    assert_equal "de", @presented_content[:locale]
  end

  test "it presents the first_published_at in UTC" do
    assert_equal @first_published_at.utc, @presented_content[:first_published_at]
  end

  test "it presents the auth bypass id" do
    assert_equal [@fatality_notice.auth_bypass_id], @presented_content[:auth_bypass_ids]
  end

  test "it presents edition links" do
    expected_links = {
      field_of_operation: [@fatality_notice.operational_field.content_id],
      organisations: [],
      people: [],
      primary_publishing_organisation: [],
      original_primary_publishing_organisation: [],
      roles: [],
    }
    assert expected_links, @presented_content[:links]
  end
end

class PublishingApi::FatalityNoticePresenterWithPublicTimestampTest < ActiveSupport::TestCase
  setup do
    @expected_time = Time.zone.parse("10/01/2016")
    @fatality_notice = create(
      :fatality_notice,
    )
    @fatality_notice.public_timestamp = @expected_time
    @presented_fatality_notice = PublishingApi::FatalityNoticePresenter.new(@fatality_notice)
  end

  test "it presents public_timestamp if it exists" do
    assert_equal @expected_time, @presented_fatality_notice.content[:public_updated_at]
  end
end

class PublishingApi::DraftFatalityBelongingToPublishedDocumentNoticePresenter < ActiveSupport::TestCase
  test "it presents the Fatality Notice's first_public_at" do
    presented_notice = PublishingApi::FatalityNoticePresenter.new(
      create(:published_fatality_notice) do |fatality_notice|
        fatality_notice.stubs(:first_published_at).returns(Date.new(2015, 4, 10))
      end,
    )

    assert_equal(
      Date.new(2015, 4, 10),
      presented_notice.content[:details][:first_public_at],
    )
  end
end

class PublishingApi::FatalityNoticePresenterDetailsTest < ActiveSupport::TestCase
  setup do
    @fatality_notice = create(
      :fatality_notice,
      body: "*Test string*",
    )

    @casualty_one = create(:fatality_notice_casualty, fatality_notice: @fatality_notice)
    @casualty_two = create(:fatality_notice_casualty, fatality_notice: @fatality_notice)

    @presented_details = PublishingApi::FatalityNoticePresenter.new(@fatality_notice).content[:details]
  end

  test "it presents the Govspeak body as details rendered as HTML" do
    assert_equal(
      "<div class=\"govspeak\"><p><em>Test string</em></p>\n</div>",
      @presented_details[:body],
    )
  end

  test "it presents first_public_at as nil for draft" do
    assert_nil @presented_details[:first_published_at]
  end

  test "it presents the roll call introduction" do
    assert_equal(@fatality_notice.roll_call_introduction, @presented_details[:roll_call_introduction])
  end

  test "it presents the casualties" do
    assert_equal [@casualty_one.personal_details, @casualty_two.personal_details], @presented_details[:casualties]
  end
end

class PublishingApi::PublishedFatalityNoticePresenterDetailsTest < ActiveSupport::TestCase
  setup do
    @expected_time = Time.zone.local(2011, 2, 5)
    @fatality_notice = create(
      :fatality_notice,
      :published,
      body: "*Test string*",
      first_published_at: @expected_time,
    )

    @presented_details = PublishingApi::FatalityNoticePresenter.new(@fatality_notice).content[:details]
  end

  test "it presents first_public_at as details, first_public_at" do
    assert_equal @expected_time, @presented_details[:first_public_at]
  end

  test "it presents change_history" do
    change_history = [
      {
        "public_timestamp" => @expected_time,
        "note" => "change-note",
      },
    ]

    assert_equal change_history, @presented_details[:change_history]
  end

  test "it presents the lead organisation content_ids as details, emphasised_organisations" do
    assert_equal(
      @fatality_notice.lead_organisations.map(&:content_id),
      @presented_details[:emphasised_organisations],
    )
  end
end

class PublishingApi::PublishedFatalityNoticePresenterLinksTest < ActiveSupport::TestCase
  setup do
    @fatality_notice = create(:fatality_notice)
    @fatality_notice.role_appointments << create(:ministerial_role_appointment)
    presented_fatality_notice = PublishingApi::FatalityNoticePresenter.new(@fatality_notice)
    @presented_links = presented_fatality_notice.links
  end

  test "it presents the organisation content_ids as links, organisations" do
    assert_equal(
      @fatality_notice.organisations.map(&:content_id),
      @presented_links[:organisations],
    )
  end

  test "it presents the field of operation as links, field_of_operation" do
    assert_equal(
      [@fatality_notice.operational_field.content_id],
      @presented_links[:field_of_operation],
    )
  end

  test "it presents the role_appointments person content_ids as links, people" do
    assert_equal(
      @fatality_notice.role_appointments.map(&:person).collect(&:content_id),
      @presented_links[:people],
    )
  end

  test "it presents the role_appointments role content_ids as links, roles" do
    assert_equal(
      @fatality_notice.role_appointments.map(&:role).collect(&:content_id),
      @presented_links[:roles],
    )
  end
end

class PublishingApi::FatalityNoticePresenterUpdateTypeTest < ActiveSupport::TestCase
  setup do
    @presented_fatality_notice = PublishingApi::FatalityNoticePresenter.new(
      create(:fatality_notice, minor_change: false),
    )
  end

  test "if the update type is not supplied it presents based on the item" do
    assert_equal "major", @presented_fatality_notice.update_type
  end
end

class PublishingApi::FatalityNoticePresenterMinorUpdateTypeTest < ActiveSupport::TestCase
  setup do
    @presented_fatality_notice = PublishingApi::FatalityNoticePresenter.new(
      create(:fatality_notice, minor_change: true),
    )
  end

  test "if the update type is not supplied it presents based on the item" do
    assert_equal "minor", @presented_fatality_notice.update_type
  end
end

class PublishingApi::FatalityNoticePresenterUpdateTypeArgumentTest < ActiveSupport::TestCase
  setup do
    @presented_fatality_notice = PublishingApi::FatalityNoticePresenter.new(
      create(:fatality_notice, minor_change: true),
      update_type: "major",
    )
  end

  test "presents based on the supplied update type argument" do
    assert_equal "major", @presented_fatality_notice.update_type
  end
end

class PublishingApi::AccessLimitedFatalityNoticeTest < ActiveSupport::TestCase
  setup do
    @presented_fatality_notice = PublishingApi::FatalityNoticePresenter.new(
      @fatality_notice = create(:fatality_notice, :access_limited),
    )
    @organisation = @fatality_notice.organisations.first
    @presented_content = @presented_fatality_notice.content
  end

  test "presents allowed organisations" do
    assert_equal [@organisation.content_id], @presented_content[:access_limited][:organisations]
  end
end
