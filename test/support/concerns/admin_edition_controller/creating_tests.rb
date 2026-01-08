module AdminEditionController
  module CreatingTests
    extend ActiveSupport::Concern
    include ActionMailer::TestHelper

    included do
      view_test "new displays edition form" do
        get :new

        admin_editions_path = send("admin_#{edition_type.to_s.tableize}_path")
        assert_select "form#new_edition[action='#{admin_editions_path}']" do
          assert_select "textarea[name='edition[title]']"
          assert_select "textarea[name='edition[summary]']"
          assert_select "textarea[name='edition[body]']"
          assert_select "button[type='submit']"
        end
      end

      view_test "new form has previewable body" do
        get :new

        assert_select ".js-app-c-govspeak-editor__preview-button"
      end

      view_test "new form has cancel link which takes the user to the list of drafts" do
        get :new
        assert_select "a[href=?]", admin_editions_path, text: /cancel/i
      end

      test "create should create a new edition" do
        attributes = controller_attributes_for(edition_type)
        edition_class = class_for(edition_type)

        post :create,
             params: {
               edition: attributes,
             }

        edition = edition_class.last
        assert_equal attributes[:title], edition.title
        assert_equal attributes[:body], edition.body
      end

      test "create should take the writer to the document summary page" do
        organisation = create(:organisation)
        edition_class = class_for(edition_type)

        attributes = controller_attributes_for(edition_type).merge(
          publication_type_id: PublicationType::Guidance.id,
          lead_organisation_ids: [organisation.id],
        )

        post :create,
             params: {
               edition: attributes,
             }

        edition = edition_class.last
        assert_redirected_to @controller.admin_edition_path(edition)
        expected_message = if edition.requires_taxon?
                             "Your document has been saved. You need to <a class=\"govuk-link\" href=\"/government/admin/editions/#{edition.id}/tags/edit\">add topic tags</a> before you can publish this document."
                           else
                             "Your document has been saved"
                           end
        assert_equal expected_message, flash[:notice]
      end

      test "create should email content second line if the user is monitored" do
        Edition.any_instance.stubs(:should_alert_for?).returns(true)

        assert_emails 1 do
          post :create,
               params: {
                 edition: controller_attributes_for(edition_type),
               }
        end
      end

      test "create should not email content second line if the user is not monitored" do
        Edition.any_instance.stubs(:should_alert_for?).returns(false)

        assert_no_emails do
          post :create,
               params: {
                 edition: controller_attributes_for(edition_type),
               }
        end
      end

      test "create with invalid data should leave the writer in the document editor" do
        attributes = controller_attributes_for(edition_type)
        post :create,
             params: {
               edition: attributes.merge(title: ""),
             }

        assert_equal attributes[:body], assigns(:edition).body, "the valid data should not have been lost"
        assert_template "editions/new"
      end

      view_test "create with invalid data should indicate there was an error" do
        attributes = controller_attributes_for(edition_type)
        post :create,
             params: {
               edition: attributes.merge(title: ""),
             }

        assert_select ".gem-c-error-message.govuk-error-message", text: "Error: Title cannot be blank"
        assert_equal attributes[:body], assigns(:edition).body, "the valid data should not have been lost"
        assert_select ".govuk-error-summary a", text: "Title cannot be blank", href: "#edition_title"
      end

      test "removes blank space from titles for new editions" do
        attributes = controller_attributes_for(edition_type)
        edition_class = class_for(edition_type)

        post :create,
             params: {
               edition: attributes.merge(title: "   my title   "),
             }

        edition = edition_class.last
        assert_equal "my title", edition.title
      end
    end

  private

    def edition_type
      raise NotImplementedError, "You must define `edition_type` in your test class."
    end
  end
end
