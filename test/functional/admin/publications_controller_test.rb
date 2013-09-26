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
  should_allow_html_versions_for :publication
  should_allow_attached_images_for :publication
  should_allow_association_between_world_locations_and :publication
  should_prevent_modification_of_unmodifiable :publication
  should_allow_alternative_format_provider_for :publication
  should_allow_scheduled_publication_of :publication
  should_allow_access_limiting_of :publication

  view_test "new displays publication fields" do
    get :new

    assert_select "form#new_edition" do
      assert_select "select[name*='edition[first_published_at']", count: 5
      assert_select "select[name='edition[publication_type_id]']"
    end
  end

  test "create should create a new publication" do
    post :create, edition: controller_attributes_for(:publication,
      first_published_at: Time.zone.parse("2001-10-21 00:00:00"),
      publication_type_id: PublicationType::ResearchAndAnalysis.id
    )

    created_publication = Publication.last
    assert_equal Time.zone.parse("2001-10-21 00:00:00"), created_publication.first_published_at
    assert_equal PublicationType::ResearchAndAnalysis, created_publication.publication_type
  end

  test "create should create a new publication and attachment with additional publication metadata" do
    upload_file = fixture_file_upload('greenpaper.pdf', 'application/pdf')
    post :create, edition: controller_attributes_for(:publication).merge(
      alternative_format_provider_id: create(:alternative_format_provider).id,
      attachments_attributes: {
        '0' => attributes_for(
          :attachment,
          title: 'attachment-title',
          order_url: 'http://example.com/publication',
          price: '1.23',
          hoc_paper_number: '0123',
          parliamentary_session: '1951/52'
        ).merge(attachment_data_attributes: { file: upload_file })
      }
    )

    created_publication = Publication.last
    assert_equal 'http://example.com/publication', created_publication.attachments.first.order_url
    assert_equal 1.23, created_publication.attachments.first.price
    assert_equal '0123', created_publication.attachments.first.hoc_paper_number
  end

  view_test "edit displays publication fields" do
    publication = create(:publication)

    get :edit, id: publication

    assert_select "form#edit_edition" do
      assert_select "select[name='edition[publication_type_id]']"
      assert_select "select[name*='edition[first_published_at']", count: 5
    end
  end

  test "update should save modified publication attributes" do
    publication = create(:publication)

    put :update, id: publication, edition: controller_attributes_for_instance(publication,
      first_published_at: Time.zone.parse("2001-06-18 00:00:00")
    )

    saved_publication = publication.reload
    assert_equal Time.zone.parse("2001-06-18 00:00:00"), saved_publication.first_published_at
  end

  private

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:alternative_format_provider).reverse_merge(
      alternative_format_provider_id: create(:alternative_format_provider).id
    )
  end
end
