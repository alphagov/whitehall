# rubocop:disable Rails/SaveBang
module AdminEditionController
  module EditionEditingTests
    extend ActiveSupport::Concern

    included do
      view_test "edit displays edition form" do
        edition = create(edition_type)

        get :edit, params: { id: edition }

        admin_edition_path = send("admin_#{edition_type}_path", edition)
        assert_select "form#edit_edition[action='#{admin_edition_path}']" do
          assert_select "textarea[name='edition[title]']"
          assert_select "textarea[name='edition[body]']"
          assert_select "button[type='submit']"
        end
      end

      view_test "edit form has previewable body" do
        edition = create(edition_type)

        get :edit, params: { id: edition }

        assert_select(".js-app-c-govspeak-editor__preview-button")
      end

      view_test "edit form has cancel link which takes the user back to edition" do
        draft_edition = create("draft_#{edition_type}")

        get :edit, params: { id: draft_edition }

        admin_edition_path = send("admin_#{edition_type}_path", draft_edition)
        assert_select "a[href=?]", admin_edition_path, text: /cancel/i
      end

      view_test "GET :edit on published edition shows read-only version of the form" do
        published_edition = create("published_#{edition_type}")

        get :edit, params: { id: published_edition }

        assert_select ".govuk-inset-text", text: "This is a read-only view of the current (published) edition. To edit, please return to the summary page and choose ‘Create new edition’."
        assert_select "form fieldset[disabled='disabled']" do
          assert_select "textarea[name='edition[body]']", published_edition.body
          assert_select "textarea[name='edition[summary]']", published_edition.summary
        end

        refute_select ".app-c-secondary-navigation"
        assert_select ".govuk-back-link", text: "Back"
      end

      test "update should save modified edition attributes" do
        edition = create(edition_type)

        put :update,
            params: {
              id: edition,
              edition: {
                title: "new-title",
                body: "new-body",
              },
            }

        edition.reload
        assert_equal "new-title", edition.title
        assert_equal "new-body", edition.body
      end

      test "update should take the writer to the document summary page after updating" do
        edition = create(edition_type)
        organisation = create(:organisation)

        put :update,
            params: {
              id: edition,
              edition: {
                lead_organisation_ids: [organisation.id],
              },
            }

        assert_redirected_to @controller.admin_edition_path(edition)
        expected_message = if edition.requires_taxon?
                             "Your document has been saved. You need to <a class=\"govuk-link\" href=\"\/government\/admin\/editions\/#{edition.id}\/tags\/edit\">add topic tags</a> before you can publish this document."
                           else
                             "Your document has been saved"
                           end
        assert_equal expected_message, flash[:notice]
      end

      test "update records the user who changed the edition" do
        edition = create(edition_type)

        put :update,
            params: {
              id: edition,
              edition: {
                title: "new-title",
                body: "new-body",
              },
            }

        assert_equal @controller.current_user, edition.edition_authors.reload.last.user
      end

      view_test "update with invalid data should not save the edition" do
        edition = create(edition_type, title: "A Title")

        put :update,
            params: {
              id: edition,
              edition: {
                title: "",
              },
            }

        assert_equal "A Title", edition.reload.title
        assert_template "editions/edit"
        assert_select ".govuk-error-summary a", text: "Title cannot be blank", href: "#edition_title"
      end

      test "update with a stale edition should render edit page with conflicting edition" do
        edition = create("draft_#{edition_type}")
        lock_version = edition.lock_version
        edition.touch

        put :update,
            params: {
              id: edition,
              edition: {
                lock_version: lock_version,
              },
            }

        assert_template "edit"
        conflicting_edition = edition.reload
        assert_equal conflicting_edition, assigns(:conflicting_edition)
        assert_equal conflicting_edition.lock_version, assigns(:edition).lock_version
        assert_equal %(This document has been saved since you opened it), flash[:alert]
      end

      test "removes blank space from titles for updated editions" do
        edition = create(edition_type)

        put :update,
            params: {
              id: edition,
              edition: {
                title: "   my title    ",
                previously_published: false,
              },
            }

        assert_equal "my title", edition.reload.title
      end

      test "editing an existing edition should record a RecentEditionOpening" do
        edition = create(edition_type)
        get :edit, params: { id: edition }

        assert_equal [current_user], edition.reload.recent_edition_openings.map(&:editor)
      end

      test "viewing a read-only edit form for an existing edition should not record a RecentEditionOpening" do
        published_edition = create("published_#{edition_type}")

        get :edit, params: { id: published_edition }

        assert_equal [], published_edition.reload.recent_edition_openings.map(&:editor)
      end

      view_test "should not see a warning when editing an edition that nobody has recently edited" do
        edition = create(edition_type)
        get :edit, params: { id: edition }

        refute_select ".editing_conflict"
      end

      view_test "should see a warning when editing an edition that someone else has recently edited" do
        edition = create(edition_type)
        other_user = create(:author, name: "Joe Bloggs", email: "joe@example.com")
        edition.open_for_editing_as(other_user)
        Timecop.travel 1.hour.from_now

        request.env["HTTPS"] = "on"
        get :edit, params: { id: edition }

        assert_select ".govuk-notification-banner__heading", "Joe Bloggs started editing this #{edition.format_name} about 1 hour ago and hasn’t yet saved their work."
        assert_select ".govuk-notification-banner__content .govuk-govspeak", "Contact joe@example.com if you think they are still working on it."
      end

      view_test "should see a warning when editing an edition has been recently edited by multiple people" do
        edition = create(edition_type)
        other_user = create(:author, name: "Joe Bloggs", email: "joe@example.com")
        third_user = create(:author, name: "Josie Bloggs", email: "josie@example.com")
        edition.open_for_editing_as(other_user)
        edition.open_for_editing_as(third_user)
        Timecop.travel 1.hour.from_now

        request.env["HTTPS"] = "on"
        get :edit, params: { id: edition }

        assert_select ".govuk-notification-banner__heading", "Multiple people have started editing this #{edition.format_name}:"
        assert_select ".govuk-notification-banner__content li", "Joe Bloggs started editing this #{edition.format_name} about 1 hour ago and hasn’t yet saved their work. Contact joe@example.com if you think they are still working on it."
        assert_equal assert_select(".govuk-notification-banner__content li")[1].text.strip, "Josie Bloggs started editing this #{edition.format_name} about 1 hour ago and hasn’t yet saved their work. Contact josie@example.com if you think they are still working on it."
      end

      test "saving should remove any RecentEditionOpening records for the current user" do
        edition = create(edition_type)
        edition.open_for_editing_as(@current_user)

        assert_difference "edition.reload.recent_edition_openings.count", -1 do
          put :update,
              params: {
                id: edition,
                edition: {
                  summary: "A summary",
                },
              }
        end
      end
    end

  private

    def edition_type
      raise NotImplementedError, "You must define `edition_type` in your test class."
    end
  end
end
# rubocop:enable Rails/SaveBang
