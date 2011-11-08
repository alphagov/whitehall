module DocumentControllerTestHelpers
  extend ActiveSupport::Concern

  def force_publish_button_selector(document)
    "form[action=#{admin_document_publishing_path(document, force: true)}]"
  end

  def reject_button_selector(document)
    "a[href=#{new_admin_document_editorial_remark_path(document)}]"
  end

  def link_to_public_version_selector
    ".actions .public_version"
  end

  module ClassMethods

    def should_be_able_to_delete_a_document(document_type)
      test "show displays the delete button for draft documents" do
        draft_document = create("draft_#{document_type}")

        get :show, id: draft_document

        destroy_path = send("admin_#{document_type}_path", draft_document)
        assert_select "form[action='#{destroy_path}']" do
          assert_select "input[name='_method'][type='hidden'][value='delete']"
          assert_select "input[type='submit'][value='Delete']"
        end
      end

      test "show displays the delete button for submitted documents" do
        submitted_document = create("submitted_#{document_type}")

        get :show, id: submitted_document

        destroy_path = send("admin_#{document_type}_path", submitted_document)
        assert_select "input[type='submit'][value='Delete']"
      end

      test "show does not display the delete button for published documents" do
        published_document = create("published_#{document_type}")

        get :show, id: published_document

        destroy_path = send("admin_#{document_type}_path", published_document)
        assert_select "input[type='submit'][value='Delete']", count: 0
      end

      test "show does not display the delete button for archived documents" do
        archived_document = create("archived_#{document_type}")

        get :show, id: archived_document

        destroy_path = send("admin_#{document_type}_path", archived_document)
        assert_select "input[type='submit'][value='Delete']", count: 0
      end

      test "destroy marks the document as deleted" do
        document = create("draft_#{document_type}")
        delete :destroy, id: document
        document.reload
        assert document.deleted?
      end

      test "destroying a draft document redirects to the draft documents page" do
        draft_document = create("draft_#{document_type}")
        delete :destroy, id: draft_document
        assert_redirected_to admin_documents_path
      end

      test "destroying a submitted document redirects to the submitted documents page" do
        submitted_document = create("submitted_#{document_type}")
        delete :destroy, id: submitted_document
        assert_redirected_to submitted_admin_documents_path
      end

      test "destroy displays a notice indicating the document has been deleted" do
        draft_document = create("draft_#{document_type}", title: "document-title")
        delete :destroy, id: draft_document
        assert_equal "The document 'document-title' has been deleted", flash[:notice]
      end
    end

    def should_link_to_public_version_when_published(document_type)
      test "should link to public version when published" do
        published_document = create("published_#{document_type}")
        get :show, id: published_document
        assert_select link_to_public_version_selector, count: 1
      end
    end

    def should_not_link_to_public_version_when_not_published(document_type)
      test "should not link to public version when not published" do
        draft_document = create("draft_#{document_type}")
        get :show, id: draft_document
        assert_select link_to_public_version_selector, count: 0
      end
    end

    def should_be_rejectable(document_type)
      document_type_class = document_type.to_s.classify.constantize

      test "should display the 'Reject' button" do
        document = create(document_type)
        document.stubs(:rejectable_by?).returns(true)
        document_type_class.stubs(:find).with(document.to_param).returns(document)
        get :show, id: document
        assert_select reject_button_selector(document), count: 1
      end

      test "shouldn't display the 'Reject' button" do
        document = create(document_type)
        document.stubs(:rejectable_by?).returns(false)
        document_type_class.stubs(:find).with(document.to_param).returns(document)
        get :show, id: document
        assert_select reject_button_selector(document), count: 0
      end

      test "should show who rejected the document and link to the comments" do
        document = create("rejected_#{document_type}")
        document.editorial_remarks.create!(body: "editorial-remark-body", author: @user)
        get :show, id: document
        assert_select ".rejected_by", text: @user.name
        assert_select "a[href=#editorial_remarks]"
      end

      test "should not show the editorial remarks section" do
        document = create("submitted_#{document_type}")
        get :show, id: document
        assert_select "#editorial_remarks", count: 0
      end

      test "should show the list of editorial remarks" do
        document = create("rejected_#{document_type}")
        remark = document.editorial_remarks.create!(body: "editorial-remark-body", author: @user)
        get :show, id: document
        assert_select "#editorial_remarks .editorial_remark" do
          assert_select ".body", text: "editorial-remark-body"
          assert_select ".author", text: @user.name
          assert_select "abbr.created_at[title=#{remark.created_at.iso8601}]"
        end
      end
    end

    def should_be_force_publishable(document_type)
      document_type_class = document_type.to_s.classify.constantize

      test "should display the 'Force Publish' button" do
        document = create(document_type)
        document.stubs(:publishable_by?).returns(false)
        document.stubs(:force_publishable_by?).returns(true)
        document_type_class.stubs(:find).with(document.to_param).returns(document)
        get :show, id: document
        assert_select force_publish_button_selector(document), count: 1
      end

      test "shouldn't display the 'Force Publish' button" do
        document = create(document_type)
        document.stubs(:publishable_by?).returns(false)
        document.stubs(:force_publishable_by?).returns(false)
        document_type_class.stubs(:find).with(document.to_param).returns(document)
        get :show, id: document
        assert_select force_publish_button_selector(document), count: 0
      end
    end
  end
end
