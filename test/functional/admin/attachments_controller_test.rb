require "test_helper"

class Admin::AttachmentsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    login_as :gds_editor
    @edition = create(:consultation)
  end

  def self.supported_attachable_types
    {
      edition: :edition_id,
      consultation_outcome: :consultation_response_id,
      consultation_public_feedback: :consultation_response_id,
      policy_group: :policy_group_id,
    }
  end

  supported_attachable_types.each do |type, param_name|
    view_test "GET :index handles #{type} as attachable" do
      attachable = create(type) # rubocop:disable Rails/SaveBang
      create(:file_attachment, attachable:, title: "Lorem Ipsum")

      get :index, params: { param_name => attachable.id }

      assert_response :success
      assert_select "p.govuk-body", "Title: Lorem Ipsum"
    end
  end

  view_test "GET :index shows html attachments" do
    create(:html_attachment, title: "An HTML attachment", attachable: @edition)

    get :index, params: { edition_id: @edition }

    assert_response :success
    assert_select "p.govuk-body", text: "Title: An HTML attachment"
  end

  view_test "GET :index renders the uploading banner when an attachment hasn't been uploaded to asset manager" do
    create(:html_attachment, title: "An HTML attachment", attachable: @edition)
    create(:file_attachment, title: "An uploaded file attachment", attachable: @edition)
    create(:file_attachment_with_no_assets, title: "An uploading file attachment", attachable: @edition, file: upload_fixture("two-pages.pdf"))
    create(:external_attachment, title: "An external attachment", attachable: @edition)

    get :index, params: { edition_id: @edition }

    assert_response :success
    assert_select "p.govuk-body", text: "Title: An HTML attachment"
    assert_select "p.govuk-body", text: "Title: An uploaded file attachment"
    assert_select "p.govuk-body", text: "Title: An uploading file attachment Processing"
    assert_select "p.govuk-body", text: "Title: An external attachment"
  end

  view_test "GET :index renders error if upload_error set in flash" do
    get :index, params: { edition_id: @edition }, flash: { upload_error: "File upload error" }

    assert_response :success
    assert_select ".gem-c-error-summary__list-item", text: "File upload error"
  end

  view_test "GET :index shows external attachments" do
    create(:external_attachment, title: "An external attachment", attachable: @edition)

    get :index, params: { edition_id: @edition }

    assert_response :success
    assert_select "p.govuk-body", text: "Title: An external attachment"
  end

  test "Actions are unavailable on unmodifiable editions" do
    edition = create(:published_publication)

    get :index, params: { edition_id: edition }
    assert_response :redirect
  end

  test "PUT :order saves the new order of attachments" do
    a, b, c = 3.times.map { |n| create(:html_attachment, attachable: @edition, ordering: n) }

    Consultation.any_instance.expects(:reorder_attachments).with([c.id.to_s, a.id.to_s, b.id.to_s]).once

    put :order,
        params: { edition_id: @edition,
                  ordering: { a.id.to_s => "1",
                              b.id.to_s => "2",
                              c.id.to_s => "0" } }

    assert_response :redirect
  end

  test "PUT :order sorts attachment orderings as numbers" do
    a, b, c = 3.times.map { |n| create(:html_attachment, attachable: @edition, ordering: n) }

    Consultation.any_instance.expects(:reorder_attachments).with([a.id.to_s, b.id.to_s, c.id.to_s]).once

    put :order,
        params: { edition_id: @edition,
                  ordering: { a.id.to_s => "9",
                              b.id.to_s => "10",
                              c.id.to_s => "11" } }

    assert_response :redirect
  end

  test "#attachable_attachments_path should be the attachments index" do
    assert_equal admin_edition_attachments_path(@edition),
                 @controller.polymorphic_path(controller.attachable_attachments_path(@edition))
  end

  test "#attachable_attachments_path should be the response page for responses" do
    response = create(:consultation_outcome)

    assert_equal admin_consultation_outcome_path(response.consultation),
                 @controller.polymorphic_path(controller.attachable_attachments_path(response))
  end
end
