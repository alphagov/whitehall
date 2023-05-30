require "test_helper"

class Admin::EditionsControllerTest < ActionController::TestCase
  include Admin::EditionRoutesHelper

  setup do
    login_as :writer
  end

  should_be_an_admin_controller

  test "should pass filter parameters to an edition filter" do
    stub_filter = stub_edition_filter
    Admin::EditionFilter.expects(:new).with(anything, anything, has_entries(state: "draft", type: "publication")).returns(stub_filter)

    get :index, params: { state: :draft, type: :publication }
  end

  test "should not pass blank parameters to the edition filter" do
    stub_filter = stub_edition_filter
    Admin::EditionFilter.expects(:new).with(anything, anything, Not(has_key(:author))).returns(stub_filter)

    get :index, params: { state: :draft, author: "" }
  end

  test 'should add state param set to "active" if none is supplied' do
    stub_filter = stub_edition_filter
    Admin::EditionFilter.expects(:new).with(anything, anything, has_entry(state: "active")).returns(stub_filter)

    get :index, params: { type: :publication }
  end

  test "diffing against a previous version" do
    publication = create(:draft_publication)
    editor = create(:departmental_editor)
    AuditTrail.whodunnit = editor
    publication.first_published_at = Time.zone.now
    publication.major_change_published_at = Time.zone.now
    force_publish(publication)
    draft_publication = Timecop.freeze 1.hour.from_now do
      publication.reload.create_draft(editor)
    end

    get :diff, params: { id: draft_publication, audit_trail_entry_id: draft_publication.previous_edition.id }

    assert_response :success
    assert_template :diff
    assert_equal draft_publication, assigns(:edition)
    assert_equal publication, assigns(:audit_trail_entry)
  end

  test "revising the published edition should create a new draft edition" do
    published_edition = create(:published_publication)
    Edition.stubs(:find).returns(published_edition)
    draft_edition = create(:draft_publication)
    published_edition.expects(:create_draft).with(current_user).returns(draft_edition)

    post :revise, params: { id: published_edition }
  end

  test "revising the superseded edition - if it happens to also be the latest edition - should create a new draft edition from the first deleted edition after the superseded one" do
    document = create(:document)
    buggy_superseded_edition = create(:superseded_edition, document:, title: "First")
    create(:deleted_edition, document:, title: "Second")
    create(:deleted_edition, document:, title: "Third")

    post :revise, params: { id: buggy_superseded_edition }

    assert_equal(
      %w[superseded deleted deleted draft],
      Edition.unscoped.where(document_id: document.id).pluck(:state),
    )
    assert_equal("Second", document.latest_edition.title)
  end

  test "revising a published edition redirects to edit for the new draft" do
    published_edition = create(:published_publication)

    post :revise, params: { id: published_edition }

    draft_edition = Edition.last
    assert_redirected_to edit_admin_publication_path(draft_edition.reload)
  end

  test "failing to revise an edition should redirect to the existing draft" do
    published_edition = create(:published_publication)
    existing_draft = create(:draft_publication, document: published_edition.document)

    post :revise, params: { id: published_edition }

    assert_redirected_to edit_admin_publication_path(existing_draft)
    assert_match "There is already an active draft edition for this document", flash[:alert]
  end

  test "failing to revise an edition should redirect to the existing submitted edition" do
    published_edition = create(:published_publication)
    existing_submitted = create(:submitted_publication, document: published_edition.document)

    post :revise, params: { id: published_edition }

    assert_redirected_to edit_admin_publication_path(existing_submitted)
    assert_match "There is already an active submitted edition for this document", flash[:alert]
  end

  test "failing to revise an edition should redirect to the existing rejected edition" do
    published_edition = create(:published_publication)
    existing_rejected = create(:rejected_publication, document: published_edition.document)

    post :revise, params: { id: published_edition }

    assert_redirected_to edit_admin_publication_path(existing_rejected)
    assert_match "There is already an active rejected edition for this document", flash[:alert]
  end

  test "should remember standard filter options" do
    get :index, params: { state: :draft, type: "consultation" }
    assert_equal "consultation", session[:document_filters]["type"]
  end

  test "should remember author filter options" do
    get :index, params: { state: :draft, author: current_user }
    assert_equal current_user.to_param, session[:document_filters]["author"]
  end

  test "should remember organisation filter options" do
    organisation = create(:organisation)
    get :index, params: { state: :draft, organisation: }
    assert_equal organisation.to_param, session[:document_filters]["organisation"]
  end

  test "should remember state filter options" do
    get :index, params: { state: :draft }
    assert_equal "draft", session[:document_filters]["state"]
  end

  test "should remember title filter options" do
    get :index, params: { title: "test" }
    assert_equal "test", session[:document_filters]["title"]
  end

  test "index should redirect to remembered filtered options if available" do
    organisation = create(:organisation)
    get :index, params: { organisation:, state: :submitted }

    get :index
    assert_redirected_to admin_editions_path(state: :submitted, organisation:)
  end

  test "index should redirect to remembered filtered options if selected filter is invalid" do
    organisation = create(:organisation)
    session[:document_filters] = { "state" => "submitted", "author" => current_user.to_param, "organisation" => organisation.to_param }
    get :index, params: { author: "invalid" }
    assert_redirected_to admin_editions_path(state: :submitted, author: current_user, organisation:)
  end

  test "index should redirect to department if logged in with no remembered filters" do
    organisation = create(:organisation)
    login_as create(:departmental_editor, organisation:)
    get :index
    assert_redirected_to admin_editions_path(organisation: organisation.id, state: :active)
  end

  view_test "should not show published editions as force published" do
    publication = create(:published_publication)
    get :index, params: { state: :published, type: :publication }

    assert_select ".govuk-table__row" do
      assert_select ".govuk-table__cell:nth-child(1)", text: publication.title
      assert_select ".govuk-table__cell:nth-child(3)", text: "Published"
    end
  end

  view_test "should show force published editions as force published" do
    publication = create(:published_publication, force_published: true)
    get :index, params: { state: :published, type: :publication }

    assert_select ".govuk-table__row" do
      assert_select ".govuk-table__cell:nth-child(1)", text: publication.title
      assert_select ".govuk-table__cell:nth-child(3)", text: "Force published"
    end
  end

  view_test "should show force published editions when the filter is active" do
    publication = create(:published_publication, force_published: true)
    get :index, params: { state: :force_published, type: :publication }

    assert_select ".govuk-table__row" do
      assert_select ".govuk-table__cell:nth-child(1)", text: publication.title
      assert_select ".govuk-table__cell:nth-child(3)", text: "Force published"
    end
  end

  view_test "should display state information when viewing all active editions" do
    draft_edition = create(:draft_publication)
    submitted_edition = create(:submitted_publication)
    rejected_edition = create(:rejected_news_article)
    published_edition = create(:published_consultation)

    get :index, params: { state: :active }

    assert_select ".govuk-table__row" do
      assert_select ".govuk-table__cell:nth-child(1)", text: draft_edition.title do |cell|
        cell.first.parent.xpath("td[3]").text.strip == "Draft"
      end
    end

    assert_select ".govuk-table__row" do
      assert_select ".govuk-table__cell:nth-child(1)", text: submitted_edition.title do |cell|
        cell.first.parent.xpath("td[3]").text.strip == "Submitted"
      end
    end

    assert_select ".govuk-table__row" do
      assert_select ".govuk-table__cell:nth-child(1)", text: rejected_edition.title do |cell|
        cell.first.parent.xpath("td[3]").text.strip == "Rejected"
      end
    end

    assert_select ".govuk-table__row" do
      assert_select ".govuk-table__cell:nth-child(1)", text: published_edition.title do |cell|
        cell.first.parent.xpath("td[3]").text.strip == "Published"
      end
    end
  end

  view_test "index should not display limited access editions which I don't have access to" do
    my_organisation = create(:organisation)
    other_organisation = create(:organisation)
    login_as create(:writer, organisation: my_organisation)
    accessible = [
      create(:draft_publication),
      create(:draft_publication, publication_type: PublicationType::NationalStatistics, access_limited: true, organisations: [my_organisation]),
      create(:draft_publication, publication_type: PublicationType::NationalStatistics, access_limited: false, organisations: [other_organisation]),
    ]
    inaccessible = create(:draft_publication, publication_type: PublicationType::NationalStatistics, access_limited: true, organisations: [other_organisation])

    get :index, params: { state: :active }

    accessible.each do |edition|
      assert_select ".govuk-table__cell:nth-child(1)", text: edition.title
    end
    refute_select ".govuk-table__cell:nth-child(1)", text: inaccessible.title
  end

  view_test "index should indicate the protected status of limited access editions which I do have access to" do
    my_organisation = create(:organisation)
    login_as create(:writer, organisation: my_organisation)
    publication = create(:draft_publication, publication_type: PublicationType::NationalStatistics, access_limited: true, organisations: [my_organisation])

    get :index, params: { state: :active }

    assert_select ".govuk-table__row" do
      assert_select ".govuk-table__cell:nth-child(1)", text: publication.title
      assert_select ".govuk-table__cell:nth-child(3)", text: "Draft Limited access"
    end
  end

  test "prevents revising of access-limited editions" do
    my_organisation = create(:organisation)
    other_organisation = create(:organisation)
    login_as create(:writer, organisation: my_organisation)
    inaccessible = create(:draft_publication, publication_type: PublicationType::NationalStatistics, access_limited: true, organisations: [other_organisation])

    post :revise, params: { id: inaccessible }
    assert_response :forbidden
  end

  view_test "prevents oversized exports" do
    login_as :gds_editor
    Admin::EditionFilter.any_instance.stubs(exportable?: false)
    post :export,
         params: {
           include_last_author: true,
           include_link_check_reports: true,
           include_unpublishing: true,
           state: "active",
         }
    assert_equal "The document list is too large for export", flash[:alert]
  end

private

  def stub_edition_filter(attributes = {})
    default_attributes = {
      editions: Kaminari.paginate_array(attributes[:editions] || []).page(1),
      page_title: "",
      edition_state: "",
      valid?: true,
      options: {},
      hide_type: false,
    }
    stub("edition filter", default_attributes.merge(attributes.except(:editions)))
  end
end
