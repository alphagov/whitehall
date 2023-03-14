require "test_helper"

class PublishingApi::OperationalFieldPresenterTest < ActiveSupport::TestCase
  setup do
    @operational_field = create(
      :operational_field,
      name: "Operational Field name",
      description: "Operational Field description",
    )
    @fatality_notices_for_operational_field = []
    @casualty_hash = {}
    2.times do |i|
      notice = create(:published_fatality_notice, roll_call_introduction: "Fatality Notice #{i}", operational_field: @operational_field)
      @casualty_hash[notice.id] = []
      2.times do |j|
        casualty = create(:fatality_notice_casualty, fatality_notice: notice, personal_details: "personal details #{i} - #{j}")
        @casualty_hash[notice.id] << casualty.personal_details
      end
      @fatality_notices_for_operational_field << notice
    end
    create(:published_fatality_notice, operational_field: create(:operational_field))
    %i[draft_fatality_notice
       submitted_fatality_notice
       rejected_fatality_notice
       deleted_fatality_notice
       superseded_fatality_notice
       scheduled_fatality_notice].map do |non_published_type|
      create(non_published_type, operational_field: @operational_field)
    end

    @presented_operational_field = PublishingApi::OperationalFieldPresenter.new(@operational_field)
    @presented_content = @presented_operational_field.content
    @links = @presented_operational_field.links
  end

  test "presents an operational field" do
    expected_hash = {
      title: "Operational Field name",
      locale: "en",
      publishing_app: "whitehall",
      update_type: "major",
      base_path: "/government/fields-of-operation/operational-field-name",
      details: { casualties: @casualty_hash },
      document_type: "field_of_operation",
      rendering_app: "whitehall-frontend",
      schema_name: "field_of_operation",
      description: "Operational Field description",
      routes: [
        {
          path: "/government/fields-of-operation/operational-field-name",
          type: "exact",
        },
      ],
    }

    assert_equal expected_hash, @presented_content
    assert_valid_against_publisher_schema @presented_content, "field_of_operation"
  end

  test "it delegates the content id" do
    assert_equal @operational_field.content_id, @presented_operational_field.content_id
  end

  test "it presents the expected links" do
    expected_links = {
      fatality_notices: @fatality_notices_for_operational_field.map(&:content_id),
      primary_publishing_organisation: [PublishingApi::OperationalFieldPresenter::MINISTRY_OF_DEFENCE_CONTENT_ID],
    }

    assert_equal expected_links, @links
    assert_valid_against_links_schema({ links: @links }, "field_of_operation")
  end
end
