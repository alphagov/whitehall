require "test_helper"

class PublishingApi::StatisticalDataSetPresenterTest < ActiveSupport::TestCase
  setup do
    create(:current_government)

    @statistical_data_set = create(
      :statistical_data_set,
      title: "Statistical Data Set title",
      summary: "Statistical Data Set summary",
    )

    @presented_statistical_data_set = PublishingApi::StatisticalDataSetPresenter.new(@statistical_data_set)
    @presented_content = I18n.with_locale("de") { @presented_statistical_data_set.content }
    @presented_links = I18n.with_locale("de") { @presented_statistical_data_set.links }
  end

  test "it presents a valid statistical_data_set content item" do
    assert_valid_against_publisher_schema @presented_content, "statistical_data_set"
    assert_valid_against_links_schema({ links: @presented_links }, "statistical_data_set")
  end

  test "it delegates the content id" do
    assert_equal @statistical_data_set.content_id, @presented_statistical_data_set.content_id
  end

  test "it presents the title" do
    assert_equal "Statistical Data Set title", @presented_content[:title]
  end

  test "it presents the summary as the description" do
    assert_equal "Statistical Data Set summary", @presented_content[:description]
  end

  test "it presents the base_path" do
    assert_equal "/government/statistical-data-sets/statistical-data-set-title.de", @presented_content[:base_path]
  end

  test "it presents updated_at if public_timestamp is nil" do
    assert_equal @statistical_data_set.updated_at, @presented_content[:public_updated_at]
  end

  test "it presents the publishing_app as whitehall" do
    assert_equal Whitehall::PublishingApp::WHITEHALL, @presented_content[:publishing_app]
  end

  test "it presents the rendering_app as government-frontend" do
    assert_equal "government-frontend", @presented_content[:rendering_app]
  end

  test "it presents the schema_name as statistical_data_set" do
    assert_equal "statistical_data_set", @presented_content[:schema_name]
  end

  test "it presents the document type as statistical_data_set" do
    assert_equal "statistical_data_set", @presented_content[:document_type]
  end

  test "it presents the global process wide locale as the locale of the statistical_data_set" do
    assert_equal "de", @presented_content[:locale]
  end

  test "it presents the auth bypass id" do
    assert_equal [@statistical_data_set.auth_bypass_id], @presented_content[:auth_bypass_ids]
  end

  test "it includes headers when headers are present in body" do
    statistical_data_set = create(
      :statistical_data_set,
      title: "Some data set",
      body: "##Some header\n\nSome content",
    )

    presented_statistical_data_set = PublishingApi::StatisticalDataSetPresenter.new(statistical_data_set)

    expected_headers = [
      {
        text: "Some header",
        level: 2,
        id: "some-header",
      },
    ]

    assert_equal expected_headers, presented_statistical_data_set.content[:details][:headers]
  end

  test "it does not include headers when headers are not present in body" do
    statistical_data_set = create(
      :published_statistical_data_set,
      title: "Some data set",
      summary: "Some summary",
      body: "Some content",
    )

    presented_statistical_data_set = PublishingApi::StatisticalDataSetPresenter.new(statistical_data_set)

    assert_nil presented_statistical_data_set.content[:details][:headers]
  end
end

class PublishingApi::StatisticalDataSetWithPublicTimestampTest < ActiveSupport::TestCase
  setup do
    @expected_time = Time.zone.parse("10/01/2016")
    @statistical_data_set = create(
      :statistical_data_set,
    )
    @statistical_data_set.public_timestamp = @expected_time
    @presented_statistical_data_set = PublishingApi::StatisticalDataSetPresenter.new(@statistical_data_set)
  end

  test "it presents public_timestamp if it exists" do
    assert_equal @expected_time, @presented_statistical_data_set.content[:public_updated_at]
  end
end

class PublishingApi::StatisticalDataSetBelongingToPublishedDocumentNoticePresenter < ActiveSupport::TestCase
  test "it presents the Statistical Data Set's first_published_at as first_public_at" do
    presented_notice = PublishingApi::StatisticalDataSetPresenter.new(
      create(:published_statistical_data_set) do |statistical_data_set|
        statistical_data_set.stubs(:first_published_at).returns(Date.new(2015, 4, 10))
      end,
    )

    assert_equal(
      Date.new(2015, 4, 10),
      presented_notice.content[:details][:first_public_at],
    )
  end
end

class PublishingApi::PublishedStatisticalDataSetPresenterDetailsTest < ActiveSupport::TestCase
  setup do
    @expected_first_published_at = Time.zone.local(2011, 2, 5)
    @statistical_data_set = create(
      :statistical_data_set,
      :published,
      body: "*Test string*",
      first_published_at: @expected_first_published_at,
    )

    @presented_content = PublishingApi::StatisticalDataSetPresenter.new(@statistical_data_set).content
    @presented_details = @presented_content[:details]
  end

  test "it presents first_public_at as details, first_public_at" do
    assert_equal @expected_first_published_at, @presented_details[:first_public_at]
  end

  test "it presents change_history" do
    change_history = [
      {
        "public_timestamp" => @expected_first_published_at,
        "note" => "change-note",
      },
    ]

    assert_equal change_history, @presented_details[:change_history]
  end

  test "it presents the lead organisation content_ids as details, emphasised_organisations" do
    assert_equal(
      @statistical_data_set.lead_organisations.map(&:content_id),
      @presented_details[:emphasised_organisations],
    )
  end
end

class PublishingApi::PublishedStatisticalDataSetPresenterLinksTest < ActiveSupport::TestCase
  setup do
    @statistical_data_set = create(:statistical_data_set)
    presented_statistical_data_set = PublishingApi::StatisticalDataSetPresenter.new(@statistical_data_set)
    @presented_links = presented_statistical_data_set.links
  end

  test "it presents the organisation content_ids as links, organisations" do
    assert_equal(
      @statistical_data_set.organisations.map(&:content_id),
      @presented_links[:organisations],
    )
  end
end

class PublishingApi::StatisticalDataSetPresenterUpdateTypeTest < ActiveSupport::TestCase
  setup do
    @presented_statistical_data_set = PublishingApi::StatisticalDataSetPresenter.new(
      create(:statistical_data_set, minor_change: false),
    )
  end

  test "if the update type is not supplied it presents based on the item" do
    assert_equal "major", @presented_statistical_data_set.update_type
  end
end

class PublishingApi::StatisticalDataSetPresenterMinorUpdateTypeTest < ActiveSupport::TestCase
  setup do
    @presented_statistical_data_set = PublishingApi::StatisticalDataSetPresenter.new(
      create(:statistical_data_set, minor_change: true),
    )
  end

  test "if the update type is not supplied it presents based on the item" do
    assert_equal "minor", @presented_statistical_data_set.update_type
  end
end

class PublishingApi::StatisticalDataSetPresenterAttachmentTest < ActiveSupport::TestCase
  setup do
    @statistical_data_set = create(:statistical_data_set, :with_file_attachment)
    @presented_statistical_data_set = PublishingApi::StatisticalDataSetPresenter.new(@statistical_data_set)
  end

  test "it presentes attachments" do
    attachment = @statistical_data_set.attachments.first
    assert_equal @presented_statistical_data_set.content.dig(:details, :attachments, 0, :id),
                 attachment.id.to_s
  end

  test "its attachments are valid against the schema" do
    assert_valid_against_publisher_schema @presented_statistical_data_set.content, "statistical_data_set"
    assert_valid_against_links_schema({ links: @presented_statistical_data_set.links }, "statistical_data_set")
  end
end

class PublishingApi::StatisticalDataSetPresenterUpdateTypeArgumentTest < ActiveSupport::TestCase
  setup do
    @presented_statistical_data_set = PublishingApi::StatisticalDataSetPresenter.new(
      create(:statistical_data_set, minor_change: true),
      update_type: "major",
    )
  end

  test "presents based on the supplied update type argument" do
    assert_equal "major", @presented_statistical_data_set.update_type
  end
end

class PublishingApi::StatisticalDataSetPresenterCurrentGovernmentTest < ActiveSupport::TestCase
  setup do
    # Goverments are not explicitly associated with an Edition.
    # The Government is determined based on date of publication.
    @current_government = create(
      :current_government,
      name: "The Current Government",
      slug: "the-current-government",
    )
    @presented_statistical_data_set = PublishingApi::StatisticalDataSetPresenter.new(
      create(:statistical_data_set),
    )
  end

  test "presents a current government" do
    assert_equal(
      @current_government.content_id,
      @presented_statistical_data_set.links.dig(:government, 0),
    )
  end
end

class PublishingApi::StatisticalDataSetPresenterPreviousGovernmentTest < ActiveSupport::TestCase
  setup do
    # Goverments are not explicitly associated with an Edition.
    # The Government is determined based on date of publication.
    create(:current_government)
    @previous_government = create(
      :previous_government,
      name: "A Previous Government",
      slug: "a-previous-government",
    )
    @presented_statistical_data_set = PublishingApi::StatisticalDataSetPresenter.new(
      create(
        :statistical_data_set,
        first_published_at: @previous_government.start_date + 1.day,
      ),
    )
  end

  test "presents a previous government" do
    assert_equal(
      @previous_government.content_id,
      @presented_statistical_data_set.links.dig(:government, 0),
    )
  end
end

class PublishingApi::StatisticalDataSetPresenterPoliticalTest < ActiveSupport::TestCase
  setup do
    statistical_data_set = create(:statistical_data_set)
    statistical_data_set.stubs(:political?).returns(true)
    @presented_statistical_data_set = PublishingApi::StatisticalDataSetPresenter.new(
      statistical_data_set,
    )
  end

  test "presents political" do
    assert @presented_statistical_data_set.content[:details][:political]
  end
end

class PublishingApi::StatisticalDataSetAccessLimitedTest < ActiveSupport::TestCase
  setup do
    create(:current_government)
    statistical_data_set = create(:statistical_data_set)

    PublishingApi::PayloadBuilder::AccessLimitation.expects(:for)
      .with(statistical_data_set)
      .returns(
        access_limited: { users: %w[abcdef12345] },
      )
    @presented_statistical_data_set = PublishingApi::StatisticalDataSetPresenter.new(
      statistical_data_set,
    )
  end

  test "include access limiting" do
    assert_equal %w[abcdef12345], @presented_statistical_data_set.content[:access_limited][:users]
  end

  test "is valid against content schemas" do
    assert_valid_against_publisher_schema @presented_statistical_data_set.content, "statistical_data_set"
    assert_valid_against_links_schema({ links: @presented_statistical_data_set.links }, "statistical_data_set")
  end
end
