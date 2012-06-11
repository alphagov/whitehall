module AdminEditionControllerTestHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def should_allow_showing_of(edition_type)
      test "should render the content using govspeak markup" do
        draft_edition = create("draft_#{edition_type}", body: "body-in-govspeak")
        govspeak_transformation_fixture default: "\n", "body-in-govspeak" => "body-in-html" do
          get :show, id: draft_edition
        end

        assert_select ".body", text: "body-in-html"
      end

      test "show lists each edition author once" do
        tom = create(:user, name: "Tom")
        dick = create(:user, name: "Dick")
        harry = create(:user, name: "Harry")

        draft_edition = create("draft_#{edition_type}", creator: tom)
        draft_edition.edit_as(dick)
        draft_edition.edit_as(harry)
        draft_edition.edit_as(dick)

        get :show, id: draft_edition

        assert_select ".authors", text: "Tom, Dick and Harry"
      end
    end

    def should_show_document_audit_trail_on(action)
      test "should show who created the document and when on #{action}" do
        edition_type = 'publication'
        tom = login_as(create(:author, name: "Tom", email: "tom@example.com"))
        draft_edition = create("draft_#{edition_type}")

        request.env['HTTPS'] = 'on'
        get action, id: draft_edition

        assert_select ".audit-trail", text: /Created by Tom/ do
          assert_select "img[src^='https']"
        end
      end
    end

    def should_allow_creating_of(edition_type)
      edition_class = edition_class_for(edition_type)

      test "new displays edition form" do
        get :new

        admin_editions_path = send("admin_#{edition_type.to_s.tableize}_path")
        assert_select "form#edition_new[action='#{admin_editions_path}']" do
          assert_select "input[name='edition[title]'][type='text']"
          assert_select "textarea[name='edition[summary]']" if edition_class.new.has_summary?
          assert_select "textarea[name='edition[body]']"
          assert_select "input[type='submit']"
        end
      end

      test "new form has previewable body" do
        get :new
        assert_select "textarea[name='edition[body]'].previewable"
      end

      test "new form has cancel link which takes the user to the list of drafts" do
        get :new
        assert_select "a[href=#{admin_editions_path}]", text: /cancel/i
      end

      test "create should create a new edition" do
        attributes = controller_attributes_for(edition_type)

        post :create, edition: attributes

        edition = edition_class.last
        assert_equal attributes[:title], edition.title
        assert_equal attributes[:body], edition.body
      end

      test "create should take the writer to the edition page" do
        post :create, edition: controller_attributes_for(edition_type)

        admin_edition_path = send("admin_#{edition_type}_path", edition_class.last)
        assert_redirected_to admin_edition_path
        assert_equal 'The document has been saved', flash[:notice]
      end

      test "create with invalid data should leave the writer in the document editor" do
        attributes = controller_attributes_for(edition_type)
        post :create, edition: attributes.merge(title: '')

        assert_equal attributes[:body], assigns(:edition).body, "the valid data should not have been lost"
        assert_template "editions/new"
      end

      test "create with invalid data should indicate there was an error" do
        attributes = controller_attributes_for(edition_type)
        post :create, edition: attributes.merge(title: '')

        assert_select ".field_with_errors input[name='edition[title]']"
        assert_equal attributes[:body], assigns(:edition).body, "the valid data should not have been lost"
        assert_equal 'There are some problems with the document', flash.now[:alert]
      end
    end

    def should_allow_editing_of(edition_type)
      should_report_editing_conflicts_of(edition_type)

      test "edit displays edition form" do
        edition = create(edition_type)

        get :edit, id: edition

        admin_edition_path = send("admin_#{edition_type}_path", edition)
        assert_select "form#edition_edit[action='#{admin_edition_path}']" do
          assert_select "input[name='edition[title]'][type='text']"
          assert_select "textarea[name='edition[body]']"
          assert_select "input[type='submit']"
        end
      end

      test "edit form has previewable body" do
        edition = create(edition_type)

        get :edit, id: edition

        assert_select "textarea[name='edition[body]'].previewable"
      end

      test "edit form has cancel link which takes the user back to edition" do
        draft_edition = create("draft_#{edition_type}")

        get :edit, id: draft_edition

        admin_edition_path = send("admin_#{edition_type}_path", draft_edition)
        assert_select "a[href=#{admin_edition_path}]", text: /cancel/i
      end

      test "update should save modified edition attributes" do
        edition = create(edition_type)

        put :update, id: edition, edition: {
          title: "new-title",
          body: "new-body"
        }

        edition.reload
        assert_equal "new-title", edition.title
        assert_equal "new-body", edition.body
      end

      test "update should take the writer to the edition page" do
        edition = create(edition_type)

        put :update, id: edition, edition: {title: 'new-title', body: 'new-body'}

        admin_edition_path = send("admin_#{edition_type}_path", edition)
        assert_redirected_to admin_edition_path
        assert_equal 'The document has been saved', flash[:notice]
      end

      test "update records the user who changed the edition" do
        edition = create(edition_type)

        put :update, id: edition, edition: {title: 'new-title', body: 'new-body'}

        assert_equal current_user, edition.edition_authors(true).last.user
      end

      test "update records the previous version of the document in the edition version history" do
        edition = create(edition_type, title: 'old-title', body: 'old-body')

        assert_difference "edition.versions.size" do
          put :update, id: edition, edition: {title: 'new-title', body: 'new-body'}
        end

        old_edition = edition.versions.last.reify
        assert_equal 'old-title', old_edition.title
        assert_equal 'old-body', old_edition.body
      end

      test "update with invalid data should not save the edition" do
        attributes = controller_attributes_for(edition_type)
        edition = create(edition_type, attributes)

        put :update, id: edition, edition: attributes.merge(title: '')

        assert_equal attributes[:title], edition.reload.title
        assert_template "editions/edit"
        assert_equal 'There are some problems with the document', flash.now[:alert]
      end

      test "update with a stale edition should render edit page with conflicting edition" do
        edition = create("draft_#{edition_type}")
        lock_version = edition.lock_version
        edition.touch

        put :update, id: edition, edition: { lock_version: lock_version }

        assert_template 'edit'
        conflicting_edition = edition.reload
        assert_equal conflicting_edition, assigns(:conflicting_edition)
        assert_equal conflicting_edition.lock_version, assigns(:edition).lock_version
        assert_equal %{This document has been saved since you opened it}, flash[:alert]
      end
    end

    def should_allow_revision_of(edition_type)
      test "should be possible to revise a published edition" do
        published_edition = create("published_#{edition_type}")

        get :show, id: published_edition

        assert_select "form[action='#{revise_admin_edition_path(published_edition)}']"
      end

      test "should not be possible to revise a draft edition" do
        draft_edition = create("draft_#{edition_type}")

        get :show, id: draft_edition

        refute_select "form[action='#{revise_admin_edition_path(draft_edition)}']"
      end

      test "should not be possible to revise an archived edition" do
        archived_edition = create("archived_#{edition_type}")

        get :show, id: archived_edition

        refute_select "form[action='#{revise_admin_edition_path(archived_edition)}']"
      end
    end

    def should_allow_attachments_for(edition_type)
      edition_class = edition_class_for(edition_type)

      test "new displays edition attachment fields" do
        get :new

        assert_select "form#edition_new" do
          assert_select "input[name='edition[edition_attachments_attributes][0][attachment_attributes][title]'][type='text']"
          assert_select "input[name='edition[edition_attachments_attributes][0][attachment_attributes][file]'][type='file']"
        end
      end

      test 'creating an edition should attach file' do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        attributes = controller_attributes_for(edition_type)
        attributes[:edition_attachments_attributes] = {
          "0" => { attachment_attributes: attributes_for(:attachment, title: "attachment-title", file: greenpaper_pdf) }
        }

        post :create, edition: attributes

        assert edition = edition_class.last
        assert_equal 1, edition.attachments.length
        attachment = edition.attachments.first
        assert_equal "attachment-title", attachment.title
        assert_equal "greenpaper.pdf", attachment.carrierwave_file
        assert_equal "application/pdf", attachment.content_type
        assert_equal greenpaper_pdf.size, attachment.file_size
      end

      test "creating an edition should result in a single instance of the uploaded file being cached" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        attributes = controller_attributes_for(edition_type)
        attributes[:edition_attachments_attributes] = {
          "0" => { attachment_attributes: attributes_for(:attachment, title: "attachment-title", file: greenpaper_pdf) }
        }

        Attachment.any_instance.expects(:file=).once

        post :create, edition: attributes
      end

      test "creating an edition with invalid data should still show attachment fields" do
        post :create, edition: controller_attributes_for(edition_type, title: "")

        assert_select "form#edition_new" do
          assert_select "input[name='edition[edition_attachments_attributes][0][attachment_attributes][title]'][type='text']"
          assert_select "input[name='edition[edition_attachments_attributes][0][attachment_attributes][file]'][type='file']"
        end
      end

      test "creating an edition with invalid data should only allow a single attachment to be selected for upload" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')

        post :create, edition: controller_attributes_for(edition_type,
          title: "",
          edition_attachments_attributes: {
            "0" => { attachment_attributes: attributes_for(:attachment, file: greenpaper_pdf) }
          }
        )

        assert_select "form#edition_new" do
          assert_select "input[name*='edition[edition_attachments_attributes]'][type='file']", count: 1
        end
      end

      test "creating an edition with invalid data but valid attachment data should still display the attachment data" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')

        post :create, edition: controller_attributes_for(edition_type,
          title: "",
          edition_attachments_attributes: {
            "0" => { attachment_attributes: attributes_for(:attachment, title: "attachment-title", file: greenpaper_pdf) }
          }
        )

        assert_select "form#edition_new" do
          assert_select "input[name='edition[edition_attachments_attributes][0][attachment_attributes][title]'][value='attachment-title']"
          assert_select "input[name='edition[edition_attachments_attributes][0][attachment_attributes][file_cache]'][value$='greenpaper.pdf']"
          assert_select ".already_uploaded", text: "greenpaper.pdf already uploaded"
        end
      end

      test 'creating an edition with invalid data should not show any existing attachment info' do
        attributes = controller_attributes_for(edition_type)
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')
        attributes[:edition_attachments_attributes] = {
          "0" => { attachment_attributes: attributes_for(:attachment, file: greenpaper_pdf) }
        }

        post :create, edition: attributes.merge(title: '')

        refute_select "p.attachment"
      end

      test "creating an edition with multiple attachments should attach all files" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        csv_file = fixture_file_upload('sample-from-excel.csv', 'text/csv')
        attributes = controller_attributes_for(edition_type)
        attributes[:edition_attachments_attributes] = {
          "0" => { attachment_attributes: attributes_for(:attachment, title: "attachment-1-title", file: greenpaper_pdf) },
          "1" => { attachment_attributes: attributes_for(:attachment, title: "attachment-2-title", file: csv_file) }
        }

        post :create, edition: attributes

        assert edition = edition_class.last
        assert_equal 2, edition.attachments.length
        attachment_1 = edition.attachments.first
        assert_equal "attachment-1-title", attachment_1.title
        assert_equal "greenpaper.pdf", attachment_1.carrierwave_file
        assert_equal "application/pdf", attachment_1.content_type
        assert_equal greenpaper_pdf.size, attachment_1.file_size
        attachment_2 = edition.attachments.last
        assert_equal "attachment-2-title", attachment_2.title
        assert_equal "sample-from-excel.csv", attachment_2.carrierwave_file
        assert_equal "text/csv", attachment_2.content_type
        assert_equal csv_file.size, attachment_2.file_size
      end

      test 'edit displays edition attachment fields' do
        two_page_pdf = fixture_file_upload('two-pages.pdf', 'application/pdf')
        attachment = create(:attachment, title: "attachment-title", file: two_page_pdf)
        edition = create(edition_type, attachments: [attachment])

        get :edit, id: edition

        assert_select "form#edition_edit" do
          assert_select "input[name='edition[edition_attachments_attributes][0][attachment_attributes][title]'][type='text'][value='attachment-title']"
          assert_select ".attachment" do
            assert_select "a", text: %r{two-pages.pdf$}
          end
          assert_select "input[name='edition[edition_attachments_attributes][1][attachment_attributes][title]'][type='text']"
          assert_select "input[name='edition[edition_attachments_attributes][1][attachment_attributes][file]'][type='file']"
        end
      end

      test 'updating an edition should attach file' do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        edition = create(edition_type)

        put :update, id: edition, edition: edition.attributes.merge(
          edition_attachments_attributes: {
            "0" => { attachment_attributes: attributes_for(:attachment, title: "attachment-title", file: greenpaper_pdf) }
          }
        )

        edition.reload
        assert_equal 1, edition.attachments.length
        attachment = edition.attachments.first
        assert_equal "attachment-title", attachment.title
        assert_equal "greenpaper.pdf", attachment.carrierwave_file
        assert_equal "application/pdf", attachment.content_type
        assert_equal greenpaper_pdf.size, attachment.file_size
      end

      test 'updating an edition should attach multiple files' do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        csv_file = fixture_file_upload('sample-from-excel.csv', 'text/csv')
        edition = create(edition_type)

        put :update, id: edition, edition: edition.attributes.merge(
          edition_attachments_attributes: {
            "0" => { attachment_attributes: attributes_for(:attachment, title: "attachment-1-title", file: greenpaper_pdf) },
            "1" => { attachment_attributes: attributes_for(:attachment, title: "attachment-2-title", file: csv_file) }
          }
        )

        edition.reload
        assert_equal 2, edition.attachments.length
        attachment_1 = edition.attachments.first
        assert_equal "attachment-1-title", attachment_1.title
        assert_equal "greenpaper.pdf", attachment_1.carrierwave_file
        assert_equal "application/pdf", attachment_1.content_type
        assert_equal greenpaper_pdf.size, attachment_1.file_size
        attachment_2 = edition.attachments.last
        assert_equal "attachment-2-title", attachment_2.title
        assert_equal "sample-from-excel.csv", attachment_2.carrierwave_file
        assert_equal "text/csv", attachment_2.content_type
        assert_equal csv_file.size, attachment_2.file_size
      end

      test "updating an edition with invalid data should still allow attachment to be selected for upload" do
        edition = create(edition_type)
        put :update, id: edition, edition: edition.attributes.merge(title: "")

        assert_select "form#edition_edit" do
          assert_select "input[name='edition[edition_attachments_attributes][0][attachment_attributes][file]'][type='file']"
        end
      end

      test "updating an edition with invalid data should only allow a single attachment to be selected for upload" do
        edition = create(edition_type)
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')

        put :update, id: edition, edition: controller_attributes_for(edition_type,
          title: "",
          edition_attachments_attributes: {
            "0" => { attachment_attributes: attributes_for(:attachment, file: greenpaper_pdf) }
          }
        )

        assert_select "form#edition_edit" do
          assert_select "input[name*='edition[edition_attachments_attributes]'][type='file']", count: 1
        end
      end

      test "updating an edition with invalid data and valid attachment data should display the attachment data" do
        edition = create(edition_type)
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')

        put :update, id: edition, edition: controller_attributes_for(edition_type,
          title: "",
          edition_attachments_attributes: {
            "0" => { attachment_attributes: attributes_for(:attachment, title: "attachment-title", file: greenpaper_pdf) }
          }
        )

        assert_select "form#edition_edit" do
          assert_select "input[name='edition[edition_attachments_attributes][0][attachment_attributes][title]'][value='attachment-title']"
          assert_select "input[name='edition[edition_attachments_attributes][0][attachment_attributes][file_cache]'][value$='greenpaper.pdf']"
          assert_select ".already_uploaded", text: "greenpaper.pdf already uploaded"
        end
      end

      test "updating a stale edition should still display attachment fields" do
        edition = create("draft_#{edition_type}")
        lock_version = edition.lock_version
        edition.touch

        put :update, id: edition, edition: edition.attributes.merge(lock_version: lock_version)

        assert_select "form#edition_edit" do
          assert_select "input[name='edition[edition_attachments_attributes][0][attachment_attributes][title]'][type='text']"
          assert_select "input[name='edition[edition_attachments_attributes][0][attachment_attributes][file]'][type='file']"
        end
      end

      test "updating a stale edition should only allow a single attachment to be selected for upload" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf')
        edition = create("draft_#{edition_type}")
        lock_version = edition.lock_version
        edition.touch

        put :update, id: edition, edition: edition.attributes.merge(
          lock_version: lock_version,
          edition_attachments_attributes: {
            "0" => { attachment_attributes: attributes_for(:attachment, file: greenpaper_pdf) }
          }
        )

        assert_select "form#edition_edit" do
          assert_select "input[name*='edition[edition_attachments_attributes]'][type='file']", count: 1
        end
      end

      test 'updating should allow removal of attachments' do
        attachment_1 = create(:attachment)
        attachment_2 = create(:attachment)
        edition = create(edition_type)
        edition_attachment_1 = create(:edition_attachment, edition: edition, attachment: attachment_1)
        edition_attachment_2 = create(:edition_attachment, edition: edition, attachment: attachment_2)

        put :update, id: edition, edition: edition.attributes.merge(
          edition_attachments_attributes: {
            "0" => { id: edition_attachment_1.id.to_s, _destroy: "1" },
            "1" => { id: edition_attachment_2.id.to_s, _destroy: "0" },
            "2" => { attachment_attributes: { file_cache: "" } }
          }
        )

        refute_select ".errors"
        edition.reload
        assert_equal [attachment_2], edition.attachments
      end

      test "should display PDF attachment metadata" do
        two_page_pdf = fixture_file_upload('two-pages.pdf', 'application/pdf')
        attachment = create(:attachment, title: "attachment-title", file: two_page_pdf)
        edition = create(edition_type, attachments: [attachment])

        get :show, id: edition

        assert_select_object(attachment) do
          assert_select ".attachment_title a", text: "attachment-title"
          assert_select ".type", /PDF/
          assert_select ".number_of_pages", "2 pages"
          assert_select ".size", "1.41 KB"
        end
      end

      test "should display CSV attachment metadata" do
        csv = fixture_file_upload('sample-from-excel.csv', 'text/csv')
        attachment = create(:attachment, title: "attachment-title", file: csv)
        edition = create(edition_type, attachments: [attachment])

        get :show, id: edition

        assert_select_object(attachment) do
          assert_select ".attachment_title a", text: "attachment-title"
          assert_select ".type", /CSV/
          refute_select ".number_of_pages"
          assert_select ".size", "121 Bytes"
        end
      end
    end

    def should_allow_attached_images_for(edition_type)
      edition_class = edition_class_for(edition_type)

      test "new displays edition image fields" do
        get :new

        assert_select "form#edition_new" do
          assert_select "input[name='edition[images_attributes][0][alt_text]'][type='text']"
          assert_select "textarea[name='edition[images_attributes][0][caption]']"
          assert_select "input[name='edition[images_attributes][0][image_data_attributes][file]'][type='file']"
        end
      end

      test 'creating an edition should attach image' do
        image = fixture_file_upload('portas-review.jpg')
        attributes = controller_attributes_for(edition_type)
        attributes[:images_attributes] = {
          "0" => { alt_text: "some-alt-text", caption: "longer-caption-for-image",
                  image_data_attributes: attributes_for(:image_data, file: image) }
        }

        post :create, edition: attributes

        assert edition = edition_class.last
        assert_equal 1, edition.images.length
        image = edition.images.first
        assert_equal "some-alt-text", image.alt_text
        assert_equal "longer-caption-for-image", image.caption
      end

      test "creating an edition should result in a single instance of the uploaded image file being cached" do
        image = fixture_file_upload('portas-review.jpg')
        attributes = controller_attributes_for(edition_type)
        attributes[:images_attributes] = {
          "0" => { alt_text: "some-alt-text",
                  image_data_attributes: attributes_for(:image_data, file: image) }
        }

        ImageData.any_instance.expects(:file=).once

        post :create, edition: attributes
      end

      test "creating an edition with invalid data should still show image fields" do
        post :create, edition: controller_attributes_for(edition_type, title: "")

        assert_select "form#edition_new" do
          assert_select "input[name='edition[images_attributes][0][alt_text]'][type='text']"
          assert_select "textarea[name='edition[images_attributes][0][caption]']"
          assert_select "input[name='edition[images_attributes][0][image_data_attributes][file]'][type='file']"
        end
      end

      test "creating an edition with invalid data should only allow a single image to be selected for upload" do
        image = fixture_file_upload('portas-review.jpg')
        attributes = controller_attributes_for(edition_type, title: "")
        attributes[:images_attributes] = {
          "0" => { alt_text: "some-alt-text",
                  image_data_attributes: attributes_for(:image_data, file: image) }
        }

        post :create, edition: attributes

        assert_select "form#edition_new" do
          assert_select "input[name*='edition[images_attributes]'][type='file']", count: 1
        end
      end

      test "creating an edition with invalid data but valid image data should still display the image data" do
        image = fixture_file_upload('portas-review.jpg')
        attributes = controller_attributes_for(edition_type, title: "")
        attributes[:images_attributes] = {
          "0" => { alt_text: "some-alt-text",
                  image_data_attributes: attributes_for(:image_data, file: image) }
        }

        post :create, edition: attributes

        assert_select "form#edition_new" do
          assert_select "input[name='edition[images_attributes][0][alt_text]'][type='text'][value='some-alt-text']"
          assert_select "input[name='edition[images_attributes][0][image_data_attributes][file_cache]'][value$='portas-review.jpg']"
          assert_select ".already_uploaded", text: "portas-review.jpg already uploaded"
        end
      end

      test 'creating an edition with invalid data should not show any existing image info' do
        image = fixture_file_upload('portas-review.jpg')
        attributes = controller_attributes_for(edition_type, title: "")
        attributes[:images_attributes] = {
          "0" => { alt_text: "some-alt-text",
                  image_data_attributes: attributes_for(:image_data, file: image) }
        }

        post :create, edition: attributes

        refute_select "p.image"
      end

      test "creating an edition with multiple images should attach all files" do
        image = fixture_file_upload('portas-review.jpg')
        attributes = controller_attributes_for(edition_type)
        attributes[:images_attributes] = {
          "0" => {alt_text: "some-alt-text",
                  image_data_attributes: attributes_for(:image_data, file: image)},
          "1" => {alt_text: "more-alt-text",
                  image_data_attributes: attributes_for(:image_data, file: image)}
        }

        post :create, edition: attributes

        assert edition = edition_class.last
        assert_equal 2, edition.images.length
        image_1 = edition.images.first
        assert_equal "some-alt-text", image_1.alt_text
        image_2 = edition.images.last
        assert_equal "more-alt-text", image_2.alt_text
      end

      test 'edit displays edition image fields' do
        image = fixture_file_upload('portas-review.jpg')
        edition = create(edition_type)
        image = create(:image, alt_text: "blah", edition: edition,
                       image_data_attributes: attributes_for(:image_data, file: image))

        get :edit, id: edition

        assert_select "form#edition_edit" do
          assert_select "input[name='edition[images_attributes][0][alt_text]'][type='text'][value='blah']"
          assert_select ".image" do
            assert_select "img[src$='portas-review.jpg']"
          end
          assert_select "input[name='edition[images_attributes][1][alt_text]'][type='text']"
          assert_select "textarea[name='edition[images_attributes][1][caption]']"
          assert_select "input[name='edition[images_attributes][1][image_data_attributes][file]'][type='file']"
        end
      end

      test 'updating an edition should attach an image' do
        image = fixture_file_upload('portas-review.jpg')
        edition = create(edition_type)

        put :update, id: edition, edition: edition.attributes.merge(
          images_attributes: {
            "0" => { alt_text: "alt-text", image_data_attributes: attributes_for(:image_data, file: image) }
          }
        )

        edition.reload
        assert_equal 1, edition.images.length
        image = edition.images.first
        assert_equal "alt-text", image.alt_text
      end

      test 'updating an edition with image alt text but no file attachment should show a validation error' do
        edition = create(edition_type)

        put :update, id: edition, edition: edition.attributes.merge(
          images_attributes: {
            "0" => { alt_text: "alt-text", image_data_attributes: { file_cache: "" } }
          }
        )

        assert_select ".errors", text: "Images image data file can't be blank"

        edition.reload
        assert_equal 0, edition.images.length
      end

      test 'updating an edition with an existing image allows image attributes to be changed' do
        edition = create(edition_type)
        image = edition.images.create!(alt_text: "old-alt-text", caption: 'old-caption')

        put :update, id: edition, edition: edition.attributes.merge(
          images_attributes: {
            "0" => { id: image.id, alt_text: "new-alt-text", caption: 'new-caption' }
          }
        )

        edition.reload
        assert_equal 1, edition.images.length
        image = edition.images.first
        assert_equal "new-alt-text", image.alt_text
        assert_equal "new-caption", image.caption
      end

      test 'updating an edition should attach multiple images' do
        edition = create(edition_type)
        image = fixture_file_upload('portas-review.jpg')
        attributes = edition.attributes
        attributes[:images_attributes] = {
          "0" => {alt_text: "some-alt-text",
                  image_data_attributes: attributes_for(:image_data, file: image)},
          "1" => {alt_text: "more-alt-text",
                  image_data_attributes: attributes_for(:image_data, file: image)}
        }

        put :update, id: edition, edition: attributes

        edition.reload
        assert_equal 2, edition.images.length
        image_1 = edition.images.first
        assert_equal "some-alt-text", image_1.alt_text
        image_2 = edition.images.last
        assert_equal "more-alt-text", image_2.alt_text
      end

      test "updating an edition with invalid data should still allow image to be selected for upload" do
        edition = create(edition_type)
        put :update, id: edition, edition: edition.attributes.merge(title: "")

        assert_select "form#edition_edit" do
          assert_select "input[name='edition[images_attributes][0][image_data_attributes][file]'][type='file']"
        end
      end

      test "updating an edition with invalid data should only allow a single image to be selected for upload" do
        edition = create(edition_type)
        image = fixture_file_upload('portas-review.jpg')
        attributes = edition.attributes.merge(title: "")
        attributes[:images_attributes] = {
          "0" => { alt_text: "some-alt-text",
                  image_data_attributes: attributes_for(:image_data, file: image) }
        }

        put :update, id: edition, edition: attributes

        assert_select "form#edition_edit" do
          assert_select "input[name*='edition[images_attributes]'][type='file']", count: 1
        end
      end

      test "updating an edition with invalid data and valid image data should display the image data" do
        edition = create(edition_type)
        image = fixture_file_upload('portas-review.jpg')
        attributes = edition.attributes.merge(title: "")
        attributes[:images_attributes] = {
          "0" => { alt_text: "some-alt-text",
                  image_data_attributes: attributes_for(:image_data, file: image) }
        }

        put :update, id: edition, edition: attributes

        assert_select "form#edition_edit" do
          assert_select "input[name='edition[images_attributes][0][alt_text]'][value='some-alt-text']"
          assert_select "input[name='edition[images_attributes][0][image_data_attributes][file_cache]'][value$='portas-review.jpg']"
          assert_select ".already_uploaded", text: "portas-review.jpg already uploaded"
        end
      end

      test "updating a stale edition should still display image fields" do
        edition = create("draft_#{edition_type}")
        lock_version = edition.lock_version
        edition.touch

        put :update, id: edition, edition: edition.attributes.merge(lock_version: lock_version)

        assert_select "form#edition_edit" do
          assert_select "input[name='edition[images_attributes][0][alt_text]'][type='text']"
          assert_select "textarea[name='edition[images_attributes][0][caption]']"
          assert_select "input[name='edition[images_attributes][0][image_data_attributes][file]'][type='file']"
        end
      end

      test "updating a stale edition should only allow a single image to be selected for upload" do
        edition = create(edition_type)
        image = fixture_file_upload('portas-review.jpg')
        lock_version = edition.lock_version
        edition.touch
        attributes = edition.attributes.merge(title: "", lock_version: lock_version)
        attributes[:images_attributes] = {
          "0" => { alt_text: "some-alt-text",
                  image_data_attributes: attributes_for(:image_data, file: image) }
        }

        put :update, id: edition, edition: attributes

        assert_select "form#edition_edit" do
          assert_select "input[name*='edition[images_attributes]'][type='file']", count: 1
        end
      end

      test 'updating should allow removal of images' do
        edition = create(edition_type)
        image_1 = create(:image, edition: edition, alt_text: "the first image")
        image_2 = create(:image, edition: edition, alt_text: "the second image")

        attributes = edition.attributes.merge(
          images_attributes: {
            "0" => { id: image_1.id.to_s, _destroy: "1" },
            "1" => { id: image_2.id.to_s, _destroy: "0" },
            "2" => { image_data_attributes: { file_cache: "" } }
          }
        )
        put :update, id: edition, edition: attributes

        refute_select ".errors"
        edition.reload
        assert_equal [image_2], edition.images
      end

      test "shows the image" do
        edition = create(edition_type)
        image = create(:image, edition: edition)

        get :show, id: edition

        assert_select_object(image) do
          assert_select "img[src=?]", %r{#{image.image_data.file}}
        end
      end

      test "can embed image inline and see it in preview" do
        edition = create(edition_type, body: "!!1")
        image = create(:image, edition: edition)

        get :show, id: edition

        assert_select 'article .body figure.image.embedded img[src=?]', %r{#{image.url}}
      end
    end

    def should_use_lead_image_for(edition_type)
      test "showing should display the lead image" do
        draft_edition = create("draft_#{edition_type}", images: [build(:image)])

        get :show, id: draft_edition

        assert_select "article.document .body figure.image.lead"
      end

      test 'edit indicates that first image is lead image' do
        draft_edition = create("draft_#{edition_type}", images: [build(:image)])

        get :edit, id: draft_edition

        message = "This will automatically be used as the lead image. No markdown required."

        assert_select "fieldset.images .image p", text: message
      end

      test 'edit shows markdown hint for second image' do
        draft_edition = create("draft_#{edition_type}", images: [build(:image), build(:image)])

        get :edit, id: draft_edition

        assert_select "fieldset.images .image p" do |nodes|
          assert_equal 1, nodes[1].select("input[readonly][value=!!2]").length
        end
      end
    end

    def should_not_use_lead_image_for(edition_type)
      test "showing should not display the lead image" do
        draft_edition = create("draft_#{edition_type}", images: [build(:image)])

        get :show, id: draft_edition

        assert_select "article.document .body figure.image.lead", count: 0
      end

      test 'edit shows markdown hint for first image' do
        draft_edition = create("draft_#{edition_type}", images: [build(:image)])

        get :edit, id: draft_edition

        assert_select "fieldset.images .image p", text: "Markdown to use:" do |nodes|
          assert_equal 1, nodes[0].select("input[readonly][value=!!1]").length
        end
      end
    end

    def should_be_able_to_delete_an_edition(edition_type)
      test "show displays the delete button for draft editions" do
        draft_edition = create("draft_#{edition_type}")

        get :show, id: draft_edition

        destroy_path = send("admin_#{edition_type}_path", draft_edition)
        assert_select "form[action='#{destroy_path}']" do
          assert_select "input[name='_method'][type='hidden'][value='delete']"
          assert_select "input[type='submit'][value='Delete']"
        end
      end

      test "show displays the delete button for submitted editions" do
        submitted_edition = create("submitted_#{edition_type}")

        get :show, id: submitted_edition

        destroy_path = send("admin_#{edition_type}_path", submitted_edition)
        assert_select "input[type='submit'][value='Delete']"
      end

      test "show displays the delete button for published editions with no previous editions" do
        published_edition = create("published_#{edition_type}")

        get :show, id: published_edition

        destroy_path = send("admin_#{edition_type}_path", published_edition)
        assert_select "input[type='submit'][value='Delete']"
      end

      test "show does not display the delete button for published editions with previous editions" do
        user = create(:user)
        previous_edition = create("published_#{edition_type}")
        published_edition = previous_edition.create_draft(user)
        published_edition.publish!

        get :show, id: published_edition

        destroy_path = send("admin_#{edition_type}_path", published_edition)
        refute_select "input[type='submit'][value='Delete']"
      end

      test "show displays the delete button for archived editions with no previous editions" do
        archived_edition = create("archived_#{edition_type}")

        get :show, id: archived_edition

        destroy_path = send("admin_#{edition_type}_path", archived_edition)
        assert_select "input[type='submit'][value='Delete']"
      end

      test "show does not display the delete button for archived editions with previous editions" do
        user = create(:user)
        previous_edition = create("published_#{edition_type}")
        archived_edition = previous_edition.create_draft(user)
        archived_edition.publish!
        archived_edition.archive!

        get :show, id: archived_edition

        destroy_path = send("admin_#{edition_type}_path", archived_edition)
        refute_select "input[type='submit'][value='Delete']"
      end

      test "destroy marks the edition as deleted" do
        edition = create("draft_#{edition_type}")
        delete :destroy, id: edition
        edition.reload
        assert edition.deleted?
      end

      test "destroying an edition redirects to the draft editions page" do
        draft_edition = create("draft_#{edition_type}")
        delete :destroy, id: draft_edition
        assert_redirected_to admin_editions_path
      end

      test "destroy displays a notice indicating the edition has been deleted" do
        draft_edition = create("draft_#{edition_type}", title: "edition-title")
        delete :destroy, id: draft_edition
        assert_equal "The document 'edition-title' has been deleted", flash[:notice]
      end
    end

    def should_link_to_public_version_when_published(edition_type)
      test "should link to public version when published" do
        published_edition = create("published_#{edition_type}")
        get :show, id: published_edition
        assert_select link_to_public_version_selector, count: 1
      end
    end

    def should_not_link_to_public_version_when_not_published(edition_type)
      test "should not link to public version when not published" do
        draft_edition = create("draft_#{edition_type}")
        get :show, id: draft_edition
        refute_select link_to_public_version_selector
      end
    end

    def should_be_rejectable(edition_type)
      document_type_class = edition_type.to_s.classify.constantize

      test "should display the 'Reject' button" do
        edition = create(edition_type)
        edition.stubs(:rejectable_by?).returns(true)
        document_type_class.stubs(:find).with(edition.to_param).returns(edition)
        get :show, id: edition
        assert_select reject_button_selector(edition), count: 1
      end

      test "shouldn't display the 'Reject' button" do
        edition = create(edition_type)
        edition.stubs(:rejectable_by?).returns(false)
        document_type_class.stubs(:find).with(edition.to_param).returns(edition)
        get :show, id: edition
        refute_select reject_button_selector(edition)
      end

      test "should show who rejected the edition" do
        edition = create("rejected_#{edition_type}")
        edition.editorial_remarks.create!(body: "editorial-remark-body", author: current_user)
        get :show, id: edition
        assert_select ".rejected_by", text: current_user.name
      end

      test "should not show the editorial remarks section" do
        edition = create("submitted_#{edition_type}")
        get :show, id: edition
        refute_select "#editorial_remarks .editorial_remark"
      end

      test "should show the list of editorial remarks" do
        edition = create("rejected_#{edition_type}")
        remark = edition.editorial_remarks.create!(body: "editorial-remark-body", author: current_user)
        get :show, id: edition
        assert_select ".editorial_remark" do
          assert_select ".body", text: /editorial-remark-body/
          assert_select ".actor", text: current_user.name
          assert_select "abbr.created_at[title=#{remark.created_at.iso8601}]"
        end
      end
    end

    def should_be_publishable(edition_type)
      test "should display the publish form if edition is publishable" do
        login_as :departmental_editor
        edition = create("submitted_#{edition_type}")
        get :show, id: edition
        assert_select publish_form_selector(edition), count: 1
      end

      test "should not display the publish form if edition is not publishable" do
        edition = create("draft_#{edition_type}")
        get :show, id: edition
        refute_select publish_form_selector(edition)
      end
    end

    def should_be_force_publishable(edition_type)
      test "should not display the force publish form if edition is publishable" do
        login_as :departmental_editor
        edition = create("submitted_#{edition_type}")
        get :show, id: edition
        refute_select force_publish_form_selector(edition)
      end

      test "should display the force publish form if edition is not publishable but is force-publishable" do
        login_as :departmental_editor
        edition = create("draft_#{edition_type}")
        get :show, id: edition
        assert_select force_publish_form_selector(edition), count: 1
      end

      test "should not display the force publish form if edition is neither publishable nor force-publishable" do
        edition = create("draft_#{edition_type}")
        get :show, id: edition
        refute_select force_publish_form_selector(edition)
      end

      test "show should indicate a force-published document" do
        edition = create("published_#{edition_type}", force_published: true)
        get :show, id: edition
        assert_select ".force_published"
      end

      test "show should not display the approve_retrospectively form for the creator" do
        creator = create(:departmental_editor, name: "Fred")
        login_as(creator)
        edition = create("published_#{edition_type}", force_published: true, creator: creator)
        get :show, id: edition
        refute_select ".force_published form input"
      end

      test "show should display the approve_retrospectively form for a departmental editor who wasn't the creator" do
        creator = create(:departmental_editor, name: "Fred")
        login_as(creator)
        edition = create("published_#{edition_type}", force_published: true, creator: creator)
        login_as(create(:departmental_editor, name: "Another Editor"))
        get :show, id: edition
        assert_select ".force_published form input"
      end
    end

    def should_allow_video_for(edition_type)
      edition_class = edition_class_for(edition_type)

      test "new should display edition video URL field" do
        get :new

        assert_select "form#edition_new" do
          assert_select "input[name='edition[video_url]'][type='text']"
        end
      end

      test "create should set video URL on edition" do
        attributes = controller_attributes_for(edition_type)

        post :create, edition: attributes.merge(
          video_url: "http://www.youtube.com/watch?v=OXHPWmnycno"
        )

        edition = edition_class.last
        assert_equal "http://www.youtube.com/watch?v=OXHPWmnycno", edition.video_url
      end

      test "edit should display edition video URL field" do
        edition = create(edition_type, video_url: "http://www.youtube.com/watch?v=OXHPWmnycno")

        get :edit, id: edition

        assert_select "form#edition_edit" do
          assert_select "input[name='edition[video_url]'][value='http://www.youtube.com/watch?v=OXHPWmnycno']"
        end
      end

      test "update should set video URL on edition" do
        edition = create(edition_type, video_url: "http://www.youtube.com/watch?v=OXHPWmnycno")

        put :update, id: edition, edition: {
          video_url: "http://www.youtube.com/watch?v=o8Ka17LIIfU"
        }

        edition.reload
        assert_equal "http://www.youtube.com/watch?v=o8Ka17LIIfU", edition.video_url
      end

      test "shows the video" do
        edition = create(edition_type, video_url: "http://www.youtube.com/watch?v=OXHPWmnycno")

        get :show, id: edition

        assert_select ".video" do
          assert_select "a[href=?]", "http://www.youtube.com/watch?v=OXHPWmnycno"
        end
      end
    end

    def should_allow_related_policies_for(document_type)
      edition_class = edition_class_for(document_type)

      test "new displays document form with related policies field" do
        get :new

        assert_select "form#edition_new" do
          assert_select "select[name*='edition[related_document_ids]']"
        end
      end

      test "creating should create a new document with related policies" do
        first_policy = create(:policy)
        second_policy = create(:policy)
        attributes = controller_attributes_for(document_type)

        post :create, edition: attributes.merge(
          related_document_ids: [first_policy.document.id, second_policy.document.id]
        )

        assert document = edition_class.last
        assert_equal [first_policy, second_policy], document.related_policies
      end

      test "edit displays document form with related policies field" do
        policy = create(:policy)
        document = create(document_type, related_policies: [policy])

        get :edit, id: document

        assert_select "form#edition_edit" do
          assert_select "select[name*='edition[related_document_ids]']"
        end
      end

      test "updating should save modified document attributes with related policies" do
        first_policy = create(:policy)
        second_policy = create(:policy)
        document = create(document_type, related_policies: [first_policy])

        put :update, id: document, edition: {
          related_document_ids: [second_policy.document.id]
        }

        document = document.reload
        assert_equal [second_policy], document.related_policies
      end

      test "updating should remove all related policies if none in params" do
        policy = create(:policy)
        document = create(document_type, related_policies: [policy])

        put :update, id: document, edition: {}

        document.reload
        assert_equal [], document.related_policies
      end

      test "updating a stale document should render edit page with conflicting document and its related policies" do
        policy = create(:policy)
        document = create(document_type, related_policies: [policy])
        lock_version = document.lock_version
        document.touch

        put :update, id: document, edition: document.attributes.merge(lock_version: lock_version)

        assert_select ".document.conflict" do
          assert_select "h1", "Related Policies"
        end
      end

      test "show displays related policies" do
        policy = create(:policy)
        document = create(document_type, related_policies: [policy])

        get :show, id: document

        assert_select_object policy
      end
    end

    def should_allow_organisations_for(edition_type)
      edition_class = edition_class_for(edition_type)

      test "new should display edition organisations field" do
        get :new

        assert_select "form#edition_new" do
          assert_select "select[name*='edition[organisation_ids]']"
        end
      end

      test "create should associate organisations with edition" do
        first_organisation = create(:organisation)
        second_organisation = create(:organisation)
        attributes = controller_attributes_for(edition_type)

        post :create, edition: attributes.merge(
          organisation_ids: [first_organisation.id, second_organisation.id]
        )

        edition = edition_class.last
        assert_equal [first_organisation, second_organisation], edition.organisations
      end

      test "edit should display edition organisations field" do
        edition = create(edition_type)

        get :edit, id: edition

        assert_select "form#edition_edit" do
          assert_select "select[name*='edition[organisation_ids]']"
        end
      end

      test "update should associate organisations with editions" do
        first_organisation = create(:organisation)
        second_organisation = create(:organisation)

        edition = create(edition_type, organisations: [first_organisation])

        put :update, id: edition, edition: {
          organisation_ids: [second_organisation.id]
        }

        edition.reload
        assert_equal [second_organisation], edition.organisations
      end

      test "update should remove all organisations if none specified" do
        organisation = create(:organisation)

        edition = create(edition_type, organisations: [organisation])

        put :update, id: edition, edition: {}

        edition.reload
        assert_equal [], edition.organisations
      end
    end

    def should_allow_ministerial_roles_for(edition_type)
      edition_class = edition_class_for(edition_type)

      test "new should display edition ministerial roles field" do
        get :new

        assert_select "form#edition_new" do
          assert_select "select[name*='edition[ministerial_role_ids]']"
        end
      end

      test "create should associate ministerial roles with edition" do
        first_minister = create(:ministerial_role)
        second_minister = create(:ministerial_role)
        attributes = controller_attributes_for(edition_type)

        post :create, edition: attributes.merge(
          ministerial_role_ids: [first_minister.id, second_minister.id]
        )

        edition = edition_class.last
        assert_equal [first_minister, second_minister], edition.ministerial_roles
      end

      test "edit should display edition ministerial roles field" do
        edition = create(edition_type)

        get :edit, id: edition

        assert_select "form#edition_edit" do
          assert_select "select[name*='edition[ministerial_role_ids]']"
        end
      end

      test "update should associate ministerial roles with editions" do
        first_minister = create(:ministerial_role)
        second_minister = create(:ministerial_role)

        edition = create(edition_type, ministerial_roles: [first_minister])

        put :update, id: edition, edition: {
          ministerial_role_ids: [second_minister.id]
        }

        edition.reload
        assert_equal [second_minister], edition.ministerial_roles
      end

      test "update should remove all ministerial roles if none specified" do
        minister = create(:ministerial_role)

        edition = create(edition_type, ministerial_roles: [minister])

        put :update, id: edition, edition: {}

        edition.reload
        assert_equal [], edition.ministerial_roles
      end
    end

    def should_prevent_modification_of_unmodifiable(edition_type)
      (Edition::UNMODIFIABLE_STATES - %w(deleted)).each do |state|
        test "edit not allowed for #{state} #{edition_type}" do
          edition = create("#{state}_#{edition_type}")

          get :edit, id: edition

          assert_redirected_to send("admin_#{edition_type}_path", edition)
        end

        test "update not allowed for #{state} #{edition_type}" do
          edition = create("#{state}_#{edition_type}")

          put :update, id: edition, edition: {title: 'new-title'}

          assert_redirected_to send("admin_#{edition_type}_path", edition)
        end
      end
    end

    def should_allow_overriding_of_first_published_at_for(edition_type)
      edition_class = edition_class_for(edition_type)

      test "new should display first_published_at fields" do
        get :new

        admin_editions_path = send("admin_#{edition_type.to_s.tableize}_path")
        assert_select "form#edition_new[action='#{admin_editions_path}']" do
          assert_select "select[name*='edition[first_published_at']", count: 5
        end
      end

      test "edit should display first_published_at fields" do
        edition = create(edition_type)

        get :edit, id: edition

        admin_edition_path = send("admin_#{edition_type}_path", edition)
        assert_select "form#edition_edit[action='#{admin_edition_path}']" do
          assert_select "select[name*='edition[first_published_at']", count: 5
        end
      end

      test "create should save overridden first_published_at attribute" do
        first_published_at = 3.months.ago
        post :create, edition: controller_attributes_for(edition_type).merge(first_published_at: 3.months.ago)

        edition = edition_class.last
        assert_equal first_published_at, edition.first_published_at
      end

      test "update should save overridden first_published_at attribute" do
        edition = create(edition_type)
        first_published_at = 3.months.ago

        put :update, id: edition, edition: { first_published_at: first_published_at }

        edition.reload
        assert_equal first_published_at, edition.first_published_at
      end
    end

    def should_report_editing_conflicts_of(edition_type)
      test "editing an existing #{edition_type} should record a RecentEditionOpening" do
        edition = create(edition_type)
        get :edit, id: edition

        assert_equal [current_user], edition.reload.recent_edition_openings.map(&:editor)
      end

      test "should not see a warning when editing an edition that nobody has recently edited" do
        edition = create(edition_type)
        get :edit, id: edition

        refute_select ".editing_conflict"
      end

      test "should see a warning when editing an edition that someone else has recently edited" do
        edition = create(edition_type)
        other_user = create(:author, name: "Joe Bloggs", email: "joe@example.com")
        edition.open_for_editing_as(other_user)
        Timecop.travel 1.hour.from_now

        request.env['HTTPS'] = 'on'
        get :edit, id: edition

        assert_select ".editing_conflict", /Joe Bloggs/ do
          assert_select "img[src^='https']"
        end
        assert_select ".editing_conflict", /1 hour ago/
      end

      test "saving a #{edition_type} should remove any RecentEditionOpening records for the current user" do
        edition = create(edition_type)
        edition.open_for_editing_as(@current_user)

        assert_difference "edition.reload.recent_edition_openings.count", -1 do
          put :update, id: edition, edition: {}
        end
      end
    end
  end

  def controller_attributes_for(edition_type, attributes = {})
    attributes_for(edition_type, attributes)
  end
end
