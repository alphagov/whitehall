require 'test_helper'

class Admin::EditionsController
  class EditionFilterTest < ActiveSupport::TestCase
    setup do
      @current_user = build(:user)
    end

    test "should filter by edition type" do
      policy = create(:policy)
      another_edition = create(:publication)

      assert_equal [policy], EditionFilter.new(Edition, @current_user, type: 'policy').editions
    end

    test "should filter by edition state" do
      draft_edition = create(:draft_policy)
      edition_in_other_state = create(:published_policy)

      assert_equal [draft_edition], EditionFilter.new(Edition, @current_user, state: 'draft').editions
    end

    test "should filter by edition author" do
      author = create(:user)
      edition = create(:policy, authors: [author])
      edition_by_another_author = create(:policy)

      assert_equal [edition], EditionFilter.new(Edition, @current_user, author: author.to_param).editions
    end

    test "should filter by organisation" do
      organisation = create(:organisation)
      edition = create(:policy, organisations: [organisation])
      edition_in_no_organisation = create(:policy)
      edition_in_another_organisation = create(:publication, organisations: [create(:organisation)])

      assert_equal [edition], EditionFilter.new(Edition, @current_user, organisation: organisation.to_param).editions
    end

    test "should filter by edition type, state and author" do
      author = create(:user)
      policy = create(:draft_policy, authors: [author])
      another_edition = create(:published_policy, authors: [author])

      assert_equal [policy], EditionFilter.new(Edition, @current_user, type: 'policy', state: 'draft', author: author.to_param).editions
    end

    test "should filter by edition type, state and organisation" do
      organisation = create(:organisation)
      policy = create(:draft_policy, organisations: [organisation])
      another_edition = create(:published_policy, organisations: [organisation])

      assert_equal [policy], EditionFilter.new(Edition, @current_user, type: 'policy', state: 'draft', organisation: organisation.to_param).editions
    end

    test "should filter by title" do
      detailed = create(:policy, title: "Test mcTest")
      policy = create(:policy, title: "A policy")

      assert_equal [detailed], EditionFilter.new(Edition, @current_user, title: "test").editions
    end

    test "should return the editions ordered by most recent first" do
      older_policy = create(:draft_policy, updated_at: 3.days.ago)
      newer_policy = create(:draft_policy, updated_at: 1.minute.ago)

      assert_equal [newer_policy, older_policy], EditionFilter.new(Edition, @current_user, {}).editions
    end

    test "should provide efficient access to edition creators" do
      create(:policy)
      create(:publication)
      create(:speech)
      create(:consultation)

      query_count = count_queries do
        editions = EditionFilter.new(Edition, @current_user).editions
        editions.each { |d| d.creator.name }
      end

      expected_queries = [:query_for_all_editions, :query_for_all_edition_authors, :query_for_all_users]
      assert_equal expected_queries.length, query_count
    end

    test "should be invalid if author can't be found" do
      filter = EditionFilter.new(Edition, @current_user, author: 'invalid')
      refute filter.valid?
    end

    test "should be invalid if organisation can't be found" do
      filter = EditionFilter.new(Edition, @current_user, organisation: 'invalid')
      refute filter.valid?
    end

    test "should generate page title when there are no filter options" do
      filter = EditionFilter.new(Edition, build(:user))
      assert_equal "Everyone's documents", filter.page_title
    end

    test "should generate page title when we're displaying active documents" do
      filter = EditionFilter.new(Edition, build(:user), state: 'active')
      assert_equal "Everyone's documents", filter.page_title
    end

    test "should generate page title when filtering by document state" do
      filter = EditionFilter.new(Edition, build(:user), state: 'draft')
      assert_equal "Everyone's draft documents", filter.page_title
    end

    test "should generate page title when filtering by document type" do
      filter = EditionFilter.new(Edition, build(:user), type: 'news_article')
      assert_equal "Everyone's news articles", filter.page_title
    end

    test "should generate page title when filtering by any organisation" do
      organisation = create(:organisation, name: "Cabinet Office")
      filter = EditionFilter.new(Edition, build(:user), organisation: organisation.to_param)
      assert_equal "Cabinet Office's documents", filter.page_title
    end

    test "should generate page title when filtering by my organisation" do
      organisation = create(:organisation)
      user = create(:user, organisation: organisation)
      filter = EditionFilter.new(Edition, user, organisation: organisation.to_param)
      assert_equal "My department's documents", filter.page_title
    end

    test "should generate page title when filtering by any author" do
      user = create(:user, name: 'John Doe')
      filter = EditionFilter.new(Edition, build(:user), author: user.to_param)
      assert_equal "John Doe's documents", filter.page_title
    end

    test "should generate page title when filtering by my documents" do
      user = create(:user)
      filter = EditionFilter.new(Edition, user, author: user.to_param)
      assert_equal "My documents", filter.page_title
    end

    test "should generate page title when filtering by document state, document type and organisation" do
      organisation = create(:organisation, name: 'Cabinet Office')
      filter = EditionFilter.new(Edition, build(:user), state: 'published', type: 'consultation', organisation: organisation.to_param)
      assert_equal "Cabinet Office's published consultations", filter.page_title
    end

    test "should generate page title when filtering by document state, document type and author" do
      user = create(:user, name: 'John Doe')
      filter = EditionFilter.new(Edition, build(:user), state: 'rejected', type: 'speech', author: user.to_param)
      assert_equal "John Doe's rejected speeches", filter.page_title
    end

    test "should generate page title when filtering by title" do
      filter = EditionFilter.new(Edition, build(:user), title: 'test')
      assert_equal "Everyone's documents that match 'test'", filter.page_title
    end
  end
end

class Admin::EditionsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test 'should pass filter parameters to an edition filter' do
    stub_filter = stub_edition_filter
    Admin::EditionsController::EditionFilter.expects(:new).with(anything, anything, {"state" => "draft", "type" => "policy"}).returns(stub_filter)

    get :index, state: :draft, type: :policy
  end

  test "should not pass blank parameters to the edition filter" do
    stub_filter = stub_edition_filter
    Admin::EditionsController::EditionFilter.expects(:new).with(anything, anything, {"state" => "draft"}).returns(stub_filter)

    get :index, state: :draft, author: ""
  end

  test 'should strip out any invalid states passed as parameters' do
    stub_filter = stub_edition_filter
    Admin::EditionsController::EditionFilter.expects(:new).with(anything, anything, {"type" => "policy"}).returns(stub_filter)

    get :index, state: :haxxor_method, type: :policy
  end

  test 'should distinguish between edition types when viewing the list of editions' do
    policy = create(:draft_policy)
    publication = create(:draft_publication)
    stub_filter = stub_edition_filter(editions: [policy, publication])
    Admin::EditionsController::EditionFilter.stubs(:new).returns(stub_filter)

    get :index, state: :draft

    assert_select_object(policy) { assert_select ".type", text: "Policy" }
    assert_select_object(publication) { assert_select ".type", text: "Publication" }
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
    assert_redirected_to admin_editions_path(state: :submitted, organisation: organisation)
  end

  test "index should render a list of drafts I have written if a writer has no remembered filters" do
    writer = login_as create(:policy_writer)
    get :index
    assert_redirected_to admin_editions_path(state: :draft, author: writer)
  end

  test "index should redirect to drafts if stored filter options are not valid for route building" do
    session[:document_filters] = { action: :unknown }
    get :index
    assert_redirected_to admin_editions_path(state: :draft)
  end

  test "should not show published editions as force published" do
    policy = create(:published_policy)
    get :index, state: :published, type: :policy

    assert_select_object(policy)
    refute_select "tr.force_published"
  end

  test "should show force published editions as force published" do
    policy = create(:published_policy, force_published: true)
    get :index, state: :published, type: :policy

    assert_select_object(policy)
    assert_select "tr.force_published"
  end

  test "should link to all active editions" do
    get :index, state: :draft

    assert_select "a[href='#{admin_editions_path(state: :active)}']"
  end

  test "should not display the featured column when viewing all active editions" do
    create(:published_news_article)

    get :index, state: :active, type: 'news_article'

    refute_select "th", text: "Featured"
    refute_select "td.featured"
  end

  test "should display state information when viewing all active editions" do
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

  test "should not display state information when viewing editions of a particular state" do
    draft_edition = create(:draft_policy)

    get :index, state: :draft

    assert_select_object(draft_edition) { refute_select ".state" }
  end

  test "index should not display limited access editions which I don't have access to" do
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

  test "index should indicate the protected status of limited access editions which I do have access to" do
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

    get :show, id: inaccessible
    assert_response 403

    get :edit, id: inaccessible
    assert_response 403

    put :update, id: inaccessible, edition: {summary: "new-summary"}
    assert_response 403

    post :revise, id: inaccessible
    assert_response 403

    delete :destroy, id: inaccessible
    assert_response 403
  end

  def stub_edition_filter(attributes = {})
    default_attributes = {
      editions: Kaminari.paginate_array(attributes[:editions] || []).page(1),
      page_title: '', edition_state: '', valid?: true
    }
    stub('edition filter', default_attributes.merge(attributes.except(:editions)))
  end
end
