require 'test_helper'

class Admin::PublicationsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_creating_of :publication
  should_allow_editing_of :publication

  should_allow_speed_tagging_of :publication
  should_allow_related_policies_for :publication
  should_allow_organisations_for :publication
  should_allow_ministerial_roles_for :publication
  should_allow_references_to_statistical_data_sets_for :publication
  should_require_alternative_format_provider_for :publication
  show_should_display_attachments_for :publication
  should_not_show_inline_attachment_help_for :publication
  should_allow_html_versions_for :publication
  should_allow_attached_images_for :publication
  should_allow_association_between_world_locations_and :publication
  should_prevent_modification_of_unmodifiable :publication
  should_allow_alternative_format_provider_for :publication
  should_allow_assignment_to_document_series :publication
  should_allow_scheduled_publication_of :publication
  should_allow_access_limiting_of :publication

  view_test "new displays publication fields" do
    get :new

    assert_select "form#new_edition" do
      assert_select "select[name*='edition[publication_date']", count: 5
      assert_select "select[name='edition[publication_type_id]']"
    end
  end

  view_test "new doesn't allow consultation to be chosen as the type" do
    get :new

    assert_select "select[name='edition[publication_type_id]']" do
      assert_select "option", text: PublicationType::Consultation.singular_name, count: 0
    end
  end

  view_test "new should allow users to add publication metadata to an attachment" do
    get :new

    assert_select "form#new_edition" do
      assert_select "input[type=text][name='edition[edition_attachments_attributes][0][attachment_attributes][order_url]']"
      assert_select "input[type=text][name='edition[edition_attachments_attributes][0][attachment_attributes][price]']"
    end
  end

  test "create should create a new publication" do
    post :create, edition: controller_attributes_for(:publication,
      publication_date: Time.zone.parse("2001-10-21 00:00:00"),
      publication_type_id: PublicationType::ResearchAndAnalysis.id
    )

    created_publication = Publication.last
    assert_equal Time.zone.parse("2001-10-21 00:00:00"), created_publication.publication_date
    assert_equal PublicationType::ResearchAndAnalysis, created_publication.publication_type
  end

  test "create should create a new publication and attachment with additional publication metadata" do
    post :create, edition: controller_attributes_for(:publication).merge({
      alternative_format_provider_id: create(:alternative_format_provider).id,
      edition_attachments_attributes: {
        "0" => { attachment_attributes: attributes_for(:attachment,
          title: "attachment-title",
          order_url: 'http://example.com/publication',
          price: "1.23").merge(attachment_data_attributes: {
            file: fixture_file_upload('greenpaper.pdf', 'application/pdf')
          })
        }
      }
    })

    created_publication = Publication.last
    assert_equal 'http://example.com/publication', created_publication.attachments.first.order_url
    assert_equal 1.23, created_publication.attachments.first.price
  end

  view_test "edit displays publication fields" do
    publication = create(:publication)

    get :edit, id: publication

    assert_select "form#edit_edition" do
      assert_select "select[name='edition[publication_type_id]']"
      assert_select "select[name*='edition[publication_date']", count: 5
    end
  end

  view_test "edit should allow users to assign publication metadata to an attachment" do
    publication = create(:publication, :with_attachment)
    attachment = publication.attachments.first

    get :edit, id: publication

    assert_select "form#edit_edition" do
      assert_select "input[type=text][name='edition[edition_attachments_attributes][0][attachment_attributes][order_url]']"
      assert_select "input[type=text][name='edition[edition_attachments_attributes][0][attachment_attributes][price]']"
    end
  end

  test "update should save modified publication attributes" do
    publication = create(:publication)

    put :update, id: publication, edition: controller_attributes_for_instance(publication,
      publication_date: Time.zone.parse("2001-06-18 00:00:00")
    )

    saved_publication = publication.reload
    assert_equal Time.zone.parse("2001-06-18 00:00:00"), saved_publication.publication_date
  end

  view_test "should display publication attributes" do
    publication = create(:publication,
      publication_date: Time.zone.parse("2001-05-31 00:00:00"),
      publication_type_id: PublicationType::ResearchAndAnalysis.id
    )

    get :show, id: publication

    assert_select ".document" do
      assert_select ".publication_type", text: "Research and analysis"
      assert_select ".publication_date", text: "31 May 2001 00:00"
    end
  end

  private

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:alternative_format_provider).reverse_merge(
      alternative_format_provider_id: create(:alternative_format_provider).id
    )
  end
end
