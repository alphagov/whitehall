require "test_helper"

class Admin::SupportingDocumentsControllerTest < ActionController::TestCase
  setup do
    @user = login_as :policy_writer
  end

  test 'is an admin controller' do
    assert @controller.is_a?(Admin::BaseController), "the controller should have the behaviour of an Admin::BaseController"
  end

  test "new form has title and body inputs" do
    document = create(:draft_policy)

    get :new, document_id: document

    assert_select "form[action='#{admin_document_supporting_documents_path(document)}']" do
      assert_select "input[name='supporting_document[title]'][type='text']"
      assert_select "textarea[name='supporting_document[body]']"
      assert_select "input[type='submit']"
    end
  end

  test "new form has previewable body" do
    document = create(:draft_policy)

    get :new, document_id: document

    assert_select "textarea[name='supporting_document[body]'].previewable"
  end

  test "create adds supporting document" do
    document = create(:draft_policy)
    attributes = { title: "title", body: "body" }
    post :create, document_id: document, supporting_document: attributes

    assert supporting_document = document.supporting_documents.last
    assert_equal attributes[:title], supporting_document.title
    assert_equal attributes[:body], supporting_document.body
  end

  test "create should redirect to the document page" do
    policy = create(:draft_policy)
    attributes = { title: "title", body: "body" }
    post :create, document_id: policy, supporting_document: attributes

    assert_redirected_to admin_policy_path(policy)
    assert_equal flash[:notice], "The supporting document was added successfully"
  end

  test "create should render the form when attributes are invalid" do
    document = create(:draft_policy)
    invalid_attributes = { title: nil, body: "body" }
    post :create, document_id: document, supporting_document: invalid_attributes

    assert_template "new"
    assert_equal "There was a problem: Title can't be blank", flash[:alert]
  end

  test "shows the title and a link back to the parent" do
    document = create(:draft_policy)
    supporting_document = create(:supporting_document, document: document)

    get :show, id: supporting_document

    assert_select ".title", supporting_document.title
    assert_select "a[href='#{admin_policy_path(document)}']", text: "Back to '#{document.title}'"
  end

  test "shows the body using govspeak markup" do
    supporting_document = create(:supporting_document, body: "body-in-govspeak")
    Govspeak::Document.stubs(:to_html).with("body-in-govspeak").returns("body-in-html")

    get :show, id: supporting_document

    assert_select ".body", text: "body-in-html"
  end

  test "shows edit link if parent document is not published" do
    document = create(:draft_policy)
    supporting_document = create(:supporting_document, document: document)

    get :show, document_id: document, id: supporting_document

    assert_select "a[href='#{edit_admin_supporting_document_path(supporting_document)}']", text: 'Edit'
  end

  test "doesn't show edit link if parent document is published" do
    document = create(:published_policy)
    supporting_document = create(:supporting_document, document: document)

    get :show, document_id: document, id: supporting_document

    assert_select "a[href='#{edit_admin_supporting_document_path(supporting_document)}']", count: 0
  end

  test "edit form has title and body inputs" do
    document = create(:draft_policy)
    supporting_document = create(:supporting_document, document: document)

    get :edit, document_id: document, id: supporting_document

    assert_select "form[action='#{admin_supporting_document_path(supporting_document)}']" do
      assert_select "input[name='supporting_document[title]'][type='text'][value='#{supporting_document.title}']"
      assert_select "textarea[name='supporting_document[body]']", text: supporting_document.body
      assert_select "input[type='submit']"
    end
  end

  test "edit form has previewable body" do
    document = create(:draft_policy)
    supporting_document = create(:supporting_document, document: document)

    get :new, document_id: document, id: supporting_document

    assert_select "textarea[name='supporting_document[body]'].previewable"
  end

  test "edit form include lock version to prevent conflicting changes overwriting each other" do
    document = create(:draft_policy)
    supporting_document = create(:supporting_document, document: document)

    get :edit, document_id: document, id: supporting_document

    assert_select "form[action='#{admin_supporting_document_path(supporting_document)}']" do
      assert_select "input[name='supporting_document[lock_version]'][type='hidden'][value='#{supporting_document.lock_version}']"
    end
  end

  test "update modifies supporting document" do
    supporting_document = create(:supporting_document)

    attributes = { title: "new-title", body: "new-body" }
    put :update, id: supporting_document, supporting_document: attributes

    supporting_document.reload
    assert_equal attributes[:title], supporting_document.title
    assert_equal attributes[:body], supporting_document.body
  end

  test "update should redirect to the supporting document page" do
    supporting_document = create(:supporting_document)

    attributes = { title: "new-title", body: "new-body" }
    put :update, id: supporting_document, supporting_document: attributes

    assert_redirected_to admin_supporting_document_path(supporting_document)
    assert_equal flash[:notice], "The supporting document was updated successfully"
  end

  test "update should render the form when attributes are invalid" do
    supporting_document = create(:supporting_document)

    attributes = { title: nil, body: "new-body" }
    put :update, id: supporting_document, supporting_document: attributes

    assert_template "edit"
    assert_equal "There was a problem: Title can't be blank", flash[:alert]
  end

  test "updating a stale supporting document should render edit page with conflicting supporting document" do
    supporting_document = create(:supporting_document)
    lock_version = supporting_document.lock_version
    supporting_document.update_attributes!(title: "new title")

    attributes = { title: "new-title", body: "new-body" }
    put :update, id: supporting_document, supporting_document: attributes.merge(lock_version: lock_version)

    assert_template 'edit'
    conflicting_supporting_document = supporting_document.reload
    assert_equal conflicting_supporting_document, assigns[:conflicting_supporting_document]
    assert_equal conflicting_supporting_document.lock_version, assigns[:supporting_document].lock_version
    assert_equal %{This document has been saved since you opened it. Your version appears at the top and the latest version appears at the bottom. Please incorporate any relevant changes into your version and then save it.}, flash[:alert]
  end

end
