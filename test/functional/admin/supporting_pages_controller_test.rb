require "test_helper"

class Admin::SupportingPagesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller
  should_allow_attachments_for :supporting_page

  def process(action, parameters, session, flash, method)
    parameters ||= {}
    if !parameters.has_key?(:edition_id)
      edition = if parameters[:id]
        parameters[:id].edition
      else
        create(:draft_policy)
      end
      parameters = parameters.merge(edition_id: edition)
    end
    super(action, parameters, session, flash, method)
  end

  view_test "new form has title and body inputs" do
    edition = create(:draft_policy)

    get :new, edition_id: edition

    assert_select "form[action='#{admin_edition_supporting_pages_path(edition)}']" do
      assert_select "input[name='supporting_page[title]'][type='text']"
      assert_select "textarea[name='supporting_page[body]']"
      assert_select "input[type='submit']"
    end
  end

  view_test "new form has previewable body" do
    edition = create(:draft_policy)

    get :new, edition_id: edition

    assert_select "textarea[name='supporting_page[body]'].previewable"
  end

  test "create adds supporting page" do
    edition = create(:draft_policy)
    attributes = { title: "title", body: "body" }
    post :create, edition_id: edition, supporting_page: attributes

    assert supporting_page = edition.supporting_pages.last
    assert_equal attributes[:title], supporting_page.title
    assert_equal attributes[:body], supporting_page.body
  end

  test "create should redirect to the edition page" do
    policy = create(:draft_policy)
    attributes = { title: "title", body: "body" }
    post :create, edition_id: policy, supporting_page: attributes

    assert_redirected_to admin_policy_path(policy)
    assert_equal flash[:notice], "The supporting page was added successfully"
  end

  test "create should render the form when attributes are invalid" do
    edition = create(:draft_policy)
    invalid_attributes = { title: nil, body: "body" }
    post :create, edition_id: edition, supporting_page: invalid_attributes

    assert_template "new"
    assert_equal "There was a problem: Title can't be blank", flash[:alert]
  end

  test "shows version of supporting page linked to given edition" do
    previous_edition = create(:published_policy)
    previous_supporting_page = create(:supporting_page, edition: previous_edition)
    edition = previous_edition.create_draft(create(:policy_writer))
    supporting_page = edition.supporting_pages.first

    get :show, edition_id: edition, id: supporting_page

    assert_equal supporting_page, assigns(:supporting_page)
  end

  view_test "shows the title and a link back to the parent" do
    edition = create(:draft_policy)
    supporting_page = create(:supporting_page, edition: edition)

    get :show, edition_id: edition, id: supporting_page

    assert_select ".title", supporting_page.title
    assert_select "a[href='#{admin_policy_path(edition)}']", text: "Back to &#x27;#{edition.title}&#x27;"
  end

  view_test "shows the body using govspeak markup" do
    supporting_page = create(:supporting_page, body: "body-in-govspeak")
    govspeak_transformation_fixture "body-in-govspeak" => "body-in-html" do
      get :show, edition_id: supporting_page.edition, id: supporting_page
    end

    assert_select ".body", text: "body-in-html"
  end

  view_test "shows edit link if parent edition is not published" do
    edition = create(:draft_policy)
    supporting_page = create(:supporting_page, edition: edition)

    get :show, edition_id: edition, id: supporting_page

    assert_select "a[href='#{edit_admin_supporting_page_path(supporting_page)}']", text: 'Edit'
  end

  view_test "does not show edit link if parent edition is published" do
    edition = create(:published_policy)
    supporting_page = create(:supporting_page, edition: edition)

    get :show, edition_id: edition, id: supporting_page

    refute_select "a[href='#{edit_admin_supporting_page_path(supporting_page)}']"
  end

  view_test "edit form has title and body inputs" do
    edition = create(:draft_policy)
    supporting_page = create(:supporting_page, edition: edition)

    get :edit, edition_id: edition, id: supporting_page

    assert_select "form[action='#{admin_supporting_page_path(supporting_page)}']" do
      assert_select "input[name='supporting_page[title]'][type='text'][value='#{supporting_page.title}']"
      assert_select "textarea[name='supporting_page[body]']", text: supporting_page.body
      assert_select "input[type='submit']"
    end
  end

  view_test "edit form has previewable body" do
    edition = create(:draft_policy)
    supporting_page = create(:supporting_page, edition: edition)

    get :edit, edition_id: edition, id: supporting_page

    assert_select "textarea[name='supporting_page[body]'].previewable"
  end

  view_test "edit form include lock version to prevent conflicting changes overwriting each other" do
    edition = create(:draft_policy)
    supporting_page = create(:supporting_page, edition: edition)

    get :edit, edition_id: edition, id: supporting_page

    assert_select "form[action='#{admin_supporting_page_path(supporting_page)}']" do
      assert_select "input[name='supporting_page[lock_version]'][type='hidden'][value='#{supporting_page.lock_version}']"
    end
  end

  test "edit works when the supporting page has an attachment" do
   supporting_page = create(:supporting_page, attachments: [create(:file_attachment)])

    get :edit, edition_id: supporting_page.edition, id: supporting_page

    assert_response :success
  end

  test "update modifies supporting page" do
    supporting_page = create(:supporting_page)

    attributes = { title: "new-title", body: "new-body" }
    put :update, edition_id: supporting_page.edition, id: supporting_page, supporting_page: attributes

    supporting_page.reload
    assert_equal attributes[:title], supporting_page.title
    assert_equal attributes[:body], supporting_page.body
  end

  test "update should redirect to the supporting page" do
    supporting_page = create(:supporting_page)

    attributes = { title: "new-title", body: "new-body" }
    put :update, edition_id: supporting_page.edition, id: supporting_page, supporting_page: attributes

    assert_redirected_to admin_supporting_page_path(supporting_page)
    assert_equal flash[:notice], "The supporting page was updated successfully"
  end

  test "update should render the form when attributes are invalid" do
    supporting_page = create(:supporting_page)

    attributes = { title: nil, body: "new-body" }
    put :update, edition_id: supporting_page.edition, id: supporting_page, supporting_page: attributes

    assert_template "edit"
    assert_equal "There was a problem: Title can't be blank", flash[:alert]
  end

  test "updating a stale supporting page should render edit page with conflicting supporting page" do
    supporting_page = create(:supporting_page)
    lock_version = supporting_page.lock_version
    supporting_page.touch

    attributes = { title: "new-title", body: "new-body" }
    put :update, edition_id: supporting_page.edition, id: supporting_page, supporting_page: attributes.merge(lock_version: lock_version)

    assert_template 'edit'
    conflicting_supporting_page = supporting_page.reload
    assert_equal conflicting_supporting_page, assigns(:conflicting_supporting_page)
    assert_equal conflicting_supporting_page.lock_version, assigns(:supporting_page).lock_version
    assert_equal %(This page has been saved since you opened it. Your version appears at the top and the latest version appears at the bottom. Please incorporate any relevant changes into your version and then save it.), flash[:alert]
  end

  test "should be able to destroy a destroyable supporting page" do
    edition = create(:draft_policy)
    supporting_page = create(:supporting_page, edition: edition, title: "Blah blah")

    delete :destroy, edition_id: edition, id: supporting_page.id

    assert_redirected_to admin_policy_path(edition)
    refute SupportingPage.find_by_id(supporting_page.id)
    assert_equal %{"Blah blah" destroyed.}, flash[:notice]
  end

  test "destroying an indestructible role" do
    edition = create(:published_policy)
    supporting_page = create(:supporting_page, edition: edition, title: "Blah blah")

    delete :destroy, edition_id: edition, id: supporting_page.id

    assert_redirected_to admin_policy_path(edition)
    assert SupportingPage.find_by_id(supporting_page.id)
    assert_equal "Cannot destroy a supporting page that has been published", flash[:alert]
  end

  test "should limit edition access" do
    protected_edition = create(:protected_edition)
    get :show, edition_id: protected_edition.id, id: "2"

    assert_response :forbidden
  end

  def controller_attributes_for(edition_type, attributes = {})
    super.reject { |k,_| [:lead_organisation_ids, :supporting_organisation_ids].include? k }
  end
end
