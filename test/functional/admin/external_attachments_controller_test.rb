require "test_helper"

class Admin::AttachmentsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  def valid_external_attachment_params
    {
      title: "Attachment title",
      external_url: "http://www.somewebsite.com/somepath",
    }
  end

  setup do
    login_as :gds_editor
    @edition = create(:consultation)
  end

  test "POST :create handles external attachments when attachable allows them" do
    publication = create(:publication, attachments: [])
    post :create, params: { edition_id: publication, type: "external", attachment: valid_external_attachment_params }

    assert_response :redirect
    assert_equal 1, publication.reload.attachments.size
    assert_equal "Attachment title", publication.attachments.first.title
    assert_equal "http://www.somewebsite.com/somepath", publication.attachments.first.external_url
  end

  test "POST :create ignores external attachments when attachable does not allow them" do
    attachable = create(:statistical_data_set, access_limited: false)

    post :create, params: { edition_id: attachable, type: "external", attachment: valid_external_attachment_params }

    assert_response :redirect
    assert_equal 0, attachable.reload.attachments.size
  end

  test "Actions are unavailable on unmodifiable editions" do
    edition = create(:published_news_article)

    get :index, params: { edition_id: edition }
    assert_response :redirect
  end

  test "GET :new raises an exception with an unknown parent type" do
    assert_raise(ActiveRecord::RecordNotFound) do
      get :new, params: { edition_id: 123 }
    end
  end

  test "POST :create with bad data does not save the attachment and re-renders the new template" do
    post :create, params: { edition_id: @edition, attachment: { attachment_data_attributes: {} } }
    assert_template :new
    assert_equal 0, @edition.reload.attachments.size
  end

  view_test "GET :edit renders the edit form" do
    attachment = create(:external_attachment, attachable: @edition)
    get :edit, params: { edition_id: @edition, id: attachment }
    assert_select "input[value=#{attachment.title}]"
  end

  test "PUT :update for external attachment updates the attachment" do
    attachment = create(:external_attachment, attachable: @edition)

    put :update,
        params: {
          edition_id: @edition,
          id: attachment.id,
          attachment: {
            title: "New title",
            external_url: "http://www.newwebsite.com/somepath",
          },
        }
    assert_equal "New title", attachment.reload.title
    assert_equal "http://www.newwebsite.com/somepath", attachment.reload.external_url
  end

  test "attachment access is forbidden for users without access to the edition" do
    login_as :world_editor
    get :new, params: { edition_id: @edition }
    assert_response :forbidden
  end
end
