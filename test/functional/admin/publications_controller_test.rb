require 'test_helper'

class Admin::PublicationsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_showing_of :publication
  should_allow_creating_of :publication
  should_allow_editing_of :publication
  should_allow_revision_of :publication

  should_show_document_audit_trail_for :publication, :show
  should_show_document_audit_trail_for :publication, :edit

  should_allow_related_policies_for :publication
  should_allow_organisations_for :publication
  should_allow_ministerial_roles_for :publication
  should_allow_attachments_for :publication
  should_allow_references_to_statistical_data_sets_for :publication
  should_require_alternative_format_provider_for :publication
  show_should_display_attachments_for :publication
  should_allow_attachment_references_for :publication
  should_not_show_inline_attachment_help_for :publication
  should_allow_attached_images_for :publication
  should_allow_association_between_world_locations_and :publication
  should_be_rejectable :publication
  should_be_publishable :publication
  should_allow_unpublishing_for :publication
  should_be_force_publishable :publication
  should_be_able_to_delete_an_edition :publication
  should_link_to_public_version_when_published :publication
  should_not_link_to_public_version_when_not_published :publication
  should_link_to_preview_version_when_not_published :publication
  should_prevent_modification_of_unmodifiable :publication
  should_allow_alternative_format_provider_for :publication
  should_allow_assignment_to_document_series :publication
  should_allow_scheduled_publication_of :publication

  test "new displays publication fields" do
    get :new

    assert_select "form#edition_new" do
      assert_select "select[name*='edition[publication_date']", count: 3
      assert_select "select[name='edition[publication_type_id]']"
    end
  end

  test "new doesn't allow consultation to be chosen as the type" do
    get :new

    assert_select "select[name='edition[publication_type_id]']" do
      assert_select "option", text: PublicationType::Consultation.singular_name, count: 0
    end
  end

  test "new should allow users to add publication metadata to an attachment" do
    get :new

    assert_select "form#edition_new" do
      assert_select "input[type=text][name='edition[edition_attachments_attributes][0][attachment_attributes][order_url]']"
      assert_select "input[type=text][name='edition[edition_attachments_attributes][0][attachment_attributes][price]']"
    end
  end

  test "create should create a new publication" do
    post :create, edition: controller_attributes_for(:publication,
      publication_date: Date.parse("1805-10-21"),
      publication_type_id: PublicationType::ResearchAndAnalysis.id
    )

    created_publication = Publication.last
    assert_equal Date.parse("1805-10-21"), created_publication.publication_date
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

  test "create should record the access_limited flag for a National Statistic publications" do
    post :create, edition: controller_attributes_for(:publication,
      publication_date: Date.parse("1805-10-21"),
      publication_type_id: PublicationType::NationalStatistics.id,
      access_limited: true
    )

    assert created_publication = Publication.last
    assert created_publication.access_limited?
  end

  test "edit displays persisted access_limited flag for National Statistic publications" do
    publication = create(:publication, publication_type_id: PublicationType::NationalStatistics.id, access_limited: false)

    get :edit, id: publication

    assert_select "form#edition_edit" do
      assert_select "input[name='edition[access_limited]'][type=checkbox]"
      assert_select "input[name='edition[access_limited]'][type=checkbox][checked=checked]", count: 0
    end
  end

  test "edit will always check access_limited flag ignoring the persisted value for non-statistic publications" do
    publication = create(:publication, publication_type_id: PublicationType::PolicyPaper.id, access_limited: false)

    get :edit, id: publication

    assert_select "form#edition_edit" do
      assert_select "input[name='edition[access_limited]'][type=checkbox][checked=checked]"
    end
  end

  test "edit displays publication fields" do
    publication = create(:publication)

    get :edit, id: publication

    assert_select "form#edition_edit" do
      assert_select "select[name='edition[publication_type_id]']"
      assert_select "select[name*='edition[publication_date']", count: 3
    end
  end

  test "edit should allow users to assign publication metadata to an attachment" do
    publication = create(:publication, :with_attachment)
    attachment = publication.attachments.first

    get :edit, id: publication

    assert_select "form#edition_edit" do
      assert_select "input[type=text][name='edition[edition_attachments_attributes][0][attachment_attributes][order_url]']"
      assert_select "input[type=text][name='edition[edition_attachments_attributes][0][attachment_attributes][price]']"
    end
  end

  test "update should save modified publication attributes" do
    publication = create(:publication)

    put :update, id: publication, edition: controller_attributes_for_instance(publication,
      publication_date: Date.parse("1815-06-18")
    )

    saved_publication = publication.reload
    assert_equal Date.parse("1815-06-18"), saved_publication.publication_date
  end

  test "should display publication attributes" do
    publication = create(:publication,
      publication_date: Date.parse("1916-05-31"),
      publication_type_id: PublicationType::ResearchAndAnalysis.id
    )

    get :show, id: publication

    assert_select ".document" do
      assert_select ".publication_type", text: "Research and analysis"
      assert_select ".publication_date", text: "31 May 1916"
    end
  end

  private

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:alternative_format_provider).reverse_merge(
      alternative_format_provider_id: create(:alternative_format_provider).id
    )
  end
end
