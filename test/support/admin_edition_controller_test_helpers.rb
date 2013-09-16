module AdminEditionControllerTestHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def should_have_summary(edition_type)
      edition_class = class_for(edition_type)

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

    def should_allow_creating_of(edition_type)
      edition_class = class_for(edition_type)

      view_test "new displays edition form" do
        get :new

        admin_editions_path = send("admin_#{edition_type.to_s.tableize}_path")
        assert_select "form#new_edition[action='#{admin_editions_path}']" do
          assert_select "input[name='edition[title]'][type='text']"
          assert_select "textarea[name='edition[summary]']"
          assert_select "textarea[name='edition[body]']"
          assert_select "input[type='submit']"
        end
      end

      view_test "new form has previewable body" do
        get :new
        assert_select "textarea[name='edition[body]'].previewable"
      end

      view_test "new form has cancel link which takes the user to the list of drafts" do
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

      view_test "create with invalid data should indicate there was an error" do
        attributes = controller_attributes_for(edition_type)
        post :create, edition: attributes.merge(title: '')

        assert_select ".field_with_errors input[name='edition[title]']"
        assert_equal attributes[:body], assigns(:edition).body, "the valid data should not have been lost"
        assert_equal 'There are some problems with the document', flash.now[:alert]
      end

      test "removes blank space from titles for new editions" do
        attributes = controller_attributes_for(edition_type)

        post :create, edition: attributes.merge(title: '   my title   ')

        edition = edition_class.last
        assert_equal 'my title', edition.title
      end
    end

    def should_allow_editing_of(edition_type)
      should_report_editing_conflicts_of(edition_type)

      view_test "edit displays edition form" do
        edition = create(edition_type)

        get :edit, id: edition

        admin_edition_path = send("admin_#{edition_type}_path", edition)
        assert_select "form#edit_edition[action='#{admin_edition_path}']" do
          assert_select "input[name='edition[title]'][type='text']"
          assert_select "textarea[name='edition[body]']"
          assert_select "input[type='submit']"
        end
      end

      view_test "edit form has previewable body" do
        edition = create(edition_type)

        get :edit, id: edition

        assert_select "textarea[name='edition[body]'].previewable"
      end

      view_test "edit form has cancel link which takes the user back to edition" do
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

      test "removes blank space from titles for updated editions" do
        edition = create(edition_type)

        put :update, id: edition, edition: { title: '   my title    ' }

        assert_equal 'my title', edition.reload.title
      end
    end

    def should_allow_speed_tagging_of(edition_type)
      test "update should convert to draft and go to the next #{edition_type} when speed tagging" do
        edition = create("imported_#{edition_type}")
        edition2 = create("imported_#{edition_type}")

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
          title: "new-title",
          body: "new-body"
        ), speed_save_convert: 1

        edition.reload
        assert_equal "draft", edition.state
        assert_redirected_to send("admin_#{edition_type}_path", edition2)
      end
    end

    def should_allow_attached_images_for(edition_type)
      edition_class = class_for(edition_type)

      view_test "new displays edition image fields" do
        get :new

        assert_select "form#new_edition" do
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

      view_test "creating an edition with invalid data should still show image fields" do
        post :create, edition: controller_attributes_for(edition_type, title: "")

        assert_select "form#new_edition" do
          assert_select "input[name='edition[images_attributes][0][alt_text]'][type='text']"
          assert_select "textarea[name='edition[images_attributes][0][caption]']"
          assert_select "input[name='edition[images_attributes][0][image_data_attributes][file]'][type='file']"
        end
      end

      view_test "creating an edition with invalid data should only allow a single image to be selected for upload" do
        image = fixture_file_upload('minister-of-funk.960x640.jpg')
        attributes = controller_attributes_for(edition_type, title: "")
        attributes[:images_attributes] = {
          "0" => { alt_text: "some-alt-text",
                  image_data_attributes: attributes_for(:image_data, file: image) }
        }

        post :create, edition: attributes

        assert_select "form#new_edition" do
          assert_select "input[name*='edition[images_attributes]'][type='file']", count: 1
        end
      end

      view_test "creating an edition with invalid data but valid image data should still display the image data" do
        image = fixture_file_upload('minister-of-funk.960x640.jpg')
        attributes = controller_attributes_for(edition_type, title: "")
        attributes[:images_attributes] = {
          "0" => { alt_text: "some-alt-text",
                  image_data_attributes: attributes_for(:image_data, file: image) }
        }

        post :create, edition: attributes

        assert_select "form#new_edition" do
          assert_select "input[name='edition[images_attributes][0][alt_text]'][type='text'][value='some-alt-text']"
          assert_select "input[name='edition[images_attributes][0][image_data_attributes][file_cache]'][value$='minister-of-funk.960x640.jpg']"
          assert_select ".already_uploaded", text: "minister-of-funk.960x640.jpg already uploaded"
        end
      end

      view_test 'creating an edition with invalid data should not show any existing image info' do
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

      view_test 'creating an edition with an invalid image should show an error' do
        ImageSizeChecker.any_instance.stubs(:size_is?).returns false
        attributes = controller_attributes_for(edition_type)
        invalid_image = fixture_file_upload('horrible-image.64x96.jpg')

        post :create, edition: attributes.merge(
          images_attributes: {
            "0" => { alt_text: "alt-text", image_data_attributes: attributes_for(:image_data, file: invalid_image) }
          }
        )

        assert_select ".errors", text: "Images image data file must be 960px wide and 640px tall"
      end

      view_test 'edit displays edition image fields' do
        image = fixture_file_upload('minister-of-funk.960x640.jpg')
        edition = create(edition_type)
        image = create(:image, alt_text: "blah", edition: edition,
                       image_data_attributes: attributes_for(:image_data, file: image))

        get :edit, id: edition

        assert_select "form#edit_edition" do
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

      view_test 'updating an edition with image alt text but no file attachment should show a validation error' do
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

      view_test "updating an edition with invalid data should still allow image to be selected for upload" do
        edition = create(edition_type)
        put :update, id: edition, edition: controller_attributes_for_instance(edition, title: "")

        assert_select "form#edit_edition" do
          assert_select "input[name='edition[images_attributes][0][image_data_attributes][file]'][type='file']"
        end
      end

      view_test "updating an edition with invalid data should only allow a single image to be selected for upload" do
        edition = create(edition_type)
        image = fixture_file_upload('minister-of-funk.960x640.jpg')
        attributes = controller_attributes_for_instance(edition, title: "")
        attributes[:images_attributes] = {
          "0" => { alt_text: "some-alt-text",
                  image_data_attributes: attributes_for(:image_data, file: image) }
        }

        put :update, id: edition, edition: attributes

        assert_select "form#edit_edition" do
          assert_select "input[name*='edition[images_attributes]'][type='file']", count: 1
        end
      end

      view_test "updating an edition with invalid data and valid image data should display the image data" do
        edition = create(edition_type)
        image = fixture_file_upload('minister-of-funk.960x640.jpg')
        attributes = controller_attributes_for_instance(edition, title: "")
        attributes[:images_attributes] = {
          "0" => { alt_text: "some-alt-text",
                  image_data_attributes: attributes_for(:image_data, file: image) }
        }

        put :update, id: edition, edition: attributes

        assert_select "form#edit_edition" do
          assert_select "input[name='edition[images_attributes][0][alt_text]'][value='some-alt-text']"
          assert_select "input[name='edition[images_attributes][0][image_data_attributes][file_cache]'][value$='minister-of-funk.960x640.jpg']"
          assert_select ".already_uploaded", text: "minister-of-funk.960x640.jpg already uploaded"
        end
      end

      view_test "updating a stale edition should still display image fields" do
        edition = create("draft_#{edition_type}")
        lock_version = edition.lock_version
        edition.touch

        put :update, id: edition, edition: controller_attributes_for_instance(edition, lock_version: lock_version)

        assert_select "form#edit_edition" do
          assert_select "input[name='edition[images_attributes][0][alt_text]'][type='text']"
          assert_select "textarea[name='edition[images_attributes][0][caption]']"
          assert_select "input[name='edition[images_attributes][0][image_data_attributes][file]'][type='file']"
        end
      end

      view_test "updating a stale edition should only allow a single image to be selected for upload" do
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

        assert_select "form#edit_edition" do
          assert_select "input[name*='edition[images_attributes]'][type='file']", count: 1
        end
      end

      view_test 'updating should allow removal of images' do
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
    end

    def should_allow_related_policies_for(document_type)
      edition_class = class_for(document_type)

      view_test "new displays document form with related policies field" do
        draft_policy = create(:draft_policy)
        submitted_policy = create(:submitted_policy)
        rejected_policy = create(:rejected_policy)
        published_policy = create(:published_policy)
        archived_policy = create(:archived_policy)
        deleted_policy = create(:deleted_policy)

        get :new

        assert_select "form#new_edition" do
          assert_select "select[name*='edition[related_policy_ids]']" do
            assert_select "option[value='#{draft_policy.id}']"
            assert_select "option[value='#{submitted_policy.id}']"
            assert_select "option[value='#{rejected_policy.id}']"
            assert_select "option[value='#{published_policy.id}']"
            refute_select "option[value='#{archived_policy.id}']"
            refute_select "option[value='#{deleted_policy.id}']"
          end
        end
      end

      test "creating should create a new document with related policies" do
        first_policy = create(:policy)
        second_policy = create(:policy)
        attributes = controller_attributes_for(document_type)

        post :create, edition: attributes.merge(
          related_policy_ids: [first_policy.id, second_policy.id]
        )

        assert document = edition_class.last
        assert_equal [first_policy, second_policy], document.related_policies
      end

      view_test "edit displays document form with related policies field" do
        policy = create(:policy)
        document = create(document_type, related_editions: [policy])

        get :edit, id: document

        assert_select "form#edit_edition" do
          assert_select "select[name*='edition[related_policy_ids]']"
        end
      end

      test "updating should save modified document attributes with related policies" do
        first_policy = create(:policy)
        second_policy = create(:policy)
        document = create(document_type, related_editions: [first_policy])

        put :update, id: document, edition: controller_attributes_for_instance(document,
          related_policy_ids: [second_policy.id]
        )

        document = document.reload
        assert_equal [second_policy], document.related_policies
      end

      view_test "updating a stale document should render edit page with conflicting document and its related policies" do
        policy = create(:policy)
        document = create(document_type, related_editions: [policy])
        lock_version = document.lock_version
        document.touch

        put :update, id: document, edition: controller_attributes_for_instance(
          document,
          lock_version: lock_version,
          related_policy_ids: document.related_policy_ids
        )

        assert_select ".document.conflict" do
          assert_select "h1", "Related policies"
          assert_select record_css_selector(policy)
        end
      end
    end

    def should_allow_references_to_statistical_data_sets_for(edition_type)
      edition_class = class_for(edition_type)

      view_test "new should display statistical data sets field" do
        get :new

        assert_select "form#new_edition" do
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

      view_test "edit should display edition statistical data sets field" do
        edition = create(edition_type)

        get :edit, id: edition

        assert_select "form#edit_edition" do
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
    end

    def should_allow_organisations_for(edition_type)
      edition_class = class_for(edition_type)

      view_test "new should display edition organisations field" do
        get :new

        assert_select "form#new_edition" do
          assert_select "select[name*='edition[lead_organisation_ids][]']"
          assert_select "select[name*='edition[supporting_organisation_ids][]']"
        end
      end

      test "new should set first lead organisation to users organisation" do
        editors_org = create(:organisation)
        login_as create(:departmental_editor, organisation: editors_org)

        get :new

        assert_equal assigns(:edition).edition_organisations.first.organisation, editors_org
        assert_equal assigns(:edition).edition_organisations.first.lead, true
        assert_equal assigns(:edition).edition_organisations.first.lead_ordering, 0
      end

      test "create should associate organisations with edition" do
        first_organisation = create(:organisation)
        second_organisation = create(:organisation)
        attributes = controller_attributes_for(edition_type)

        post :create, edition: attributes.merge(
          lead_organisation_ids: [second_organisation.id, first_organisation.id]
        )

        edition = edition_class.last
        assert_equal [second_organisation, first_organisation], edition.lead_organisations
      end

      view_test "edit should display edition organisations field" do
        edition = create(edition_type)

        get :edit, id: edition

        assert_select "form#edit_edition" do
          assert_select "select[name*='edition[lead_organisation_ids][]']"
          assert_select "select[name*='edition[supporting_organisation_ids][]']"
        end
      end

      test "update should associate organisations with editions" do
        first_organisation = create(:organisation)
        second_organisation = create(:organisation)

        edition = create(edition_type, organisations: [first_organisation])

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
          lead_organisation_ids: [second_organisation.id]
        )

        edition.reload
        assert_equal [second_organisation], edition.lead_organisations
      end

      test "update should allow removal of an organisation" do
        organisation_1 = create(:organisation)
        organisation_2 = create(:organisation)

        edition = create(edition_type, organisations: [organisation_1, organisation_2])

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
          lead_organisation_ids: [organisation_2.id]
        )

        edition.reload
        assert_equal [organisation_2], edition.lead_organisations
      end

      test "update should allow swapping of an organisation from lead to supporting" do
        organisation_1 = create(:organisation)
        organisation_2 = create(:organisation)
        organisation_3 = create(:organisation)

        edition = create(edition_type, organisations: [organisation_1, organisation_2])
        edition.organisations << organisation_3

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
          lead_organisation_ids: [organisation_2.id, organisation_3.id],
          supporting_organisation_ids: [organisation_1.id]
        )

        edition.reload
        assert_equal [organisation_2, organisation_3], edition.lead_organisations
        assert_equal [organisation_1], edition.supporting_organisations
      end
    end

    def should_allow_association_with_topics(edition_type)
      edition_class = class_for(edition_type)

      view_test "new should display topics field" do
        get :new

        assert_select "form#new_edition" do
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

      view_test "edit should display topics field" do
        edition = create("draft_#{edition_type}")

        get :edit, id: edition

        assert_select "form#edit_edition" do
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

      view_test "updating a stale document should render edit page with conflicting document and its related topics" do
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
      edition_class = class_for(edition_type)

      view_test "new should display edition role appointments field" do
        get :new

        assert_select "form#new_edition" do
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

      view_test "edit should display edition role appointments field" do
        edition = create(edition_type)

        get :edit, id: edition

        assert_select "form#edit_edition" do
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
    end


    def should_allow_ministerial_roles_for(edition_type)
      edition_class = class_for(edition_type)

      view_test "new should display edition ministerial roles field" do
        get :new

        assert_select "form#new_edition" do
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

      view_test "edit should display edition ministerial roles field" do
        edition = create(edition_type)

        get :edit, id: edition

        assert_select "form#edit_edition" do
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
      edition_class = class_for(edition_type)

      view_test "new should display first_published_at fields" do
        get :new

        admin_editions_path = send("admin_#{edition_type.to_s.tableize}_path")
        assert_select "form#new_edition[action='#{admin_editions_path}']" do
          assert_select "label[for=edition_first_published_at]", text: "First published"
          assert_select "select[name*='edition[first_published_at']", count: 5
        end
      end

      view_test "edit should display first_published_at fields" do
        edition = create(edition_type)

        get :edit, id: edition

        admin_edition_path = send("admin_#{edition_type}_path", edition)
        assert_select "form#edit_edition[action='#{admin_edition_path}']" do
          assert_select "label[for=edition_first_published_at]", text: "First published"
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

    def should_allow_setting_first_published_at_during_speed_tagging(edition_type)
      view_test "show should display first_published_at fields when speed tagging" do
        edition = create("imported_#{edition_type}")

        get :show, id: edition

        assert_select "label[for=edition_first_published_at]", text: "First published *"
        assert_select "select[name*='edition[first_published_at']", count: 5
      end
    end

    def should_report_editing_conflicts_of(edition_type)
      test "editing an existing #{edition_type} should record a RecentEditionOpening" do
        edition = create(edition_type)
        get :edit, id: edition

        assert_equal [current_user], edition.reload.recent_edition_openings.map(&:editor)
      end

      view_test "should not see a warning when editing an edition that nobody has recently edited" do
        edition = create(edition_type)
        get :edit, id: edition

        refute_select ".editing_conflict"
      end

      view_test "should see a warning when editing an edition that someone else has recently edited" do
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
      edition_class = class_for(edition_type)

      view_test "new should display fields for related mainstream content" do
        get :new

        admin_editions_path = send("admin_#{edition_type}s_path")
        assert_select "form#new_edition[action='#{admin_editions_path}']" do
          assert_select "input[name*='edition[related_mainstream_content_url]']"
          assert_select "input[name*='edition[related_mainstream_content_title]']"
          assert_select "input[name*='edition[additional_related_mainstream_content_url]']"
          assert_select "input[name*='edition[additional_related_mainstream_content_title]']"
        end
      end

      view_test "edit should display fields for related mainstream content" do
        edition = create(edition_type)
        get :edit, id: edition

        admin_editions_path = send("admin_#{edition_type}_path", edition)
        assert_select "form#edit_edition[action='#{admin_editions_path}']" do
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
    end

    def should_allow_alternative_format_provider_for(edition_type)
      view_test "when creating allow selection of alternative format provider for #{edition_type}" do
        get :new

        assert_select "form#new_edition" do
          assert_select "select[name='edition[alternative_format_provider_id]']"
        end
      end

      view_test "when editing allow selection of alternative format provider for #{edition_type}" do
        draft = create("draft_#{edition_type}")

        get :edit, id: draft

        assert_select "form#edit_edition" do
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

    def should_allow_access_limiting_of(edition_type)
      edition_class = class_for(edition_type)

      test "create should record the access_limited flag" do
        controller.current_user.organisation = create(:organisation); controller.current_user.save!
        post :create, edition: controller_attributes_for(edition_type).merge(
          first_published_at: Date.parse("2010-10-21"),
          access_limited: '1',
          lead_organisation_ids: [controller.current_user.organisation_id]
        )

        created_publication = edition_class.last
        refute created_publication.nil?
        assert created_publication.access_limited?
      end

      view_test "edit displays persisted access_limited flag" do
        publication = create(edition_type, access_limited: false)

        get :edit, id: publication

        assert_select "form#edit_edition" do
          assert_select "input[name='edition[access_limited]'][type=checkbox]"
          assert_select "input[name='edition[access_limited]'][type=checkbox][checked=checked]", count: 0
        end
      end

      test "update records new value of access_limited flag" do
        controller.current_user.organisation = create(:organisation); controller.current_user.save!
        publication = create(edition_type, access_limited: false, organisations: [controller.current_user.organisation])

        new_attrs = controller_attributes_for_instance(publication, access_limited: '1')
        put :update, id: publication, edition: new_attrs

        assert publication.reload.access_limited?
      end
    end

    def should_allow_relevance_to_local_government_of(edition_type)
      edition_class = class_for(edition_type)

      test "create should record the relevant_to_local_government flag" do
        post :create, edition: controller_attributes_for(edition_type,
          first_published_at: Date.parse("2010-10-21"),
          relevant_to_local_government: '1'
        )

        assert created_publication = edition_class.last
        assert created_publication.relevant_to_local_government?
      end

      view_test "edit displays persisted relevant_to_local_government flag" do
        publication = create(edition_type, relevant_to_local_government: false)

        get :edit, id: publication

        assert_select "form#edit_edition" do
          assert_select "input[name='edition[relevant_to_local_government]'][type=checkbox]"
          assert_select "input[name='edition[relevant_to_local_government]'][type=checkbox][checked=checked]", count: 0
        end
      end

      test "update records new value of relevant_to_local_government flag" do
        publication = create(edition_type, relevant_to_local_government: false)

        new_attrs = controller_attributes_for_instance(publication, relevant_to_local_government: '1')
        put :update, id: publication, edition: new_attrs

        assert publication.reload.relevant_to_local_government?
      end
    end

    def should_allow_association_with_topical_events(edition_type)
      edition_class = class_for(edition_type)

      view_test "new should display topical events field" do
        get :new

        assert_select "form#new_edition" do
          assert_select "select[name*='edition[topical_event_ids]']"
        end
      end

      test "create should associate topical events with the edition" do
        first_topical_event = create(:topical_event)
        second_topical_event = create(:topical_event)
        attributes = controller_attributes_for(edition_type)

        post :create, edition: attributes.merge(
          topical_event_ids: [first_topical_event.id, second_topical_event.id]
        )

        assert edition = edition_class.last
        assert_equal [first_topical_event, second_topical_event], edition.topical_events
      end

      view_test "edit should display topical events field" do
        edition = create("draft_#{edition_type}")

        get :edit, id: edition

        assert_select "form#edit_edition" do
          assert_select "select[name*='edition[topical_event_ids]']"
        end
      end

      test "update should associate topical events with the edition" do
        first_topical_event = create(:topical_event)
        second_topical_event = create(:topical_event)

        edition = create("draft_#{edition_type}", topical_events: [first_topical_event])

        put :update, id: edition, edition: controller_attributes_for_instance(edition,
          topical_event_ids: [second_topical_event.id]
        )

        edition.reload
        assert_equal [second_topical_event], edition.topical_events
      end
    end

    def should_allow_association_with_worldwide_organisations(edition_type)
      edition_class = class_for(edition_type)

      view_test "new should display worldwide organisations field" do
        get :new

        assert_select "form#new_edition" do
          assert_select "select[name*='edition[worldwide_organisation_ids]']"
        end
      end

      test "should not populate world locations if user doesn't have any" do
        world_location = create(:world_location)
        login_as create(:departmental_editor, world_locations: [])
        get :new

        assert_equal assigns(:edition).world_locations, []
      end

      test "should populate world locations with the current users locations" do
        world_location = create(:world_location)
        login_as create(:departmental_editor, world_locations: [world_location])
        get :new

        assert_equal assigns(:edition).world_locations, [world_location]
      end

      test "create should associate worldwide organisations with the edition" do
        first_world_organisation = create(:worldwide_organisation)
        second_world_organisation = create(:worldwide_organisation)
        attributes = controller_attributes_for(edition_type)

        post :create, edition: attributes.merge(
          worldwide_organisation_ids: [first_world_organisation.id, second_world_organisation.id]
        )

        assert edition = edition_class.last
        assert_equal [first_world_organisation, second_world_organisation], edition.worldwide_organisations
      end
    end

    def should_allow_association_with_worldwide_priorities(edition_type)
      edition_class = class_for(edition_type)

      view_test "new should display worldwide priorities field" do
        get :new

        assert_select "form#new_edition" do
          assert_select "select[name*='edition[worldwide_priority_ids]']"
        end
      end

      test "create should associate worldwide priorities with the edition" do
        first_worldwide_priority = create(:worldwide_priority)
        second_worldwide_priority = create(:worldwide_priority)
        attributes = controller_attributes_for(edition_type)

        post :create, edition: attributes.merge(
          worldwide_priority_ids: [first_worldwide_priority.id, second_worldwide_priority.id]
        )

        assert edition = edition_class.last
        assert_equal [first_worldwide_priority, second_worldwide_priority], edition.worldwide_priorities
      end
    end

  end
end
