module AdminDocumentControllerTestHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def should_allow_showing_of(document_type)
      test "should render the content using govspeak markup" do
        draft_document = create("draft_#{document_type}", body: "body-in-govspeak")
        Govspeak::Document.stubs(:to_html).returns("\n")
        Govspeak::Document.stubs(:to_html).with("body-in-govspeak").returns("body-in-html")

        get :show, id: draft_document

        assert_select ".body", text: "body-in-html"
      end

      test "show lists each document author once" do
        tom = create(:user, name: "Tom")
        dick = create(:user, name: "Dick")
        harry = create(:user, name: "Harry")

        draft_document = create("draft_#{document_type}", creator: tom)
        draft_document.edit_as(dick)
        draft_document.edit_as(harry)
        draft_document.edit_as(dick)

        get :show, id: draft_document

        assert_select ".authors", text: "Tom, Dick, and Harry"
      end
    end

    def should_allow_creating_of(document_type)
      document_class = document_class_for(document_type)

      test "new displays document form" do
        get :new

        admin_documents_path = send("admin_#{document_type.to_s.tableize}_path")
        assert_select "form#document_new[action='#{admin_documents_path}']" do
          assert_select "input[name='document[title]'][type='text']"
          assert_select "textarea[name='document[body]']"
          assert_select "input[type='submit']"
        end
      end

      test "new form has previewable body" do
        get :new
        assert_select "textarea[name='document[body]'].previewable"
      end

      test "new form has cancel link which takes the user to the list of drafts" do
        get :new
        assert_select "a[href=#{admin_documents_path}]", text: /cancel/i
      end

      test "create should create a new document" do
        attributes = controller_attributes_for(document_type)

        post :create, document: attributes

        document = document_class.last
        assert_equal attributes[:title], document.title
        assert_equal attributes[:body], document.body
      end

      test "create should take the writer to the document page" do
        post :create, document: controller_attributes_for(document_type)

        admin_document_path = send("admin_#{document_type}_path", document_class.last)
        assert_redirected_to admin_document_path
        assert_equal 'The document has been saved', flash[:notice]
      end

      test "create with invalid data should leave the writer in the document editor" do
        attributes = controller_attributes_for(document_type)
        post :create, document: attributes.merge(title: '')

        assert_equal attributes[:body], assigns(:document).body, "the valid data should not have been lost"
        assert_template "documents/new"
      end

      test "create with invalid data should indicate there was an error" do
        attributes = controller_attributes_for(document_type)
        post :create, document: attributes.merge(title: '')

        assert_select ".field_with_errors input[name='document[title]']"
        assert_equal attributes[:body], assigns(:document).body, "the valid data should not have been lost"
        assert_equal 'There are some problems with the document', flash.now[:alert]
      end
    end

    def should_allow_editing_of(document_type)
      test "edit displays document form" do
        document = create(document_type)

        get :edit, id: document

        admin_document_path = send("admin_#{document_type}_path", document)
        assert_select "form#document_edit[action='#{admin_document_path}']" do
          assert_select "input[name='document[title]'][type='text']"
          assert_select "textarea[name='document[body]']"
          assert_select "input[type='submit']"
        end
      end

      test "edit form has previewable body" do
        document = create(document_type)

        get :edit, id: document

        assert_select "textarea[name='document[body]'].previewable"
      end

      test "edit form has cancel link which takes the user back to document" do
        draft_document = create("draft_#{document_type}")

        get :edit, id: draft_document

        admin_document_path = send("admin_#{document_type}_path", draft_document)
        assert_select "a[href=#{admin_document_path}]", text: /cancel/i
      end

      test "update should save modified document attributes" do
        document = create(document_type)

        put :update, id: document, document: {
          title: "new-title",
          body: "new-body"
        }

        document.reload
        assert_equal "new-title", document.title
        assert_equal "new-body", document.body
      end

      test "update should take the writer to the document page" do
        document = create(document_type)

        put :update, id: document, document: {title: 'new-title', body: 'new-body'}

        admin_document_path = send("admin_#{document_type}_path", document)
        assert_redirected_to admin_document_path
        assert_equal 'The document has been saved', flash[:notice]
      end

      test "update records the user who changed the document" do
        document = create(document_type)

        put :update, id: document, document: {title: 'new-title', body: 'new-body'}

        assert_equal current_user, document.document_authors(true).last.user
      end

      test "update with invalid data should not save the document" do
        attributes = controller_attributes_for(document_type)
        document = create(document_type, attributes)

        put :update, id: document, document: attributes.merge(title: '')

        assert_equal attributes[:title], document.reload.title
        assert_template "documents/edit"
        assert_equal 'There are some problems with the document', flash.now[:alert]
      end

      test "update with a stale document should render edit page with conflicting document" do
        document = create("draft_#{document_type}")
        lock_version = document.lock_version
        document.touch

        put :update, id: document, document: { lock_version: lock_version }

        assert_template 'edit'
        conflicting_document = document.reload
        assert_equal conflicting_document, assigns[:conflicting_document]
        assert_equal conflicting_document.lock_version, assigns[:document].lock_version
        assert_equal %{This document has been saved since you opened it}, flash[:alert]
      end
    end

    def should_allow_attachments_for(document_type)
      document_class = document_class_for(document_type)

      test "new displays document attachment fields" do
        get :new

        assert_select "form#document_new" do
          assert_select "input[name='document[document_attachments_attributes][0][attachment_attributes][title]'][type='text']"
          assert_select "input[name='document[document_attachments_attributes][0][attachment_attributes][file]'][type='file']"
        end
      end

      test 'creating a document should attach file' do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        attributes = controller_attributes_for(document_type)
        attributes[:document_attachments_attributes] = {
          "0" => { attachment_attributes: attributes_for(:attachment, title: "attachment-title", file: greenpaper_pdf) }
        }

        post :create, document: attributes

        assert document = document_class.last
        assert_equal 1, document.attachments.length
        attachment = document.attachments.first
        assert_equal "attachment-title", attachment.title
        assert_equal "greenpaper.pdf", attachment.carrierwave_file
        assert_equal "application/pdf", attachment.content_type
        assert_equal greenpaper_pdf.size, attachment.file_size
      end

      test "creating a document with invalid data should still show attachment fields" do
        post :create, document: controller_attributes_for(document_type, title: "")

        assert_select "form#document_new" do
          assert_select "input[name='document[document_attachments_attributes][0][attachment_attributes][title]'][type='text']"
          assert_select "input[name='document[document_attachments_attributes][0][attachment_attributes][file]'][type='file']"
        end
      end

      test "creating a document with invalid data should only allow a single attachment to be selected for upload" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')

        post :create, document: controller_attributes_for(document_type,
          title: "",
          document_attachments_attributes: {
            "0" => { attachment_attributes: attributes_for(:attachment, file: greenpaper_pdf) }
          }
        )

        assert_select "form#document_new" do
          assert_select "input[name*='document[document_attachments_attributes]'][type='file']", count: 1
        end
      end

      test "creating a document with invalid data but valid attachment data should still display the attachment data" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')

        post :create, document: controller_attributes_for(document_type,
          title: "",
          document_attachments_attributes: {
            "0" => { attachment_attributes: attributes_for(:attachment, title: "attachment-title", file: greenpaper_pdf) }
          }
        )

        assert_select "form#document_new" do
          assert_select "input[name='document[document_attachments_attributes][0][attachment_attributes][title]'][value='attachment-title']"
          assert_select "input[name='document[document_attachments_attributes][0][attachment_attributes][file_cache]'][value$='greenpaper.pdf']"
          assert_select ".already_uploaded", text: "greenpaper.pdf already uploaded"
        end
      end

      test 'creating a document with invalid data should not show any existing attachment info' do
        attributes = controller_attributes_for(document_type)
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')
        attributes[:document_attachments_attributes] = {
          "0" => { attachment_attributes: attributes_for(:attachment, file: greenpaper_pdf) }
        }

        post :create, document: attributes.merge(title: '')

        refute_select "p.attachment"
      end

      test "creating a document with multiple attachments should attach all files" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        csv_file = fixture_file_upload('sample-from-excel.csv', 'text/csv')
        attributes = controller_attributes_for(document_type)
        attributes[:document_attachments_attributes] = {
          "0" => { attachment_attributes: attributes_for(:attachment, title: "attachment-1-title", file: greenpaper_pdf) },
          "1" => { attachment_attributes: attributes_for(:attachment, title: "attachment-2-title", file: csv_file) }
        }

        post :create, document: attributes

        assert document = document_class.last
        assert_equal 2, document.attachments.length
        attachment_1 = document.attachments.first
        assert_equal "attachment-1-title", attachment_1.title
        assert_equal "greenpaper.pdf", attachment_1.carrierwave_file
        assert_equal "application/pdf", attachment_1.content_type
        assert_equal greenpaper_pdf.size, attachment_1.file_size
        attachment_2 = document.attachments.last
        assert_equal "attachment-2-title", attachment_2.title
        assert_equal "sample-from-excel.csv", attachment_2.carrierwave_file
        assert_equal "text/csv", attachment_2.content_type
        assert_equal csv_file.size, attachment_2.file_size
      end

      test 'edit displays document attachment fields' do
        two_page_pdf = fixture_file_upload('two-pages.pdf', 'application/pdf')
        attachment = create(:attachment, title: "attachment-title", file: two_page_pdf)
        document = create(document_type, attachments: [attachment])

        get :edit, id: document

        assert_select "form#document_edit" do
          assert_select "input[name='document[document_attachments_attributes][0][attachment_attributes][title]'][type='text'][value='attachment-title']"
          assert_select ".attachment" do
            assert_select "a", text: %r{two-pages.pdf$}
          end
          assert_select "input[name='document[document_attachments_attributes][1][attachment_attributes][title]'][type='text']"
          assert_select "input[name='document[document_attachments_attributes][1][attachment_attributes][file]'][type='file']"
        end
      end

      test 'updating a document should attach file' do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        document = create(document_type)

        put :update, id: document, document: document.attributes.merge(
          document_attachments_attributes: {
            "0" => { attachment_attributes: attributes_for(:attachment, title: "attachment-title", file: greenpaper_pdf) }
          }
        )

        document.reload
        assert_equal 1, document.attachments.length
        attachment = document.attachments.first
        assert_equal "attachment-title", attachment.title
        assert_equal "greenpaper.pdf", attachment.carrierwave_file
        assert_equal "application/pdf", attachment.content_type
        assert_equal greenpaper_pdf.size, attachment.file_size
      end

      test 'updating a document should attach multiple files' do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        csv_file = fixture_file_upload('sample-from-excel.csv', 'text/csv')
        document = create(document_type)

        put :update, id: document, document: document.attributes.merge(
          document_attachments_attributes: {
            "0" => { attachment_attributes: attributes_for(:attachment, title: "attachment-1-title", file: greenpaper_pdf) },
            "1" => { attachment_attributes: attributes_for(:attachment, title: "attachment-2-title", file: csv_file) }
          }
        )

        document.reload
        assert_equal 2, document.attachments.length
        attachment_1 = document.attachments.first
        assert_equal "attachment-1-title", attachment_1.title
        assert_equal "greenpaper.pdf", attachment_1.carrierwave_file
        assert_equal "application/pdf", attachment_1.content_type
        assert_equal greenpaper_pdf.size, attachment_1.file_size
        attachment_2 = document.attachments.last
        assert_equal "attachment-2-title", attachment_2.title
        assert_equal "sample-from-excel.csv", attachment_2.carrierwave_file
        assert_equal "text/csv", attachment_2.content_type
        assert_equal csv_file.size, attachment_2.file_size
      end

      test "updating a document with invalid data should still allow attachment to be selected for upload" do
        document = create(document_type)
        put :update, id: document, document: document.attributes.merge(title: "")

        assert_select "form#document_edit" do
          assert_select "input[name='document[document_attachments_attributes][0][attachment_attributes][file]'][type='file']"
        end
      end

      test "updating a document with invalid data should only allow a single attachment to be selected for upload" do
        document = create(document_type)
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')

        put :update, id: document, document: controller_attributes_for(document_type,
          title: "",
          document_attachments_attributes: {
            "0" => { attachment_attributes: attributes_for(:attachment, file: greenpaper_pdf) }
          }
        )

        assert_select "form#document_edit" do
          assert_select "input[name*='document[document_attachments_attributes]'][type='file']", count: 1
        end
      end

      test "updating a document with invalid data and valid attachment data should display the attachment data" do
        document = create(document_type)
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')

        put :update, id: document, document: controller_attributes_for(document_type,
          title: "",
          document_attachments_attributes: {
            "0" => { attachment_attributes: attributes_for(:attachment, title: "attachment-title", file: greenpaper_pdf) }
          }
        )

        assert_select "form#document_edit" do
          assert_select "input[name='document[document_attachments_attributes][0][attachment_attributes][title]'][value='attachment-title']"
          assert_select "input[name='document[document_attachments_attributes][0][attachment_attributes][file_cache]'][value$='greenpaper.pdf']"
          assert_select ".already_uploaded", text: "greenpaper.pdf already uploaded"
        end
      end

      test "updating a stale document should still display attachment fields" do
        document = create("draft_#{document_type}")
        lock_version = document.lock_version
        document.touch

        put :update, id: document, document: document.attributes.merge(lock_version: lock_version)

        assert_select "form#document_edit" do
          assert_select "input[name='document[document_attachments_attributes][0][attachment_attributes][title]'][type='text']"
          assert_select "input[name='document[document_attachments_attributes][0][attachment_attributes][file]'][type='file']"
        end
      end

      test "updating a stale document should only allow a single attachment to be selected for upload" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')
        document = create("draft_#{document_type}")
        lock_version = document.lock_version
        document.touch

        put :update, id: document, document: document.attributes.merge(
          lock_version: lock_version,
          document_attachments_attributes: {
            "0" => { attachment_attributes: attributes_for(:attachment, file: greenpaper_pdf) }
          }
        )

        assert_select "form#document_edit" do
          assert_select "input[name*='document[document_attachments_attributes]'][type='file']", count: 1
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
            "0" => { id: document_attachment_1.id.to_s, _destroy: "1" },
            "1" => { id: document_attachment_2.id.to_s, _destroy: "0" },
            "2" => { attachment_attributes: { file_cache: "" } }
          }
        )

        refute_select ".errors"
        document.reload
        assert_equal [attachment_2], document.attachments
      end

      test "should display PDF attachment metadata" do
        two_page_pdf = fixture_file_upload('two-pages.pdf', 'application/pdf')
        attachment = create(:attachment, title: "attachment-title", file: two_page_pdf)
        document = create(document_type, attachments: [attachment])

        get :show, id: document

        assert_select_object(attachment) do
          assert_select "a", text: "Download attachment"
          assert_select ".attachment_title", text: "attachment-title"
          assert_select ".type", /PDF/
          assert_select ".number_of_pages", "2 pages"
          assert_select ".size", "1.41 KB"
        end
      end

      test "should display CSV attachment metadata" do
        csv = fixture_file_upload('sample-from-excel.csv', 'text/csv')
        attachment = create(:attachment, title: "attachment-title", file: csv)
        document = create(document_type, attachments: [attachment])

        get :show, id: document

        assert_select_object(attachment) do
          assert_select "a", text: "Download attachment"
          assert_select ".attachment_title", text: "attachment-title"
          assert_select ".type", /CSV/
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
        document.editorial_remarks.create!(body: "editorial-remark-body", author: current_user)
        get :show, id: document
        assert_select ".rejected_by", text: current_user.name
        assert_select "a[href=#editorial_remarks]"
      end

      test "should not show the editorial remarks section" do
        document = create("submitted_#{document_type}")
        get :show, id: document
        refute_select "#editorial_remarks"
      end

      test "should show the list of editorial remarks" do
        document = create("rejected_#{document_type}")
        remark = document.editorial_remarks.create!(body: "editorial-remark-body", author: current_user)
        get :show, id: document
        assert_select "#editorial_remarks .editorial_remark" do
          assert_select ".body", text: "editorial-remark-body"
          assert_select ".author", text: current_user.name
          assert_select "abbr.created_at[title=#{remark.created_at.iso8601}]"
        end
      end
    end

    def should_be_publishable(document_type)
      document_class = document_class_for(document_type)

      test "should display the publish form if document is publishable" do
        document = create(document_type)
        document.stubs(:publishable_by?).returns(true)
        document_class.stubs(:find).with(document.to_param).returns(document)
        get :show, id: document
        assert_select publish_form_selector(document), count: 1
      end

      test "should not display the publish form if document is not publishable" do
        document = create(document_type)
        document.stubs(:publishable_by?).returns(false)
        document_class.stubs(:find).with(document.to_param).returns(document)
        get :show, id: document
        refute_select publish_form_selector(document)
      end
    end

    def should_be_force_publishable(document_type)
      document_class = document_class_for(document_type)

      test "should not display the force-publish form if document is publishable" do
        document = create(document_type)
        document.stubs(:publishable_by?).returns(true)
        document.stubs(:publishable_by?).with(anything, has_entry(force: true)).returns(true)
        document_class.stubs(:find).with(document.to_param).returns(document)
        get :show, id: document
        refute_select force_publish_form_selector(document)
      end

      test "should display the force-publish form if document is not publishable but is force-publishable" do
        document = create(document_type)
        document.stubs(:publishable_by?).returns(false)
        document.stubs(:publishable_by?).with(anything, has_entry(force: true)).returns(true)
        document_class.stubs(:find).with(document.to_param).returns(document)
        get :show, id: document
        assert_select force_publish_form_selector(document), count: 1
      end

      test "should not display the force-publish button if document is neither publishable nor force-publishable" do
        document = create(document_type)
        document.stubs(:publishable_by?).returns(false)
        document.stubs(:publishable_by?).with(anything, has_entry(force: true)).returns(false)
        document_class.stubs(:find).with(document.to_param).returns(document)
        get :show, id: document
        refute_select force_publish_form_selector(document)
      end
    end

    def should_allow_organisations_for(document_type)
      document_class = document_class_for(document_type)

      test "new should display document organisations field" do
        get :new

        assert_select "form#document_new" do
          assert_select "select[name*='document[organisation_ids]']"
        end
      end

      test "create should associate organisations with document" do
        first_organisation = create(:organisation)
        second_organisation = create(:organisation)
        attributes = controller_attributes_for(document_type)

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
      document_class = document_class_for(document_type)

      test "new should display document ministerial roles field" do
        get :new

        assert_select "form#document_new" do
          assert_select "select[name*='document[ministerial_role_ids]']"
        end
      end

      test "create should associate ministerial roles with document" do
        first_minister = create(:ministerial_role)
        second_minister = create(:ministerial_role)
        attributes = controller_attributes_for(document_type)

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

    def should_prevent_modification_of_unmodifiable(document_type)
      (Document::UNMODIFIABLE_STATES - %w(deleted)).each do |state|
        test "edit not allowed for #{state} #{document_type}" do
          document = create("#{state}_#{document_type}")

          get :edit, id: document

          assert_redirected_to send("admin_#{document_type}_path", document)
        end

        test "update not allowed for #{state} #{document_type}" do
          document = create("#{state}_#{document_type}")

          put :update, id: document, document: {title: 'new-title'}

          assert_redirected_to send("admin_#{document_type}_path", document)
        end
      end
    end

    def should_allow_overriding_of_first_published_at_for(document_type)
      document_class = document_class_for(document_type)

      test "new should display first_published_at fields" do
        get :new

        admin_documents_path = send("admin_#{document_type.to_s.tableize}_path")
        assert_select "form#document_new[action='#{admin_documents_path}']" do
          assert_select "select[name*='document[first_published_at']", count: 5
        end
      end

      test "edit should display first_published_at fields" do
        document = create(document_type)

        get :edit, id: document

        admin_document_path = send("admin_#{document_type}_path", document)
        assert_select "form#document_edit[action='#{admin_document_path}']" do
          assert_select "select[name*='document[first_published_at']", count: 5
        end
      end

      test "create should save overridden first_published_at attribute" do
        first_published_at = 3.months.ago
        post :create, document: controller_attributes_for(document_type).merge(first_published_at: 3.months.ago)

        document = document_class.last
        assert_equal first_published_at, document.first_published_at
      end

      test "update should save overridden first_published_at attribute" do
        document = create(document_type)
        first_published_at = 3.months.ago

        put :update, id: document, document: { first_published_at: first_published_at }

        document.reload
        assert_equal first_published_at, document.first_published_at
      end
    end
  end

  def controller_attributes_for(document_type, attributes = {})
    attributes_for(document_type, attributes)
  end
end
