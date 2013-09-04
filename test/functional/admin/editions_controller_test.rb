require 'test_helper'

class Admin::EditionsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test 'should pass filter parameters to an edition filter' do
    stub_filter = stub_edition_filter
    Admin::EditionFilter.expects(:new).with(anything, anything, has_entries("state" => "draft", "type" => "policy")).returns(stub_filter)

    get :index, state: :draft, type: :policy
  end

  test "should not pass blank parameters to the edition filter" do
    stub_filter = stub_edition_filter
    Admin::EditionFilter.expects(:new).with(anything, anything, Not(has_key("author"))).returns(stub_filter)

    get :index, state: :draft, author: ""
  end

  test 'should strip out any invalid states passed as parameters and replace them with "active"' do
    stub_filter = stub_edition_filter
    Admin::EditionFilter.expects(:new).with(anything, anything, has_entry("state" => "active")).returns(stub_filter)

    get :index, state: :haxxor_method, type: :policy
  end

  test 'should add state param set to "active" if none is supplied' do
    stub_filter = stub_edition_filter
    Admin::EditionFilter.expects(:new).with(anything, anything, has_entry("state" => "active")).returns(stub_filter)

    get :index, type: :policy
  end

  view_test 'should distinguish between edition types when viewing the list of editions' do
    policy = create(:draft_policy)
    publication = create(:draft_publication)
    stub_filter = stub_edition_filter(editions: [policy, publication])
    stub_filter.stubs(:show_stats)
    Admin::EditionFilter.stubs(:new).returns(stub_filter)

    get :index, state: :draft

    assert_select_object(policy) { assert_select ".type", text: "Policy" }
    assert_select_object(publication) { assert_select ".type", text: "Policy paper" }
  end

  test "diffing against a previous version" do
    policy = create(:draft_policy)
    editor = create(:departmental_editor)
    Edition::AuditTrail.whodunnit = editor
    policy.first_published_at = Time.zone.now
    policy.major_change_published_at = Time.zone.now
    policy.publish_as(editor, force: true)
    draft_policy = policy.reload.create_draft(editor)

    get :diff, id: draft_policy, audit_trail_entry_id: draft_policy.document_version_trail.first.version.item_id

    assert_response :success
    assert_template :diff
    assert_equal draft_policy, assigns(:edition)
    assert_equal policy, assigns(:audit_trail_entry)
  end

  test "revising the published edition should create a new draft edition" do
    published_edition = create(:published_policy)
    Edition.stubs(:find).returns(published_edition)
    draft_edition = create(:draft_policy)
    published_edition.expects(:create_draft).with(current_user).returns(draft_edition)

    post :revise, id: published_edition
  end

  test "revising a published edition redirects to edit for the new draft" do
    published_edition = create(:published_policy)

    post :revise, id: published_edition

    draft_edition = Edition.last
    assert_redirected_to edit_admin_policy_path(draft_edition.reload)
  end

  test "failing to revise an edition should redirect to the existing draft" do
    published_edition = create(:published_policy)
    existing_draft = create(:draft_policy, document: published_edition.document)

    post :revise, id: published_edition

    assert_redirected_to edit_admin_policy_path(existing_draft)
    assert_equal "There is already an active draft edition for this document", flash[:alert]
  end

  test "failing to revise an edition should redirect to the existing submitted edition" do
    published_edition = create(:published_policy)
    existing_submitted = create(:submitted_policy, document: published_edition.document)

    post :revise, id: published_edition

    assert_redirected_to edit_admin_policy_path(existing_submitted)
    assert_equal "There is already an active submitted edition for this document", flash[:alert]
  end

  test "failing to revise an edition should redirect to the existing rejected edition" do
    published_edition = create(:published_publication)
    existing_rejected = create(:rejected_publication, document: published_edition.document)

    post :revise, id: published_edition

    assert_redirected_to edit_admin_publication_path(existing_rejected)
    assert_equal "There is already an active rejected edition for this document", flash[:alert]
  end

  test "should remember standard filter options" do
    get :index, state: :draft, type: 'consultation'
    assert_equal 'consultation', session[:document_filters][:type]
  end

  test "should remember author filter options" do
    get :index, state: :draft, author: current_user
    assert_equal current_user.to_param, session[:document_filters][:author]
  end

  test "should remember organisation filter options" do
    organisation = create(:organisation)
    get :index, state: :draft, organisation: organisation
    assert_equal organisation.to_param, session[:document_filters][:organisation]
  end

  test "should remember state filter options" do
    get :index, state: :draft
    assert_equal 'draft', session[:document_filters][:state]
  end

  test "should remember title filter options" do
    get :index, title: "test"
    assert_equal "test", session[:document_filters][:title]
  end

  test "index should redirect to remembered filtered options if available" do
    organisation = create(:organisation)
    session[:document_filters] = { state: :submitted, author: current_user.to_param, organisation: organisation.to_param }
    get :index
    assert_redirected_to admin_editions_path(state: :submitted, author: current_user, organisation: organisation)
  end

  test "index should redirect to remembered filtered options if selected filter is invalid" do
    organisation = create(:organisation)
    session[:document_filters] = { state: :submitted, author: current_user.to_param, organisation: organisation.to_param }
    stub_edition_filter valid?: false
    get :index, author: 'invalid'
    assert_redirected_to admin_editions_path(state: :submitted, author: current_user, organisation: organisation)
  end

  test "index should redirect to submitted in my department if logged an editor has no remembered filters" do
    organisation = create(:organisation)
    editor = login_as create(:departmental_editor, organisation: organisation)
    get :index
    assert_redirected_to admin_editions_path(state: :submitted, organisation: organisation.id)
  end

  test "index should render a list of drafts I have written if a writer has no remembered filters" do
    writer = login_as create(:policy_writer)
    get :index
    assert_redirected_to admin_editions_path(state: :draft, author: writer)
  end

  view_test "should not show published editions as force published" do
    policy = create(:published_policy)
    get :index, state: :published, type: :policy

    assert_select_object(policy)
    refute_select "tr.force_published"
  end

  view_test "should show force published editions as force published" do
    policy = create(:published_policy, force_published: true)
    get :index, state: :published, type: :policy

    assert_select_object(policy)
    assert_select "tr.force_published"
  end

  view_test "should show force published editions when the filter is active" do
    policy = create(:published_policy, force_published: true)
    get :index, state: :force_published, type: :policy

    assert_select_object(policy)
    assert_select "tr.force_published"
  end

  test "should not display the featured column when viewing all active editions" do
    create(:published_news_article)

    get :index, state: :active, type: 'news_article'

    refute_select "th", text: "Featured"
    refute_select "td.featured"
  end

  view_test "should display state information when viewing all active editions" do
    draft_edition = create(:draft_policy)
    imported_edition = create(:imported_edition)
    submitted_edition = create(:submitted_publication)
    rejected_edition = create(:rejected_news_article)
    published_edition = create(:published_consultation)

    get :index, state: :active

    assert_select_object(draft_edition) { assert_select ".state", "Draft" }
    assert_select_object(imported_edition) { assert_select ".state", "Imported" }
    assert_select_object(submitted_edition) { assert_select ".state", "Submitted" }
    assert_select_object(rejected_edition) { assert_select ".state", "Rejected" }
    assert_select_object(published_edition) { assert_select ".state", "Published" }
  end

  view_test "should not display state information when viewing editions of a particular state" do
    draft_edition = create(:draft_policy)

    get :index, state: :draft

    assert_select_object(draft_edition) { refute_select ".state" }
  end

  view_test "index should not display limited access editions which I don't have access to" do
    my_organisation, other_organisation = create(:organisation), create(:organisation)
    login_as(create(:user, organisation: my_organisation))
    accessible = [
      create(:draft_policy),
      create(:draft_publication, publication_type: PublicationType::NationalStatistics, access_limited: true, organisations: [my_organisation]),
      create(:draft_publication, publication_type: PublicationType::NationalStatistics, access_limited: false, organisations: [other_organisation])
    ]
    inaccessible = create(:draft_publication, publication_type: PublicationType::NationalStatistics, access_limited: true, organisations: [other_organisation])

    get :index, state: :active

    accessible.each do |edition|
      assert_select_object(edition)
    end
    refute_select_object(inaccessible)
  end

  view_test "index should indicate the protected status of limited access editions which I do have access to" do
    my_organisation = create(:organisation)
    login_as(create(:user, organisation: my_organisation))
    publication = create(:draft_publication, publication_type: PublicationType::NationalStatistics, access_limited: true, organisations: [my_organisation])

    get :index, state: :active

    assert_select_object(publication) do
      assert_select "span", "limited access"
    end
  end

  test "should prevent viewing or modification of limited access editions which I don't have access to" do
    my_organisation, other_organisation = create(:organisation), create(:organisation)
    login_as(create(:user, organisation: my_organisation))
    inaccessible = create(:draft_publication, publication_type: PublicationType::NationalStatistics, access_limited: true, organisations: [other_organisation])
    controller.stubs(:can?).returns(true)

    get :show, id: inaccessible
    assert_response :forbidden

    get :edit, id: inaccessible
    assert_response :forbidden

    put :update, id: inaccessible, edition: {summary: "new-summary"}
    assert_response :forbidden

    post :revise, id: inaccessible
    assert_response :forbidden

    delete :destroy, id: inaccessible
    assert_response :forbidden
  end

  test "confirm_unpublish loads the edition and renders the confirm page" do
    login_as(create(:gds_editor))
    policy = create(:published_policy)
    get :confirm_unpublish, id: policy.to_param

    assert_response :success
    assert_template :confirm_unpublish
    assert_equal policy, assigns(:edition)
  end

  def stub_edition_filter(attributes = {})
    default_attributes = {
      editions: Kaminari.paginate_array(attributes[:editions] || []).page(1),
      page_title: '', edition_state: '', valid?: true,
      options: {}
    }
    stub('edition filter', default_attributes.merge(attributes.except(:editions)))
  end
end
