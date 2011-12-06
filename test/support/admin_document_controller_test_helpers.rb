module AdminDocumentControllerTestHelpers
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
    def should_allow_attachments_for(document_type)
      document_class = document_class(document_type)

      test "new displays document attachment fields" do
        get :new

        assert_select "form#document_new" do
          assert_select "input[name='document[attachments_attributes][0][file]'][type='file']"
        end
      end

      test 'creating a document should attach file' do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        attributes = attributes_for(document_type)
        attributes[:attachments_attributes] = { "0" => { file: greenpaper_pdf } }

        post :create, document: attributes

        assert document = document_class.last
        assert_equal 1, document.attachments.length
        attachment = document.attachments.first
        assert_equal "greenpaper.pdf", attachment.carrierwave_file
        assert_equal "application/pdf", attachment.content_type
        assert_equal greenpaper_pdf.size, attachment.file_size
      end

      test "creating a document with invalid data should still allow attachment to be selected for upload" do
        post :create, document: attributes_for(document_type, title: "")

        assert_select "form#document_new" do
          assert_select "input[name='document[attachments_attributes][0][file]'][type='file']"
        end
      end

      test "creating a document with invalid data should only allow a single attachment to be selected for upload" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')

        post :create, document: attributes_for(document_type,
          title: "",
          attachments_attributes: { "0" => { file: greenpaper_pdf } }
        )

        assert_select "form#document_new" do
          assert_select "input[name*='document[attachments_attributes]'][type='file']", count: 1
        end
      end

      test "creating a document with invalid data and an attachment should remember the uploaded file" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')

        post :create, document: attributes_for(document_type,
          title: "",
          attachments_attributes: { "0" => { file: greenpaper_pdf } }
        )

        assert_select "form#document_new" do
          assert_select "input[name='document[attachments_attributes][0][file_cache]'][type='hidden'][value$='greenpaper.pdf']"
          assert_select ".already_uploaded", text: "greenpaper.pdf already uploaded"
        end
      end

      test 'creating a document with invalid data should not show any attachment info' do
        attributes = attributes_for(document_type)
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')
        attributes[:attachments_attributes] = { "0" => { file: greenpaper_pdf } }

        post :create, document: attributes.merge(title: '')

        refute_select "p.attachment"
      end

      test 'edit displays document attachment fields' do
        document = create(document_type)

        get :edit, id: document

        assert_select "form#document_edit" do
          assert_select "input[name='document[attachments_attributes][0][file]'][type='file']"
        end
      end

      test 'updating a document should attach file' do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        document = create(document_type)

        put :update, id: document, document: document.attributes.merge(
          attachments_attributes: { "0" => { file: greenpaper_pdf } }
        )

        document.reload
        assert_equal 1, document.attachments.length
        attachment = document.attachments.first
        assert_equal "greenpaper.pdf", attachment.carrierwave_file
        assert_equal "application/pdf", attachment.content_type
        assert_equal greenpaper_pdf.size, attachment.file_size
      end

      test "updating a document with invalid data should still allow attachment to be selected for upload" do
        document = create(document_type)
        put :update, id: document, document: document.attributes.merge(title: "")

        assert_select "form#document_edit" do
          assert_select "input[name='document[attachments_attributes][0][file]'][type='file']"
        end
      end

      test "updating a document with invalid data should only allow a single attachment to be selected for upload" do
        document = create(document_type)
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')

        put :update, id: document, document: attributes_for(document_type,
          title: "",
          attachments_attributes: { "0" => { file: greenpaper_pdf } }
        )

        assert_select "form#document_edit" do
          assert_select "input[name*='document[attachments_attributes]'][type='file']", count: 1
        end
      end

      test "updating a document with invalid data and an attachment should remember the uploaded file" do
        document = create(document_type)
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')

        put :update, id: document, document: attributes_for(document_type,
          title: "",
          attachments_attributes: { "0" => { file: greenpaper_pdf } }
        )

        assert_select "form#document_edit" do
          assert_select "input[name='document[attachments_attributes][0][file_cache]'][type='hidden'][value$='greenpaper.pdf']"
          assert_select ".already_uploaded", text: "greenpaper.pdf already uploaded"
        end
      end

      test "updating a stale document should still allow attachment to be selected for upload" do
        document = create("draft_#{document_type}")
        lock_version = document.lock_version
        document.touch

        put :update, id: document, document: document.attributes.merge(lock_version: lock_version)

        assert_select "form#document_edit" do
          assert_select "input[name='document[attachments_attributes][0][file]'][type='file']"
        end
      end

      test "updating a stale document should only allow a single attachment to be selected for upload" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')
        document = create("draft_#{document_type}")
        lock_version = document.lock_version
        document.touch

        put :update, id: document, document: document.attributes.merge(
          lock_version: lock_version,
          attachments_attributes: { "0" => { file: greenpaper_pdf } }
        )

        assert_select "form#document_edit" do
          assert_select "input[name*='document[attachments_attributes]'][type='file']", count: 1
        end
      end

      test 'updating should allow removal of attachments' do
        attachment_1 = create(:attachment)
        attachment_2 = create(:attachment)
        document = create(document_type)
        document_attachment_1 = create(:document_attachment, document: document, attachment: attachment_1)
        document_attachment_2 = create(:document_attachment, document: document, attachment: attachment_2)

        put :update, id: document, document: document.attributes.merge(
          document_attachments_attributes: {
            "0" => {id: document_attachment_1.id.to_s, _destroy: "1"},
            "1" => {id: document_attachment_2.id.to_s, _destroy: "0"}
          },
          attachments_attributes: {
            "0" => {file_cache: ""}
          }
        )

        refute_select ".errors"
        document.reload
        assert_equal [attachment_2], document.attachments
      end
    end

    def should_display_attachments_for(document_type)
      test "should display PDF attachment metadata" do
        two_page_pdf = fixture_file_upload('two-pages.pdf', 'application/pdf')
        attachment = create(:attachment, file: two_page_pdf)
        document = create(document_type, attachments: [attachment])

        get :show, id: document

        assert_select_object(attachment) do
          assert_select "a", text: document.attachments.first.filename
          assert_select ".type", "PDF"
          assert_select ".number_of_pages", "2 pages"
          assert_select ".size", "1.41 KB"
        end
      end

      test "should display CSV attachment metadata" do
        csv = fixture_file_upload('sample-from-excel.csv', 'text/csv')
        attachment = create(:attachment, file: csv)
        document = create(document_type, attachments: [attachment])

        get :show, id: document

        assert_select_object(attachment) do
          assert_select "a", text: document.attachments.first.filename
          assert_select ".type", "CSV"
          refute_select ".number_of_pages"
          assert_select ".size", "121 Bytes"
        end
      end
    end

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
        refute_select "input[type='submit'][value='Delete']"
      end

      test "show does not display the delete button for archived documents" do
        archived_document = create("archived_#{document_type}")

        get :show, id: archived_document

        destroy_path = send("admin_#{document_type}_path", archived_document)
        refute_select "input[type='submit'][value='Delete']"
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
        refute_select link_to_public_version_selector
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
        refute_select reject_button_selector(document)
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
        refute_select "#editorial_remarks"
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
      document_class = document_class(document_type)

      test "should display the 'Force Publish' button" do
        document = create(document_type)
        document.stubs(:publishable_by?).returns(false)
        document.stubs(:force_publishable_by?).returns(true)
        document_class.stubs(:find).with(document.to_param).returns(document)
        get :show, id: document
        assert_select force_publish_button_selector(document), count: 1
      end

      test "shouldn't display the 'Force Publish' button" do
        document = create(document_type)
        document.stubs(:publishable_by?).returns(false)
        document.stubs(:force_publishable_by?).returns(false)
        document_class.stubs(:find).with(document.to_param).returns(document)
        get :show, id: document
        refute_select force_publish_button_selector(document)
      end
    end

    def should_allow_organisations_for(document_type)
      document_class = document_class(document_type)

      test "new should display document organisations field" do
        get :new

        assert_select "form#document_new" do
          assert_select "select[name*='document[organisation_ids]']"
        end
      end

      test "create should associate organisations with document" do
        first_organisation = create(:organisation)
        second_organisation = create(:organisation)
        attributes = attributes_for(document_type)

        post :create, document: attributes.merge(
          organisation_ids: [first_organisation.id, second_organisation.id]
        )

        document = document_class.last
        assert_equal [first_organisation, second_organisation], document.organisations
      end

      test "edit should display document organisations field" do
        document = create(document_type)

        get :edit, id: document

        assert_select "form#document_edit" do
          assert_select "select[name*='document[organisation_ids]']"
        end
      end

      test "update should associate organisations with documents" do
        first_organisation = create(:organisation)
        second_organisation = create(:organisation)

        document = create(document_type, organisations: [first_organisation])

        put :update, id: document, document: {
          organisation_ids: [second_organisation.id]
        }

        document.reload
        assert_equal [second_organisation], document.organisations
      end

      test "update should remove all organisations if none specified" do
        organisation = create(:organisation)

        document = create(document_type, organisations: [organisation])

        put :update, id: document, document: {}

        document.reload
        assert_equal [], document.organisations
      end
    end

    def should_allow_ministerial_roles_for(document_type)
      document_class = document_class(document_type)

      test "new should display document ministerial roles field" do
        get :new

        assert_select "form#document_new" do
          assert_select "select[name*='document[ministerial_role_ids]']"
        end
      end

      test "create should associate ministerial roles with document" do
        first_minister = create(:ministerial_role)
        second_minister = create(:ministerial_role)
        attributes = attributes_for(document_type)

        post :create, document: attributes.merge(
          ministerial_role_ids: [first_minister.id, second_minister.id]
        )

        document = document_class.last
        assert_equal [first_minister, second_minister], document.ministerial_roles
      end

      test "edit should display document ministerial roles field" do
        document = create(document_type)

        get :edit, id: document

        assert_select "form#document_edit" do
          assert_select "select[name*='document[ministerial_role_ids]']"
        end
      end

      test "update should associate ministerial roles with documents" do
        first_minister = create(:ministerial_role)
        second_minister = create(:ministerial_role)

        document = create(document_type, ministerial_roles: [first_minister])

        put :update, id: document, document: {
          ministerial_role_ids: [second_minister.id]
        }

        document.reload
        assert_equal [second_minister], document.ministerial_roles
      end

      test "update should remove all ministerial roles if none specified" do
        minister = create(:ministerial_role)

        document = create(document_type, ministerial_roles: [minister])

        put :update, id: document, document: {}

        document.reload
        assert_equal [], document.ministerial_roles
      end
    end

    private

    def document_class(document_type)
      document_type.to_s.classify.constantize
    end
  end
end
