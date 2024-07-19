require_relative "taxonomy_helper"

module AdminEditionControllerTestHelpers
  extend ActiveSupport::Concern
  include ActionMailer::TestHelper
  include TaxonomyHelper

  module ClassMethods
    def should_have_summary(edition_type)
      edition_class = class_for(edition_type)

      test "create should create a new #{edition_type} with summary" do
        attributes = controller_attributes_for(edition_type)

        post :create,
             params: {
               edition: attributes.merge(
                 summary: "my summary",
               ),
             }

        created_edition = edition_class.last
        assert_equal "my summary", created_edition.summary
      end

      test "update should save modified news article summary" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang

        put :update,
            params: {
              id: edition,
              edition: {
                summary: "new-summary",
              },
            }

        edition.reload
        assert_equal "new-summary", edition.summary
      end
    end

    def should_allow_creating_of(edition_type)
      edition_class = class_for(edition_type)

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

        assert_select(".js-app-c-govspeak-editor__preview-button")
      end

      view_test "new form has visual editor and no markdown help when flip flop enabled and user has permission" do
        feature_flags.switch!(:govspeak_visual_editor, true)
        current_user.permissions << User::Permissions::VISUAL_EDITOR_PRIVATE_BETA

        get :new

        assert_select(".app-c-visual-editor__container")
        assert_select ".govspeak-help", visible: false, count: 1
      end

      view_test "new form has cancel link which takes the user to the list of drafts" do
        get :new
        assert_select "a[href=?]", admin_editions_path, text: /cancel/i
      end

      test "create should create a new edition" do
        attributes = controller_attributes_for(edition_type)

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

        assert_select ".gem-c-error-message.govuk-error-message", text: "Error: Title can't be blank"
        assert_equal attributes[:body], assigns(:edition).body, "the valid data should not have been lost"
        assert_select ".govuk-error-summary a", text: "Title can't be blank", href: "#edition_title"
      end

      test "removes blank space from titles for new editions" do
        attributes = controller_attributes_for(edition_type)

        post :create,
             params: {
               edition: attributes.merge(title: "   my title   "),
             }

        edition = edition_class.last
        assert_equal "my title", edition.title
      end
    end

    def should_allow_editing_of(edition_type)
      should_report_editing_conflicts_of(edition_type)

      view_test "edit displays edition form" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang

        get :edit, params: { id: edition }

        admin_edition_path = send("admin_#{edition_type}_path", edition)
        assert_select "form#edit_edition[action='#{admin_edition_path}']" do
          assert_select "textarea[name='edition[title]']"
          assert_select "textarea[name='edition[body]']"
          assert_select "button[type='submit']"
        end
      end

      view_test "edit form has previewable body" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang

        get :edit, params: { id: edition }

        assert_select(".js-app-c-govspeak-editor__preview-button")
      end

      view_test "edit form renders visual editor and no markdown help when feature flag is enabled, user has permission, and edition has been saved with visual editor" do
        feature_flags.switch!(:govspeak_visual_editor, true)
        current_user.permissions << User::Permissions::VISUAL_EDITOR_PRIVATE_BETA

        edition = create(edition_type, visual_editor: true)

        get :edit, params: { id: edition }

        assert_select(".app-c-visual-editor__container")
        assert_select ".govspeak-help", visible: false, count: 1
      end

      view_test "edit form does not render visual editor, and renders the markdown help, for exited editions" do
        feature_flags.switch!(:govspeak_visual_editor, true)
        current_user.permissions << User::Permissions::VISUAL_EDITOR_PRIVATE_BETA

        edition = create(edition_type, visual_editor: false)

        get :edit, params: { id: edition }

        assert_select ".app-c-visual-editor__container", count: 0
        assert_select ".govspeak-help", count: 1
      end

      view_test "edit form does not render visual editor, and renders the markdown help, for pre-existing editions" do
        feature_flags.switch!(:govspeak_visual_editor, true)
        current_user.permissions << User::Permissions::VISUAL_EDITOR_PRIVATE_BETA

        edition = create(edition_type, visual_editor: nil)

        get :edit, params: { id: edition }

        assert_select ".app-c-visual-editor__container", count: 0
        assert_select ".govspeak-help", count: 1
      end

      view_test "edit form has cancel link which takes the user back to edition" do
        draft_edition = create("draft_#{edition_type}")

        get :edit, params: { id: draft_edition }

        admin_edition_path = send("admin_#{edition_type}_path", draft_edition)
        assert_select "a[href=?]", admin_edition_path, text: /cancel/i
      end

      test "update should save modified edition attributes" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang

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
        edition = create(edition_type) # rubocop:disable Rails/SaveBang

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
                             "Your document has been saved. You need to <a class=\"govuk-link\" href=\"/government/admin/editions/#{edition.id}/tags/edit\">add topic tags</a> before you can publish this document."
                           else
                             "Your document has been saved"
                           end
        assert_equal expected_message, flash[:notice]
      end

      test "update records the user who changed the edition" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang

        put :update,
            params: {
              id: edition,
              edition: {
                title: "new-title",
                body: "new-body",
              },
            }

        assert_equal current_user, edition.edition_authors.reload.last.user
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
        assert_select ".govuk-error-summary a", text: "Title can't be blank", href: "#edition_title"
      end

      test "update with a stale edition should render edit page with conflicting edition" do
        edition = create("draft_#{edition_type}")
        lock_version = edition.lock_version
        edition.touch

        put :update,
            params: {
              id: edition,
              edition: {
                lock_version:,
              },
            }

        assert_template "edit"
        conflicting_edition = edition.reload
        assert_equal conflicting_edition, assigns(:conflicting_edition)
        assert_equal conflicting_edition.lock_version, assigns(:edition).lock_version
        assert_equal %(This document has been saved since you opened it), flash[:alert]
      end

      test "removes blank space from titles for updated editions" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang

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
    end

    def should_send_drafts_to_content_preview_environment_for(edition_type)
      test "updating a draft edition sends the draft to the content preview environment" do
        edition = create("draft_#{edition_type}")

        Whitehall::PublishingApi.expects(:save_draft).with(
          all_of(
            responds_with(:model_name, "CaseStudy"),
            responds_with(:id, edition.id),
          ),
        )

        put :update, params: { id: edition, edition: { title: "updated title" } }
      end

      test "updating a submitted edition sends the draft to the content preview environment" do
        edition = create("submitted_#{edition_type}")

        Whitehall::PublishingApi.expects(:save_draft).with(
          all_of(
            responds_with(:model_name, "CaseStudy"),
            responds_with(:id, edition.id),
          ),
        )

        put :update,
            params: {
              id: edition,
              edition: {
                title: "updated title",
              },
            }
      end

      test "updating a rejected edition sends the draft to the content preview environment" do
        edition = create("rejected_#{edition_type}")

        Whitehall::PublishingApi.expects(:save_draft).with(
          all_of(
            responds_with(:model_name, "CaseStudy"),
            responds_with(:id, edition.id),
          ),
        )

        put :update,
            params: {
              id: edition,
              edition: {
                title: "updated title",
              },
            }
      end
    end

    def should_allow_references_to_statistical_data_sets_for(edition_type)
      edition_class = class_for(edition_type)

      view_test "new should display statistical data sets field" do
        get :new

        assert_select "form#new_edition" do
          assert_select "label[for=edition_statistical_data_set_document_ids]", text: "Statistical data sets"

          assert_select "#edition_statistical_data_set_document_ids" do |elements|
            assert_equal 1, elements.length
            assert_data_attributes_for_statistical_data_sets(
              element: elements.first,
              track_label: new_edition_path(edition_type),
            )
          end
        end
      end

      test "create should associate statistical data sets with edition" do
        first_data_set = create(:statistical_data_set, document: create(:document))
        second_data_set = create(:statistical_data_set, document: create(:document))
        attributes = controller_attributes_for(edition_type)

        post :create,
             params: {
               edition: attributes.merge(
                 statistical_data_set_document_ids: [first_data_set.document.id, second_data_set.document.id],
               ),
             }

        edition = edition_class.last
        assert_equal [first_data_set, second_data_set], edition.statistical_data_sets
      end

      view_test "edit should display edition statistical data sets field" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang

        get :edit, params: { id: edition }

        assert_select "form#edit_edition" do
          assert_select "label[for=edition_statistical_data_set_document_ids]", text: "Statistical data sets"

          assert_select "#edition_statistical_data_set_document_ids" do |elements|
            assert_equal 1, elements.length
            assert_data_attributes_for_statistical_data_sets(
              element: elements.first,
              track_label: edit_edition_path(edition_type),
            )
          end
        end
      end

      test "update should associate statistical data sets with editions" do
        first_data_set = create(:statistical_data_set, document: create(:document))
        second_data_set = create(:statistical_data_set, document: create(:document))

        edition = create(edition_type, statistical_data_sets: [first_data_set])

        put :update,
            params: {
              id: edition,
              edition: {
                statistical_data_set_document_ids: [second_data_set.document.id],
              },
            }

        edition.reload
        assert_equal [second_data_set], edition.statistical_data_sets
      end
    end

    def should_allow_lead_and_supporting_organisations_for(edition_type)
      edition_class = class_for(edition_type)

      view_test "new should display edition organisations fields" do
        get :new

        assert_select "form#new_edition" do
          (1..4).each do |i|
            assert_select "label[for=edition_lead_organisation_ids_#{i}]", text: "Lead organisation #{i}"

            assert_select("#edition_lead_organisation_ids_#{i}") do |elements|
              assert_equal 1, elements.length
              assert_data_attributes_for_lead_org(element: elements.first, track_label: new_edition_path(edition_type))
            end
          end
          refute_select "#edition_lead_organisation_ids_5"
          assert_select("#edition_supporting_organisation_ids_")
        end
      end

      test "new should set first lead organisation to users organisation" do
        editors_org = create(:organisation)
        @user = login_as create(:departmental_editor, organisation: editors_org)
        get :new

        assert_equal assigns(:edition).edition_organisations.first.organisation, editors_org
        assert_equal assigns(:edition).edition_organisations.first.lead, true
        assert_equal assigns(:edition).edition_organisations.first.lead_ordering, 0
      end

      test "create should associate organisations with edition" do
        first_organisation = create(:organisation)
        second_organisation = create(:organisation)
        attributes = controller_attributes_for(edition_type)

        post :create,
             params: {
               edition: attributes.merge(
                 lead_organisation_ids: [second_organisation.id, first_organisation.id],
               ),
             }

        edition = edition_class.last
        assert_equal [second_organisation, first_organisation], edition.lead_organisations
      end

      view_test "edit should display edition organisations field" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang

        get :edit, params: { id: edition }

        assert_select "form#edit_edition" do
          (1..4).each do |i|
            assert_select "label[for=edition_lead_organisation_ids_#{i}]", text: "Lead organisation #{i}"

            assert_select("#edition_lead_organisation_ids_#{i}") do |elements|
              assert_equal 1, elements.length
              assert_data_attributes_for_lead_org(element: elements.first, track_label: edit_edition_path(edition_type))
            end
          end
          refute_select "#edition_lead_organisation_ids_5"
          assert_select("#edition_supporting_organisation_ids_")
        end
      end

      test "update should associate organisations with editions" do
        first_organisation = create(:organisation)
        second_organisation = create(:organisation)

        edition = create(edition_type, organisations: [first_organisation])

        put :update,
            params: {
              id: edition,
              edition: {
                lead_organisation_ids: [second_organisation.id],
              },
            }

        edition.reload
        assert_equal [second_organisation], edition.lead_organisations
      end

      test "update should allow removal of an organisation" do
        organisation1 = create(:organisation)
        organisation2 = create(:organisation)

        edition = create(edition_type, organisations: [organisation1, organisation2])

        put :update,
            params: {
              id: edition,
              edition: {
                lead_organisation_ids: [organisation2.id],
              },
            }

        edition.reload
        assert_equal [organisation2], edition.lead_organisations
      end

      test "update should allow swapping of an organisation from lead to supporting" do
        organisation1 = create(:organisation)
        organisation2 = create(:organisation)
        organisation3 = create(:organisation)

        edition = create(edition_type, organisations: [organisation1, organisation2])
        edition.organisations << organisation3

        put :update,
            params: {
              id: edition,
              edition: {
                lead_organisation_ids: [organisation2.id, organisation3.id],
                supporting_organisation_ids: [organisation1.id],
              },
            }

        edition.reload
        assert_equal [organisation2, organisation3], edition.lead_organisations
        assert_equal [organisation1], edition.supporting_organisations
      end
    end

    def should_allow_only_lead_organisations_for(edition_type)
      edition_class = class_for(edition_type)

      view_test "new should display edition organisations fields" do
        get :new

        assert_select "form#new_edition" do
          (1..4).each do |i|
            assert_select "label[for=edition_lead_organisation_ids_#{i}]", text: "Lead organisation #{i}"

            assert_select("#edition_lead_organisation_ids_#{i}") do |elements|
              assert_equal 1, elements.length
              assert_data_attributes_for_lead_org(element: elements.first, track_label: new_edition_path(edition_type))
            end
          end
          refute_select "#edition_lead_organisation_ids_5"
          refute_select "#edition_supporting_organisation_ids_"
        end
      end

      test "new should set first lead organisation to users organisation" do
        editors_org = create(:organisation)
        @user = login_as create(:departmental_editor, organisation: editors_org)
        get :new

        assert_equal assigns(:edition).edition_organisations.first.organisation, editors_org
        assert_equal assigns(:edition).edition_organisations.first.lead, true
        assert_equal assigns(:edition).edition_organisations.first.lead_ordering, 0
      end

      test "create should associate organisations with edition" do
        first_organisation = create(:organisation)
        second_organisation = create(:organisation)
        attributes = controller_attributes_for(edition_type)

        post :create,
             params: {
               edition: attributes.merge(
                 lead_organisation_ids: [second_organisation.id, first_organisation.id],
               ),
             }

        edition = edition_class.last
        assert_equal [second_organisation, first_organisation], edition.lead_organisations
      end

      view_test "edit should display edition organisations field" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang

        get :edit, params: { id: edition }

        assert_select "form#edit_edition" do
          (1..4).each do |i|
            assert_select "label[for=edition_lead_organisation_ids_#{i}]", text: "Lead organisation #{i}"

            assert_select("#edition_lead_organisation_ids_#{i}") do |elements|
              assert_equal 1, elements.length
              assert_data_attributes_for_lead_org(element: elements.first, track_label: edit_edition_path(edition_type))
            end
          end
          refute_select "#edition_lead_organisation_ids_5"
          refute_select "#edition_supporting_organisation_ids_"
        end
      end

      test "update should associate organisations with editions" do
        first_organisation = create(:organisation)
        second_organisation = create(:organisation)

        edition = create(edition_type, organisations: [first_organisation])

        put :update,
            params: {
              id: edition,
              edition: {
                lead_organisation_ids: [second_organisation.id],
              },
            }

        edition.reload
        assert_equal [second_organisation], edition.lead_organisations
      end

      test "update should allow removal of an organisation" do
        organisation1 = create(:organisation)
        organisation2 = create(:organisation)

        edition = create(edition_type, organisations: [organisation1, organisation2])

        put :update,
            params: {
              id: edition,
              edition: {
                lead_organisation_ids: [organisation2.id],
              },
            }

        edition.reload
        assert_equal [organisation2], edition.lead_organisations
      end
    end

    def should_allow_role_appointments_for(edition_type)
      edition_class = class_for(edition_type)

      view_test "new should display edition role appointments field" do
        get :new

        assert_select "form#new_edition" do
          assert_select "label[for=edition_role_appointment_ids]", text: "Ministers"

          assert_select "#edition_role_appointment_ids" do |elements|
            assert_equal 1, elements.length
            assert_data_attributes_for_ministers(
              element: elements.first,
              track_label: new_edition_path(edition_type),
            )
          end
        end
      end

      test "create should associate role appointments with edition" do
        first_appointment = create(:role_appointment)
        second_appointment = create(:role_appointment)
        attributes = controller_attributes_for(edition_type)

        post :create,
             params: {
               edition: attributes.merge(
                 role_appointment_ids: [first_appointment.id, second_appointment.id],
               ),
             }

        edition = edition_class.last
        assert_equal [first_appointment, second_appointment], edition.role_appointments
      end

      view_test "edit should display edition role appointments field" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang

        get :edit, params: { id: edition }

        assert_select "form#edit_edition" do
          assert_select "select[name*='edition[role_appointment_ids]']"
        end
      end

      test "update should associate role appointments with editions" do
        first_appointment = create(:role_appointment)
        second_appointment = create(:role_appointment)

        edition = create(edition_type, role_appointments: [first_appointment])

        put :update,
            params: {
              id: edition,
              edition: {
                role_appointment_ids: [second_appointment.id],
              },
            }

        edition.reload
        assert_equal [second_appointment], edition.role_appointments
      end
    end

    def should_prevent_modification_of_unmodifiable(edition_type)
      (Edition::UNMODIFIABLE_STATES - %w[deleted]).each do |state|
        test "edit not allowed for #{state} #{edition_type}" do
          edition = create(edition_type.to_s, state.to_s)

          get :edit, params: { id: edition }

          assert_redirected_to send("admin_#{edition_type}_path", edition)
        end

        test "update not allowed for #{state} #{edition_type}" do
          edition = create(edition_type.to_s, state.to_s)

          put :update,
              params: {
                id: edition,
                edition: {
                  title: "new-title",
                },
              }

          assert_redirected_to send("admin_#{edition_type}_path", edition)
        end
      end
    end

    def should_allow_overriding_of_first_published_at_for(edition_type)
      edition_class = class_for(edition_type)

      test "create should save overridden first_published_at attribute" do
        first_published_at = 3.months.ago
        post :create,
             params: {
               edition: controller_attributes_for(edition_type).merge(first_published_at: 3.months.ago, previously_published: "true"),
             }

        edition = edition_class.last
        assert_equal first_published_at, edition.first_published_at
      end

      test "update should save overridden first_published_at attribute" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang
        first_published_at = 3.months.ago

        put :update,
            params: {
              id: edition,
              edition: {
                first_published_at:,
              },
            }

        edition.reload
        assert_equal first_published_at, edition.first_published_at
      end

      test "updates first_published_at to nil when previously_published is false" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang
        first_published_at = 3.months.ago

        patch :update, params: {
          id: edition,
          edition: {
            previously_published: "false",
            first_published_at:,
          },
        }

        assert_nil edition.reload.first_published_at
      end
    end

    def should_report_editing_conflicts_of(edition_type)
      test "editing an existing #{edition_type} should record a RecentEditionOpening" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang
        get :edit, params: { id: edition }

        assert_equal [current_user], edition.reload.recent_edition_openings.map(&:editor)
      end

      view_test "should not see a warning when editing an edition that nobody has recently edited" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang
        get :edit, params: { id: edition }

        refute_select ".editing_conflict"
      end

      view_test "should see a warning when editing an edition that someone else has recently edited" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang
        other_user = create(:author, name: "Joe Bloggs", email: "joe@example.com")
        edition.open_for_editing_as(other_user)
        Timecop.travel 1.hour.from_now

        request.env["HTTPS"] = "on"
        get :edit, params: { id: edition }

        assert_select ".govuk-notification-banner__heading", "Joe Bloggs started editing this #{edition.format_name} about 1 hour ago and hasn’t yet saved their work."
        assert_select ".govuk-notification-banner__content .govuk-govspeak", "Contact joe@example.com if you think they are still working on it."
      end

      view_test "should see a warning when editing an edition has been recently edited by multiple people" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang
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

      test "saving a #{edition_type} should remove any RecentEditionOpening records for the current user" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang
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

    def should_allow_association_with_related_mainstream_content(edition_type)
      edition_class = class_for(edition_type)

      view_test "new should display fields for related mainstream content" do
        get :new

        admin_editions_path = send("admin_#{edition_type}s_path")
        assert_select "form#new_edition[action='#{admin_editions_path}']" do
          assert_select "input[name*='edition[related_mainstream_content_url]']"
          assert_select "input[name*='edition[additional_related_mainstream_content_url]']"
        end
      end

      view_test "edit should display fields for related mainstream content" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang
        get :edit, params: { id: edition }

        admin_editions_path = send("admin_#{edition_type}_path", edition)
        assert_select "form#edit_edition[action='#{admin_editions_path}']" do
          assert_select "input[name*='edition[related_mainstream_content_url]']"
          assert_select "input[name*='edition[additional_related_mainstream_content_url]']"
        end
      end

      test "create should allow setting of related mainstream content urls" do
        Services.publishing_api.stubs(:lookup_content_ids).with(base_paths: ["/starting-to-export", "/vat-rates"]).returns("/starting-to-export" => "af70706d-1286-49a8-a597-b3715f29edb5", "/vat-rates" => "c621b246-aa0e-44ad-b320-5a9c16c1123b")

        post :create,
             params: {
               edition: controller_attributes_for(edition_type).merge(
                 related_mainstream_content_url: "https://www.gov.uk/starting-to-export",
                 additional_related_mainstream_content_url: "https://www.gov.uk/vat-rates",
               ),
             }

        edition = edition_class.last
        assert_equal "https://www.gov.uk/starting-to-export", edition.related_mainstream_content_url
        assert_equal "https://www.gov.uk/vat-rates", edition.additional_related_mainstream_content_url
      end

      test "update should allow setting of a related mainstream content url" do
        Services.publishing_api.stubs(:lookup_content_ids).with(base_paths: ["/starting-to-export", "/vat-rates"]).returns("/starting-to-export" => "af70706d-1286-49a8-a597-b3715f29edb5", "/vat-rates" => "c621b246-aa0e-44ad-b320-5a9c16c1123b")

        edition = create(
          edition_type,
          related_mainstream_content_url: "https://www.gov.uk/starting-to-export",
          additional_related_mainstream_content_url: "https://www.gov.uk/vat-rates",
        )
        Services.publishing_api.stubs(:lookup_content_ids).with(base_paths: ["/fishing-licences", "/set-up-business-uk"]).returns("/fishing-licences" => "bc46370c-2f2b-4db7-bf23-ace64b465eca", "/set-up-business-uk" => "5e5bb54d-e471-4d07-977b-291168569f26")

        put :update,
            params: {
              id: edition,
              edition: {
                related_mainstream_content_url: "https://www.gov.uk/fishing-licences",
                additional_related_mainstream_content_url: "https://www.gov.uk/set-up-business-uk",
              },
            }

        edition.reload
        assert_equal "https://www.gov.uk/fishing-licences", edition.related_mainstream_content_url
        assert_equal "https://www.gov.uk/set-up-business-uk", edition.additional_related_mainstream_content_url
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

        get :edit, params: { id: draft }

        assert_select "form#edit_edition" do
          assert_select "select[name='edition[alternative_format_provider_id]']"
        end
      end

      test "update should save modified #{edition_type} alternative format provider" do
        organisation = create(:organisation_with_alternative_format_contact_email)
        edition = create(edition_type) # rubocop:disable Rails/SaveBang

        put :update,
            params: {
              id: edition,
              edition: {
                alternative_format_provider_id: organisation.id,
              },
            }

        saved_edition = edition.reload
        assert_equal organisation, saved_edition.alternative_format_provider
      end
    end

    def should_allow_access_limiting_of(edition_type)
      edition_class = class_for(edition_type)

      test "create should record the access_limited flag" do
        organisation = create(:organisation)
        controller.current_user.organisation = organisation
        controller.current_user.save!

        post :create,
             params: {
               edition: controller_attributes_for(edition_type).merge(
                 first_published_at: Date.parse("2010-10-21"),
                 access_limited: "1",
                 lead_organisation_ids: [organisation.id],
               ),
             }

        created_publication = edition_class.last
        assert_not created_publication.nil?
        assert created_publication.access_limited?
      end

      view_test "edit displays persisted access_limited flag" do
        publication = create(edition_type, access_limited: false)

        get :edit, params: { id: publication }

        assert_select "form#edit_edition" do
          assert_select "input[name='edition[access_limited]'][type=checkbox]"
          assert_select "input[name='edition[access_limited]'][type=checkbox][checked=checked]", count: 0
        end
      end

      test "update records new value of access_limited flag" do
        controller.current_user.organisation = create(:organisation)
        controller.current_user.save!
        publication = create(edition_type, access_limited: false, organisations: [controller.current_user.organisation])

        put :update,
            params: {
              id: publication,
              edition: {
                access_limited: "1",
              },
            }

        assert publication.reload.access_limited?
      end
    end

    def should_allow_relevance_to_local_government_of(edition_type)
      edition_class = class_for(edition_type)

      test "create should record the relevant_to_local_government flag" do
        post :create,
             params: {
               edition: controller_attributes_for(
                 edition_type,
                 first_published_at: Date.parse("2010-10-21"),
                 relevant_to_local_government: "1",
               ),
             }

        created_publication = edition_class.last!
        assert created_publication.relevant_to_local_government?
      end

      view_test "edit displays persisted relevant_to_local_government flag" do
        publication = create(edition_type, relevant_to_local_government: false)

        get :edit, params: { id: publication }

        assert_select "form#edit_edition" do
          assert_select "input[name='edition[relevant_to_local_government]'][type=checkbox]"
          assert_select "input[name='edition[relevant_to_local_government]'][type=checkbox][checked=checked]", count: 0
        end
      end

      test "update records new value of relevant_to_local_government flag" do
        publication = create(edition_type, relevant_to_local_government: false)

        put :update,
            params: {
              id: publication,
              edition: {
                relevant_to_local_government: "1",
              },
            }

        assert publication.reload.relevant_to_local_government?
      end
    end

    def should_allow_association_with_topical_events(edition_type)
      edition_class = class_for(edition_type)

      view_test "new should display topical events field" do
        get :new

        assert_select "form#new_edition" do
          assert_select "label[for=edition_topical_event_ids]", text: "Topical events"

          assert_select "#edition_topical_event_ids" do |elements|
            assert_equal 1, elements.length
            assert_data_attributes_for_topical_events(
              element: elements.first,
              track_label: new_edition_path(edition_type),
            )
          end
        end
      end

      test "create should associate topical events with the edition" do
        first_topical_event = create(:topical_event)
        second_topical_event = create(:topical_event)
        attributes = controller_attributes_for(edition_type)

        post :create,
             params: {
               edition: attributes.merge(
                 topical_event_ids: [first_topical_event.id, second_topical_event.id],
               ),
             }

        edition = edition_class.last!
        assert_equal [first_topical_event, second_topical_event], edition.topical_events
      end

      view_test "edit should display topical events field" do
        edition = create("draft_#{edition_type}")

        get :edit, params: { id: edition }

        assert_select "form#edit_edition" do
          assert_select "label[for=edition_topical_event_ids]", text: "Topical events"

          assert_select "#edition_topical_event_ids" do |elements|
            assert_equal 1, elements.length
            assert_data_attributes_for_topical_events(
              element: elements.first,
              track_label: edit_edition_path(edition_type),
            )
          end
        end
      end

      test "update should associate topical events with the edition" do
        first_topical_event = create(:topical_event)
        second_topical_event = create(:topical_event)

        edition = create("draft_#{edition_type}", topical_events: [first_topical_event])

        put :update,
            params: {
              id: edition,
              edition: {
                topical_event_ids: [second_topical_event.id],
              },
            }

        edition.reload
        assert_equal [second_topical_event], edition.topical_events
      end
    end

    def should_allow_association_with_editionable_worldwide_organisations(edition_type, edition_parent_type: nil, factory_name: nil, required: false)
      factory_name ||= edition_type
      edition_class = edition_parent_type&.to_s&.classify&.constantize || class_for(edition_type)

      view_test "new should display editionable worldwide organisations field" do
        feature_flags.switch! :editionable_worldwide_organisations, true

        get :new

        assert_select "form#new_edition" do
          text = required ? "Worldwide organisations (required)" : "Worldwide organisations"
          assert_select("label[for=edition_editionable_worldwide_organisation_document_ids]", text:)

          assert_select "#edition_editionable_worldwide_organisation_document_ids" do |elements|
            assert_equal 1, elements.length
            assert_data_attributes_for_worldwide_organisations(
              element: elements.first,
              track_label: new_edition_path(edition_type, factory_name:),
            )
          end
        end
      end

      view_test "edit should display editionable worldwide organisations field" do
        feature_flags.switch! :editionable_worldwide_organisations, true

        edition = create(factory_name) # rubocop:disable Rails/SaveBang
        get :edit, params: { id: edition }

        assert_select "form#edit_edition" do
          text = required ? "Worldwide organisations (required)" : "Worldwide organisations"
          assert_select("label[for=edition_editionable_worldwide_organisation_document_ids]", text:)

          assert_select "#edition_editionable_worldwide_organisation_document_ids" do |elements|
            assert_equal 1, elements.length
            assert_data_attributes_for_worldwide_organisations(
              element: elements.first,
              track_label: edit_edition_path(edition_parent_type || edition_type),
            )
          end
        end
      end

      test "create should associate editionable worldwide organisations with the edition" do
        feature_flags.switch! :editionable_worldwide_organisations, true

        first_world_organisation = create(:editionable_worldwide_organisation, document: create(:document))
        second_world_organisation = create(:editionable_worldwide_organisation, document: create(:document))
        attributes = controller_attributes_for(edition_type)

        post :create,
             params: {
               edition: attributes.merge(
                 editionable_worldwide_organisation_document_ids: [first_world_organisation.document.id, second_world_organisation.document.id],
               ),
             }

        edition = edition_class.last!
        assert_equal [first_world_organisation, second_world_organisation], edition.editionable_worldwide_organisations
      end
    end

    def should_render_govspeak_history_and_fact_checking_tabs_for(edition_type)
      view_test "GET :show renders a side nav bar with history and fact checking" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang
        stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

        fact_checking_view_component = Admin::Editions::FactCheckingTabComponent.new(edition:)
        Admin::Editions::FactCheckingTabComponent.expects(:new).with { |value|
          value[:edition].title == edition.title && value[:send_request_section] == true
        }.returns(fact_checking_view_component)

        get :show, params: { id: edition }

        assert_select ".govuk-tabs__tab", text: "History"
        assert_select ".govuk-tabs__tab", text: "Fact checking"
      end

      view_test "GET :edit renders a side nav bar with govspeak help, history and fact checking" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang
        stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

        fact_checking_view_component = Admin::Editions::FactCheckingTabComponent.new(edition:)
        Admin::Editions::FactCheckingTabComponent.expects(:new).with { |value|
          value[:edition].title == edition.title
        }.returns(fact_checking_view_component)

        get :edit, params: { id: edition }

        assert_select ".govuk-tabs__tab", text: "Help"
        assert_select ".govuk-tabs__tab", text: "History"
        assert_select ".govuk-tabs__tab", text: "Fact checking"
      end
    end
  end

private

  def assert_data_attributes_for_ministers(element:, track_label:)
    # TODO: Add tracking back in. This is covered in this Trello card https://trello.com/c/eKGeFCQu/975-add-tracking-in-for-associations-on-the-edit-page
    # assert_equal "track-select-click", element["data-module"]
    # assert_equal "ministerSelection", element["data-track-category"]
    # assert_equal track_label, element["data-track-label"]
  end

  def assert_data_attributes_for_worldwide_organisations(element:, track_label:)
    # TODO: Add tracking back in. This is covered in this Trello card https://trello.com/c/eKGeFCQu/975-add-tracking-in-for-associations-on-the-edit-page
    # assert_equal "track-select-click", element["data-module"]
    # assert_equal "worldwideOrganisationSelection", element["data-track-category"]
    # assert_equal track_label, element["data-track-label"]
  end

  def assert_data_attributes_for_statistical_data_sets(element:, track_label:)
    # TODO: Add tracking back in. This is covered in this Trello card https://trello.com/c/eKGeFCQu/975-add-tracking-in-for-associations-on-the-edit-page
    # assert_equal "track-select-click", element["data-module"]
    # assert_equal "statisticalDataSetSelection", element["data-track-category"]
    # assert_equal track_label, element["data-track-label"]
  end

  def assert_data_attributes_for_topical_events(element:, track_label:)
    # TODO: Add tracking back in. This is covered in this Trello card https://trello.com/c/eKGeFCQu/975-add-tracking-in-for-associations-on-the-edit-page
    # assert_equal "track-select-click", element["data-module"]
    # assert_equal "topicalEventSelection", element["data-track-category"]
    # assert_equal track_label, element["data-track-label"]
  end

  def assert_data_attributes_for_lead_org(element:, track_label:)
    # TODO: Add tracking back in. This is covered in this Trello card https://trello.com/c/eKGeFCQu/975-add-tracking-in-for-associations-on-the-edit-page
    # assert_equal "track-select-click", element["data-module"]
    # assert_equal "leadOrgSelection", element["data-track-category"]
    # assert_equal track_label, element["data-track-label"]
  end

  def new_edition_path(edition_type, factory_name: nil)
    factory_name ||= edition_type
    edition = build(factory_name)
    @controller.new_polymorphic_path([:admin, edition])
  end

  def edit_edition_path(edition)
    @controller.edit_polymorphic_path([:admin, edition])
  end
end
