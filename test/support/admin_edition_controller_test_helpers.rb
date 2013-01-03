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
    end

    def should_show_document_audit_trail_for(edition_type, action)
      test "should show who created the document and when on #{action}" do
        tom = login_as(create(:gds_editor, name: "Tom", email: "tom@example.com"))
        draft_edition = create("draft_#{edition_type}")

        request.env['HTTPS'] = 'on'
        get action, id: draft_edition

        assert_select ".audit-trail", text: /Created by Tom/ do
          assert_select "img[src^='https']"
        end
      end
    end

    def should_have_summary(edition_type)
      edition_class = edition_class_for(edition_type)

      test "create should create a new #{edition_type} with summary" do
        attributes = controller_attributes_for(edition_type)

        post :create, edition: attributes.merge(
          summary: "my summary",
        )

        created_edition = edition_class.last
        assert_equal "my summary", created_edition.summary
      end

      test "update should save modified news article summary" do
        edition = create(edition_type)

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
          summary: "new-summary"
        )

        saved_edition = edition.reload
        assert_equal "new-summary", edition.summary
      end
    end

    def should_have_notes_to_editors(edition_type)
      edition_class = edition_class_for(edition_type)

      test "create should create a new #{edition_type} with notes to editors" do
        attributes = controller_attributes_for(edition_type)

        post :create, edition: attributes.merge(
          notes_to_editors: "notes-to-editors"
        )

        created_edition = edition_class.last
        assert_equal "notes-to-editors", created_edition.notes_to_editors
      end

      test "update should save modified #{edition_type} notes to editors" do
        edition = create(edition_type)

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
          notes_to_editors: "new-notes-to-editors"
        )

        saved_edition = edition.reload
        assert_equal "new-notes-to-editors", saved_edition.notes_to_editors
      end
    end

    def should_allow_unpublishing_for(edition_type)
      edition_class = edition_class_for(edition_type)

      test "should display unpublish button" do
        edition = create(edition_type)
        edition.stubs(:unpublishable_by?).returns(true)
        edition_class.stubs(:find).returns(edition)

        get :show, id: edition

        assert_select "form[action=?]", unpublish_admin_edition_path(edition, lock_version: edition.lock_version)
      end

      test "should not display unpublish button if edition is not unpublishable" do
        edition = create(edition_type)
        edition.stubs(:unpublishable_by?).returns(false)
        edition_class.stubs(:find).returns(edition)

        get :show, id: edition

        refute_select "form[action=?]", unpublish_admin_edition_path(edition)
      end
    end

    def should_allow_creating_of(edition_type)
      edition_class = edition_class_for(edition_type)

      test "new displays edition form" do
        get :new

        admin_editions_path = send("admin_#{edition_type.to_s.tableize}_path")
        assert_select "form#edition_new[action='#{admin_editions_path}']" do
          assert_select "input[name='edition[title]'][type='text']"
          assert_select "textarea[name='edition[summary]']" if edition_class.new.can_have_summary?
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

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
          title: "new-title",
          body: "new-body"
        )

        edition.reload
        assert_equal "new-title", edition.title
        assert_equal "new-body", edition.body
      end

      test "update should take the writer to the edition page" do
        edition = create(edition_type)

        put :update, id: edition, edition: controller_attributes_for_instance(edition, title: 'new-title', body: 'new-body')

        admin_edition_path = send("admin_#{edition_type}_path", edition)
        assert_redirected_to admin_edition_path
        assert_equal 'The document has been saved', flash[:notice]
      end

      test "update records the user who changed the edition" do
        edition = create(edition_type)

        put :update, id: edition, edition: controller_attributes_for_instance(edition, title: 'new-title', body: 'new-body')

        assert_equal current_user, edition.edition_authors(true).last.user
      end

      test "update records the previous version of the document in the edition version history" do
        edition = create(edition_type, title: 'old-title', body: 'old-body')

        assert_difference "edition.versions.size" do
          put :update, id: edition, edition: controller_attributes_for_instance(edition, title: 'new-title', body: 'new-body')
        end

        old_edition = edition.versions.last.reify
        assert_equal 'old-title', old_edition.title
        assert_equal 'old-body', old_edition.body
      end

      test "update with invalid data should not save the edition" do
        edition = create(edition_type)
        attributes = controller_attributes_for_instance(edition)

        put :update, id: edition, edition: attributes.merge(title: '')

        assert_equal attributes["title"], edition.reload.title
        assert_template "editions/edit"
        assert_equal 'There are some problems with the document', flash.now[:alert]
      end

      test "update with a stale edition should render edit page with conflicting edition" do
        edition = create("draft_#{edition_type}")
        lock_version = edition.lock_version
        edition.touch

        put :update, id: edition, edition: controller_attributes_for_instance(edition, lock_version: lock_version)

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

    def should_allow_attachment_references_for(edition_type)
      edition_class = edition_class_for(edition_type)

      test 'new should allow users to add reference metadata to an attachment' do
        get :new

        assert_select "form#edition_new" do
          assert_select "input[type=text][name='edition[edition_attachments_attributes][0][attachment_attributes][isbn]']"
          assert_select "input[type=text][name='edition[edition_attachments_attributes][0][attachment_attributes][unique_reference]']"
          assert_select "input[type=text][name='edition[edition_attachments_attributes][0][attachment_attributes][command_paper_number]']"
        end
      end

      test "create should create a new edition and attachment with additional publication metadata" do
        post :create, edition: controller_attributes_for(edition_type).merge({
          alternative_format_provider_id: create(:alternative_format_provider).id,
          edition_attachments_attributes: {
            "0" => { attachment_attributes: attributes_for(:attachment,
              title: "attachment-title",
              isbn: '0140621431',
              unique_reference: 'unique-reference',
              command_paper_number: 'Cm. 1234').merge(attachment_data_attributes: {
                file: fixture_file_upload('greenpaper.pdf', 'application/pdf')
              })
            }
          }
        })

        created_edition = edition_class.last
        assert_equal '0140621431', created_edition.attachments.first.isbn
        assert_equal 'unique-reference', created_edition.attachments.first.unique_reference
        assert_equal 'Cm. 1234', created_edition.attachments.first.command_paper_number
      end

      test "edit should allow users to assign edition metadata to an attachment" do
        edition = create(edition_type)
        attachment = create(:attachment)
        edition.attachments << attachment

        get :edit, id: edition

        assert_select "form#edition_edit" do
          assert_select "input[type=text][name='edition[edition_attachments_attributes][0][attachment_attributes][isbn]']"
          assert_select "input[type=text][name='edition[edition_attachments_attributes][0][attachment_attributes][unique_reference]']"
          assert_select "input[type=text][name='edition[edition_attachments_attributes][0][attachment_attributes][command_paper_number]']"
        end
      end
    end


    def should_show_inline_attachment_help_for(edition_type)
      edition_class = edition_class_for(edition_type)

      test 'edit shows markdown hint for first attachment' do
        draft_edition = create("draft_#{edition_type}", :with_attachment)
        get :edit, id: draft_edition

        assert_select "fieldset.attachments" do |nodes|
          assert_equal 1, nodes[0].select("input[readonly][value=!@1]").length
        end
      end

      test 'new shows markdown help for inline attachments' do
        get :new

        assert_select "#govspeak_help", text: /Attachments/
      end

      test 'edit shows markdown help for inline attachments' do
        draft_edition = create("draft_#{edition_type}")
        get :edit, id: draft_edition

        assert_select "#govspeak_help", text: /Attachments/
      end
    end

    def should_not_show_inline_attachment_help_for(edition_type)
      edition_class = edition_class_for(edition_type)

      test 'edit does not show markdown hint for first attachment' do
        draft_edition = create("draft_#{edition_type}", :with_attachment)
        get :edit, id: draft_edition

        assert_select "fieldset.attachments" do |nodes|
          assert_equal 0, nodes[0].select("input[readonly][value=!@1]").length
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
        image = fixture_file_upload('minister-of-funk.960x640.jpg')
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
        image = fixture_file_upload('minister-of-funk.960x640.jpg')
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
        image = fixture_file_upload('minister-of-funk.960x640.jpg')
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
        image = fixture_file_upload('minister-of-funk.960x640.jpg')
        attributes = controller_attributes_for(edition_type, title: "")
        attributes[:images_attributes] = {
          "0" => { alt_text: "some-alt-text",
                  image_data_attributes: attributes_for(:image_data, file: image) }
        }

        post :create, edition: attributes

        assert_select "form#edition_new" do
          assert_select "input[name='edition[images_attributes][0][alt_text]'][type='text'][value='some-alt-text']"
          assert_select "input[name='edition[images_attributes][0][image_data_attributes][file_cache]'][value$='minister-of-funk.960x640.jpg']"
          assert_select ".already_uploaded", text: "minister-of-funk.960x640.jpg already uploaded"
        end
      end

      test 'creating an edition with invalid data should not show any existing image info' do
        image = fixture_file_upload('minister-of-funk.960x640.jpg')
        attributes = controller_attributes_for(edition_type, title: "")
        attributes[:images_attributes] = {
          "0" => { alt_text: "some-alt-text",
                  image_data_attributes: attributes_for(:image_data, file: image) }
        }

        post :create, edition: attributes

        refute_select "p.image"
      end

      test "creating an edition with multiple images should attach all files" do
        image = fixture_file_upload('minister-of-funk.960x640.jpg')
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

      test 'creating an edition with an invalid image should show an error' do
        attributes = controller_attributes_for(edition_type)
        invalid_image = fixture_file_upload('horrible-image.64x96.jpg')

        post :create, edition: attributes.merge(
          images_attributes: {
            "0" => { alt_text: "alt-text", image_data_attributes: attributes_for(:image_data, file: invalid_image) }
          }
        )

        assert_select ".errors", text: "Images image data file must be 960px wide and 640px tall"
      end

      test 'edit displays edition image fields' do
        image = fixture_file_upload('minister-of-funk.960x640.jpg')
        edition = create(edition_type)
        image = create(:image, alt_text: "blah", edition: edition,
                       image_data_attributes: attributes_for(:image_data, file: image))

        get :edit, id: edition

        assert_select "form#edition_edit" do
          assert_select "input[name='edition[images_attributes][0][alt_text]'][type='text'][value='blah']"
          assert_select ".image" do
            assert_select "img[src$='minister-of-funk.960x640.jpg']"
          end
          assert_select "input[name='edition[images_attributes][1][alt_text]'][type='text']"
          assert_select "textarea[name='edition[images_attributes][1][caption]']"
          assert_select "input[name='edition[images_attributes][1][image_data_attributes][file]'][type='file']"
        end
      end

      test 'updating an edition should attach an image' do
        image = fixture_file_upload('minister-of-funk.960x640.jpg')
        edition = create(edition_type)

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
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

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
          images_attributes: {
            "0" => { alt_text: "alt-text", image_data_attributes: { file_cache: "" } }
          }
        )

        assert_select ".errors", text: "Images image data file can&#x27;t be blank"

        edition.reload
        assert_equal 0, edition.images.length
      end

      test 'updating an edition with an existing image allows image attributes to be changed' do
        edition = create(edition_type)
        image = edition.images.create!(alt_text: "old-alt-text", caption: 'old-caption')

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
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
        image = fixture_file_upload('minister-of-funk.960x640.jpg')
        attributes = controller_attributes_for_instance(edition)
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
        put :update, id: edition, edition: controller_attributes_for_instance(edition, title: "")

        assert_select "form#edition_edit" do
          assert_select "input[name='edition[images_attributes][0][image_data_attributes][file]'][type='file']"
        end
      end

      test "updating an edition with invalid data should only allow a single image to be selected for upload" do
        edition = create(edition_type)
        image = fixture_file_upload('minister-of-funk.960x640.jpg')
        attributes = controller_attributes_for_instance(edition, title: "")
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
        image = fixture_file_upload('minister-of-funk.960x640.jpg')
        attributes = controller_attributes_for_instance(edition, title: "")
        attributes[:images_attributes] = {
          "0" => { alt_text: "some-alt-text",
                  image_data_attributes: attributes_for(:image_data, file: image) }
        }

        put :update, id: edition, edition: attributes

        assert_select "form#edition_edit" do
          assert_select "input[name='edition[images_attributes][0][alt_text]'][value='some-alt-text']"
          assert_select "input[name='edition[images_attributes][0][image_data_attributes][file_cache]'][value$='minister-of-funk.960x640.jpg']"
          assert_select ".already_uploaded", text: "minister-of-funk.960x640.jpg already uploaded"
        end
      end

      test "updating a stale edition should still display image fields" do
        edition = create("draft_#{edition_type}")
        lock_version = edition.lock_version
        edition.touch

        put :update, id: edition, edition: controller_attributes_for_instance(edition, lock_version: lock_version)

        assert_select "form#edition_edit" do
          assert_select "input[name='edition[images_attributes][0][alt_text]'][type='text']"
          assert_select "textarea[name='edition[images_attributes][0][caption]']"
          assert_select "input[name='edition[images_attributes][0][image_data_attributes][file]'][type='file']"
        end
      end

      test "updating a stale edition should only allow a single image to be selected for upload" do
        edition = create(edition_type)
        image = fixture_file_upload('minister-of-funk.960x640.jpg')
        lock_version = edition.lock_version
        edition.touch
        attributes = controller_attributes_for_instance(edition, title: "", lock_version: lock_version)
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

        attributes = controller_attributes_for_instance(edition,
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
        edition = create(edition_type, body: "!!2")
        image1 = create(:image, edition: edition)
        image2 = create(:image, edition: edition)

        get :show, id: edition

        assert_select 'article .body figure.image.embedded img[src=?]', %r{#{image2.url}}
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

      test "show does not display the delete button for published editions" do
        published_edition = create("published_#{edition_type}")

        get :show, id: published_edition

        destroy_path = send("admin_#{edition_type}_path", published_edition)
        refute_select "input[type='submit'][value='Delete']"
      end

      test "show does not display the delete button for archived editions" do
        archived_edition = create("archived_#{edition_type}")

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

    def should_link_to_preview_version_when_not_published(edition_type)
      test "should link to preview version when not published" do
        draft_edition = create("draft_#{edition_type}")
        get :show, id: draft_edition
        assert_select link_to_preview_version_selector
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

    def should_allow_related_policies_for(document_type)
      edition_class = edition_class_for(document_type)

      test "new displays document form with related policies field" do
        draft_policy = create(:draft_policy)
        submitted_policy = create(:submitted_policy)
        rejected_policy = create(:rejected_policy)
        published_policy = create(:published_policy)
        archived_policy = create(:archived_policy)
        deleted_policy = create(:deleted_policy)

        get :new

        assert_select "form#edition_new" do
          assert_select "select[name*='edition[related_document_ids]']" do
            assert_select "option[value='#{draft_policy.document.id}']"
            assert_select "option[value='#{submitted_policy.document.id}']"
            assert_select "option[value='#{rejected_policy.document.id}']"
            assert_select "option[value='#{published_policy.document.id}']"
            refute_select "option[value='#{archived_policy.document.id}']"
            refute_select "option[value='#{deleted_policy.document.id}']"
          end
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

        put :update, id: document, edition: controller_attributes_for_instance(document,
          related_document_ids: [second_policy.document.id]
        )

        document = document.reload
        assert_equal [second_policy], document.related_policies
      end

      test "updating should remove all related policies if none in params" do
        policy = create(:policy)
        document = create(document_type, related_policies: [policy])

        put :update, id: document, edition: controller_attributes_for_instance(document, related_document_ids: [])

        document.reload
        assert_equal [], document.related_policies
      end

      test "updating a stale document should render edit page with conflicting document and its related policies" do
        policy = create(:policy)
        document = create(document_type, related_policies: [policy])
        lock_version = document.lock_version
        document.touch

        put :update, id: document, edition: controller_attributes_for_instance(document,
          lock_version: lock_version, related_document_ids: document.related_document_ids)

        assert_select ".document.conflict" do
          assert_select "h1", "Related policies"
          assert_select record_css_selector(policy)
        end
      end

      test "show displays related policies" do
        policy = create(:policy)
        document = create(document_type, related_policies: [policy])

        get :show, id: document

        assert_select_object policy
      end
    end

    def should_allow_references_to_statistical_data_sets_for(edition_type)
      edition_class = edition_class_for(edition_type)

      test "new should display statistical data sets field" do
        get :new

        assert_select "form#edition_new" do
          assert_select "select[name*='edition[statistical_data_set_document_ids]']"
        end
      end

      test "create should associate statistical data sets with edition" do
        first_data_set = create(:statistical_data_set, document: create(:document))
        second_data_set = create(:statistical_data_set, document: create(:document))
        attributes = controller_attributes_for(edition_type)

        post :create, edition: attributes.merge(
          statistical_data_set_document_ids: [first_data_set.document.id, second_data_set.document.id]
        )

        edition = edition_class.last
        assert_equal [first_data_set, second_data_set], edition.statistical_data_sets
      end

      test "edit should display edition statistical data sets field" do
        edition = create(edition_type)

        get :edit, id: edition

        assert_select "form#edition_edit" do
          assert_select "select[name*='edition[statistical_data_set_document_ids]']"
        end
      end

      test "update should associate statistical data sets with editions" do
        first_data_set = create(:statistical_data_set, document: create(:document))
        second_data_set = create(:statistical_data_set, document: create(:document))

        edition = create(edition_type, statistical_data_sets: [first_data_set])

        put :update, id: edition, edition: {
          statistical_data_set_document_ids: [second_data_set.document.id]
        }

        edition.reload
        assert_equal [second_data_set], edition.statistical_data_sets
      end

      test "update should remove all statistical data sets if none specified" do
        data_set = create(:statistical_data_set, document: create(:document))
        edition = create(edition_type, statistical_data_sets: [data_set])

        put :update, id: edition, edition: {}

        edition.reload
        assert_equal [], edition.statistical_data_sets
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
        assert_equal [first_organisation, second_organisation], edition.organisations.sort
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

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
          organisation_ids: [second_organisation.id]
        )

        edition.reload
        assert_equal [second_organisation], edition.organisations
      end

      test "update should remove all organisations if none specified" do
        organisation = create(:organisation)

        edition = create(edition_type, organisations: [organisation])

        put :update, id: edition, edition: controller_attributes_for_instance(edition, organisation_ids: [])

        edition.reload
        assert_equal [], edition.organisations
      end
    end

    def should_allow_association_with_topics(edition_type)
      edition_class = edition_class_for(edition_type)

      test "new should display topics field" do
        get :new

        assert_select "form#edition_new" do
          assert_select "select[name*='edition[topic_ids]']"
        end
      end

      test "create should associate topics with the edition" do
        first_topic = create(:topic)
        second_topic = create(:topic)
        attributes = controller_attributes_for(edition_type)

        post :create, edition: attributes.merge(
          topic_ids: [first_topic.id, second_topic.id]
        )

        assert edition = edition_class.last
        assert_equal [first_topic, second_topic], edition.topics
      end

      test "edit should display topics field" do
        edition = create("draft_#{edition_type}")

        get :edit, id: edition

        assert_select "form#edition_edit" do
          assert_select "select[name*='edition[topic_ids]']"
        end
      end

      test "update should associate topics with the edition" do
        first_topic = create(:topic)
        second_topic = create(:topic)

        edition = create("draft_#{edition_type}", topics: [first_topic])

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
          topic_ids: [second_topic.id]
        )

        edition.reload
        assert_equal [second_topic], edition.topics
      end

      test "update should remove all topics if none specified" do
        topic = create(:topic)

        edition = create("draft_#{edition_type}", topics: [topic])

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
          topic_ids: []
        )

        edition.reload
        assert_equal [], edition.topics
      end

      test "updating a stale document should render edit page with conflicting document and its related topics" do
        topic = create(:topic)
        edition = create(edition_type, topics: [topic])
        lock_version = edition.lock_version
        edition.touch

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
          lock_version: lock_version, topic_ids: edition.topic_ids
        )

        assert_select ".document.conflict" do
          assert_select "h1", "Topics"
          assert_select record_css_selector(topic)
        end
      end
    end

    def should_allow_role_appointments_for(edition_type)
      edition_class = edition_class_for(edition_type)

      test "new should display edition role appointments field" do
        get :new

        assert_select "form#edition_new" do
          assert_select "select[name*='edition[role_appointment_ids]']"
        end
      end

      test "create should associate role appointments with edition" do
        first_appointment = create(:role_appointment)
        second_appointment = create(:role_appointment)
        attributes = controller_attributes_for(edition_type)

        post :create, edition: attributes.merge(
          role_appointment_ids: [first_appointment.id, second_appointment.id]
        )

        edition = edition_class.last
        assert_equal [first_appointment, second_appointment], edition.role_appointments
      end

      test "edit should display edition role appointments field" do
        edition = create(edition_type)

        get :edit, id: edition

        assert_select "form#edition_edit" do
          assert_select "select[name*='edition[role_appointment_ids]']"
        end
      end

      test "update should associate role appointments with editions" do
        first_appointment = create(:role_appointment)
        second_appointment = create(:role_appointment)

        edition = create(edition_type, role_appointments: [first_appointment])

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
          role_appointment_ids: [second_appointment.id]
        )

        edition.reload
        assert_equal [second_appointment], edition.role_appointments
      end

      test "update should remove all role appointments if none specified" do
        appointment = create(:role_appointment)

        edition = create(edition_type, role_appointments: [appointment])

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
          role_appointment_ids: []
        )

        edition.reload
        assert_equal [], edition.role_appointments
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

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
          ministerial_role_ids: [second_minister.id]
        )

        edition.reload
        assert_equal [second_minister], edition.ministerial_roles
      end

      test "update should remove all ministerial roles if none specified" do
        minister = create(:ministerial_role)

        edition = create(edition_type, ministerial_roles: [minister])

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
          ministerial_role_ids: []
        )

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

          put :update, id: edition, edition: controller_attributes_for_instance(edition,
            title: 'new-title'
          )

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

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
          first_published_at: first_published_at
        )

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
          put :update, id: edition, edition: controller_attributes_for_instance(edition)
        end
      end
    end

    def should_allow_association_with_related_mainstream_content(edition_type)
      edition_class = edition_class_for(edition_type)

      test "new should display fields for related mainstream content" do
        get :new

        admin_editions_path = send("admin_#{edition_type}s_path")
        assert_select "form#edition_new[action='#{admin_editions_path}']" do
          assert_select "input[name*='edition[related_mainstream_content_url]']"
          assert_select "input[name*='edition[related_mainstream_content_title]']"
          assert_select "input[name*='edition[additional_related_mainstream_content_url]']"
          assert_select "input[name*='edition[additional_related_mainstream_content_title]']"
        end
      end

      test "edit should display fields for related mainstream content" do
        edition = create(edition_type)
        get :edit, id: edition

        admin_editions_path = send("admin_#{edition_type}_path", edition)
        assert_select "form#edition_edit[action='#{admin_editions_path}']" do
          assert_select "input[name*='edition[related_mainstream_content_url]']"
          assert_select "input[name*='edition[related_mainstream_content_title]']"
          assert_select "input[name*='edition[additional_related_mainstream_content_url]']"
          assert_select "input[name*='edition[additional_related_mainstream_content_title]']"
        end
      end

      test "create should allow setting of related mainstream content urls and titles" do
        post :create, edition: controller_attributes_for(edition_type).merge(
          related_mainstream_content_url: "http://mainstream/content",
          related_mainstream_content_title: "Some Mainstream Content",
          additional_related_mainstream_content_url: "http://mainstream/additional-content",
          additional_related_mainstream_content_title: "Some Additional Mainstream Content"
        )

        edition = edition_class.last
        assert_equal "http://mainstream/content", edition.related_mainstream_content_url
        assert_equal "Some Mainstream Content", edition.related_mainstream_content_title
        assert_equal "http://mainstream/additional-content", edition.additional_related_mainstream_content_url
        assert_equal "Some Additional Mainstream Content", edition.additional_related_mainstream_content_title
      end

      test "update should allow setting of a related mainstream content url and title" do
        edition = create(edition_type,
          related_mainstream_content_url: "http://mainstream/content",
          related_mainstream_content_title: "Some Mainstream Content",
          additional_related_mainstream_content_url: "http://mainstream/additional-content",
          additional_related_mainstream_content_title: "Some Additional Mainstream Content"
        )

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
          related_mainstream_content_url: "http://mainstream/updated-content",
          related_mainstream_content_title: "Some Updated Mainstream Content",
          additional_related_mainstream_content_url: "http://mainstream/updated-additional-content",
          additional_related_mainstream_content_title: "Some Updated Additional Mainstream Content"
        )

        edition.reload
        assert_equal "http://mainstream/updated-content", edition.related_mainstream_content_url
        assert_equal "Some Updated Mainstream Content", edition.related_mainstream_content_title
        assert_equal "http://mainstream/updated-additional-content", edition.additional_related_mainstream_content_url
        assert_equal "Some Updated Additional Mainstream Content", edition.additional_related_mainstream_content_title
      end

      test "show should list the links to mainstream content" do
        edition = create(edition_type,
          related_mainstream_content_url: "http://mainstream/content",
          related_mainstream_content_title: "Some Mainstream Content",
          additional_related_mainstream_content_url: "http://mainstream/additional-content",
          additional_related_mainstream_content_title: "Some Additional Mainstream Content"
        )

        get :show, id: edition

        assert_select '.related_mainstream_content' do
          assert_select "a[href='http://mainstream/content']", text: 'Some Mainstream Content'
          assert_select "a[href='http://mainstream/additional-content']", text: 'Some Additional Mainstream Content'
        end
      end

      test "show should indicate a lack of links to mainstream content" do
        edition = create(edition_type)
        get :show, id: edition
        assert_select '.related_mainstream_content', text: %r{doesn't have any related mainstream content}
      end
    end

    def should_allow_alternative_format_provider_for(edition_type)
      test "shows alternative format provider for #{edition_type}" do
        organisation = create(:organisation_with_alternative_format_contact_email, name: "Ministry of Pop")
        draft = create(:"draft_#{edition_type}", alternative_format_provider: organisation)

        get :show, id: draft

        assert_select "#associations a", organisation.name
      end

      test "when creating allow selection of alternative format provider for #{edition_type}" do
        get :new

        assert_select "form#edition_new" do
          assert_select "select[name='edition[alternative_format_provider_id]']"
        end
      end

      test "when editing allow selection of alternative format provider for #{edition_type}" do
        draft = create("draft_#{edition_type}")

        get :edit, id: draft

        assert_select "form#edition_edit" do
          assert_select "select[name='edition[alternative_format_provider_id]']"
        end
      end

      test "update should save modified #{edition_type} alternative format provider" do
        organisation = create(:organisation_with_alternative_format_contact_email)
        edition = create(edition_type)

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
          alternative_format_provider_id: organisation.id,
        )

        saved_edition = edition.reload
        assert_equal organisation, saved_edition.alternative_format_provider
      end
    end

    def should_allow_assignment_to_document_series(edition_type)
      test "when creating allows assignment to document series" do
        get :new

        assert_select "form#edition_new" do
          assert_select "select[name='edition[document_series_id]']"
        end
      end

      test "when editing allows assignment to document series" do
        series = create(:document_series)
        edition = create(edition_type, document_series: series)

        get :edit, id: edition

        assert_select "form#edition_edit" do
          assert_select "select[name='edition[document_series_id]']"
        end
      end

      test "shows assigned document series" do
        series = create(:document_series)
        edition = create(edition_type, document_series: series)

        get :show, id: edition

        assert_select_object(series)
      end
    end
  end
end
