require "test_helper"

class Admin::EditionAccessLimitedControllerTest < ActionController::TestCase
  setup do
    login_as :gds_admin
  end

  should_be_an_admin_controller

  test "GET :edit should be forbidden unless user is a GDS Admin" do
    edition = create(:consultation)
    login_as :gds_editor
    get :edit, params: { id: edition }
    assert_response :forbidden
  end

  view_test "GET :edit should show radio buttons instead of checkbox when access_limiting_organisations_ui flag is on" do
    feature_flags.switch! :access_limiting_organisations_ui, true
    feature_flags.switch! :access_limiting_individuals_ui, true

    organisation = create(:organisation)
    edition = create(
      :consultation,
      access_limiting: "none",
      create_default_organisation: false,
      lead_organisations: [organisation],
    )

    get :edit, params: { id: edition }

    assert_select "input[name='edition[access_limiting]'][type=radio][value=none]"
    assert_select "input[name='edition[access_limiting]'][type=radio][value=organisations]"
    assert_select "input[name='edition[access_limiting]'][type=radio][value=individuals]"
    assert_select "input[name='edition[access_limited]'][type=checkbox]", count: 0
  end

  view_test "GET :edit shows the persisted editions's access limiting value when flag is on" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    organisation = create(:organisation)
    edition = create(
      :consultation,
      access_limiting: "organisations",
      create_default_organisation: false,
      lead_organisations: [organisation],
      access_limiting_organisation_ids: [organisation.id],
    )

    get :edit, params: { id: edition }

    assert_select "input[name='edition[access_limiting]'][value='organisations'][checked=checked]"
    assert_select "select[name='edition[access_limiting_organisation_ids][]']" do
      assert_select "option[selected='selected'][value='#{organisation.id}']"
    end
  end

  view_test "GET :edit shows the persisted editions's access limiting value, and preserves already set access limiting organisations, when flag is turned off" do
    organisation = create(:organisation)
    edition = create(
      :consultation,
      access_limiting: "organisations",
      create_default_organisation: false,
      lead_organisations: [organisation],
      access_limiting_organisation_ids: [organisation.id],
    )

    feature_flags.switch! :access_limiting_organisations_ui, false

    get :edit, params: { id: edition }

    assert edition.access_limited?
    assert_equal "organisations", edition.access_limiting
    assert edition.access_limiting_organisations.exists?(id: organisation.id)
    assert_select "input[name='edition[access_limiting]'][value='organisations'][checked=checked]"
    refute_select "select[name='edition[access_limiting_organisation_ids][]']"
  end

  test "PATCH :update should be forbidden unless user is a GDS Admin" do
    edition = create(:consultation)
    login_as :gds_editor
    patch :update, params: { id: edition }
    assert_response :forbidden
  end

  test "PATCH :update should update editions organisations and create an editorial remark" do
    first_organisation = create(:organisation)
    second_organisation = create(:organisation)
    third_organisation = create(:organisation)

    edition = create(
      :consultation,
      access_limiting: "organisations",
      access_limiting_organisation_ids: [first_organisation.id],
      create_default_organisation: false,
      lead_organisations: [first_organisation],
      supporting_organisations: [second_organisation],
    )

    editorial_remark = "Updating the organisations at the users request."

    patch :update,
          params: {
            id: edition,
            edition: {
              lead_organisation_ids: [second_organisation.id],
              supporting_organisation_ids: [third_organisation.id],
              editorial_remark:,
              access_limiting: "organisations",
            },
          }

    assert_equal [second_organisation], edition.reload.lead_organisations
    assert_equal [third_organisation], edition.supporting_organisations
    assert_redirected_to admin_editions_path
    assert_equal "Access updated for #{edition.title}", flash[:notice]
    assert_equal "Access options updated by GDS Admin: #{editorial_remark}", edition.editorial_remarks.last.body
  end

  test "PATCH :update changes access limiting from 'none' to 'organisations' and creates an editorial remark" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    organisation = create(:organisation)
    edition = create(
      :consultation,
      access_limiting: "none",
      create_default_organisation: false,
      lead_organisations: [organisation],
    )

    editorial_remark = "Update access limiting to custom organisations."

    patch :update,
          params: {
            id: edition,
            edition: {
              lead_organisation_ids: [organisation.id],
              access_limiting: "organisations",
              access_limiting_organisation_ids: [organisation.id.to_s],
              editorial_remark: editorial_remark,
            },
          }

    assert_redirected_to admin_editions_path
    assert_equal "organisations", edition.reload.access_limiting
    assert edition.access_limiting_organisations.exists?(id: organisation.id)
    assert_equal "Access updated for #{edition.title}", flash[:notice]
    assert_equal "Access options updated by GDS Admin: #{editorial_remark}", edition.editorial_remarks.last.body
  end

  test "PATCH :update changes access limiting from 'organisations' to 'none', clears access limiting organisations, and creates an editorial remark" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    organisation = create(:organisation)
    edition = create(
      :consultation,
      access_limiting: "organisations",
      create_default_organisation: false,
      lead_organisations: [organisation],
      access_limiting_organisation_ids: [organisation.id],
    )
    editorial_remark = "Removing access limited at the users request."

    patch :update,
          params: {
            id: edition,
            edition: {
              lead_organisation_ids: [organisation.id],
              access_limiting: "none",
              access_limiting_organisation_ids: [organisation.id],
              editorial_remark: editorial_remark,
            },
          }

    assert_redirected_to admin_editions_path
    assert_equal "none", edition.reload.access_limiting
    assert_empty edition.access_limiting_organisations
    assert_equal "Access updated for #{edition.title}", flash[:notice]
    assert_equal "Access options updated by GDS Admin: #{editorial_remark}", edition.editorial_remarks.last.body
  end

  test "PATCH :update fails and re-renders edit template when editorial remark is not provided" do
    feature_flags.switch! :access_limiting_organisations_ui, true
    organisation = create(:organisation)
    edition = create(
      :consultation,
      access_limiting: "organisations",
      create_default_organisation: false,
      lead_organisations: [organisation],
      access_limiting_organisation_ids: [organisation.id],
    )

    patch :update,
          params: {
            id: edition,
            edition: {
              lead_organisation_ids: [organisation.id],
              editorial_remark: "",
              access_limiting: "none",
            },
          }

    assert_template :edit
    assert_equal "organisations", edition.reload.access_limiting
    assert_equal ["Editorial remark cannot be blank"], assigns(:edition).errors.full_messages
  end

  view_test "PATCH :update fails and renders edit template with submitted access limiting organisations, when access limiting organisations empty" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    organisation = create(:organisation)
    edition = create(
      :consultation,
      access_limiting: "organisations",
      create_default_organisation: false,
      lead_organisations: [organisation],
      access_limiting_organisation_ids: [organisation.id],
    )

    patch :update,
          params: {
            id: edition,
            edition: {
              lead_organisation_ids: [organisation.id],
              access_limiting: "organisations",
              access_limiting_organisation_ids: [""],
              editorial_remark: "Test",
            },
          }

    assert_template :edit
    assert_select ".govuk-error-summary a", text: "Access limiting organisations must include at least one organisation", href: "#access_limiting_organisation_ids"
    assert_select "form#edit_edition" do
      assert_select "input[name='edition[access_limiting]'][value='organisations'][checked=checked]"
      assert_select "select[name='edition[access_limiting_organisation_ids][]']" do
        refute_select "option[selected='selected'][value='#{organisation.id}']"
      end
    end
    assert_equal "organisations", edition.reload.access_limiting
    assert edition.access_limiting_organisations.exists?(id: organisation.id)
  end

  view_test "PATCH :update re-renders the edit template with the submitted access limiting organisations and editorial remark, when unrelated field fails validation" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    organisation = create(:organisation)
    new_organisation = create(:organisation)
    edition = create(
      :consultation,
      access_limiting: "organisations",
      create_default_organisation: false,
      lead_organisations: [organisation],
      access_limiting_organisation_ids: [organisation.id],
    )

    patch :update,
          params: {
            id: edition,
            edition: {
              lead_organisation_ids: [""],
              access_limiting: "organisations",
              access_limiting_organisation_ids: [organisation.id, new_organisation.id],
              editorial_remark: "Test",
            },
          }

    assert_template :edit
    assert_equal ["Lead organisation ids at least one required"], assigns(:edition).errors.full_messages
    assert_select "input[name='edition[access_limiting]'][value='organisations'][checked=checked]"
    assert_select "select[name='edition[access_limiting_organisation_ids][]']" do
      assert_select "option[selected='selected'][value='#{organisation.id}']"
      assert_select "option[selected='selected'][value='#{new_organisation.id}']"
    end
    assert_select "textarea[name='edition[editorial_remark]']", text: "Test"
    assert_equal [organisation.id], edition.reload.access_limiting_organisation_ids
  end

  test "PATCH :update clears access_limiting_organisations when switching to individuals" do
    feature_flags.switch! :access_limiting_organisations_ui, true
    feature_flags.switch! :access_limiting_individuals_ui, true

    organisation = create(:organisation)
    edition = create(
      :consultation,
      access_limiting: :organisations,
      access_limiting_organisation_ids: [organisation.id],
    )

    # The form resubmits the values of the other radio buttons. They get cleared in the controller.
    put :update,
        params: {
          id: edition,
          edition: {
            access_limiting: "individuals",
            access_limiting_individual_emails: "user@example.com",
            access_limiting_organisation_ids: [organisation.id],
            editorial_remark: "Switching to individual access limiting",
          },
        }

    assert_redirected_to admin_editions_path
    assert edition.reload.access_limited?
    assert_empty edition.access_limiting_organisations
    assert edition.access_limiting_individuals.exists?(email: "user@example.com")
  end

  test "PATCH :update clears access_limiting_individuals when switching to organisations" do
    feature_flags.switch! :access_limiting_organisations_ui, true
    feature_flags.switch! :access_limiting_individuals_ui, true

    organisation = create(:organisation)
    edition = create(
      :consultation,
      access_limiting: :individuals,
      access_limiting_individual_emails: "user@example.com",
    )

    # The form resubmits the values of the other radio buttons. They get cleared in the controller.
    put :update,
        params: {
          id: edition,
          edition: {
            access_limiting: "organisations",
            access_limiting_individual_emails: "user@example.com",
            access_limiting_organisation_ids: [organisation.id.to_s],
            editorial_remark: "Switching to organisation access limiting",
          },
        }

    assert_redirected_to admin_editions_path
    assert edition.reload.access_limited?
    assert edition.access_limiting_organisations.exists?(id: organisation.id)
    assert_empty edition.access_limiting_individuals
  end

  test "PATCH :update clears both access_limiting_organisations and access_limiting_individuals when switching to none" do
    feature_flags.switch! :access_limiting_organisations_ui, true
    feature_flags.switch! :access_limiting_individuals_ui, true

    organisation = create(:organisation)
    edition = create(
      :consultation,
      access_limiting: :individuals,
      access_limiting_individual_emails: "user@example.com",
    )

    # The form resubmits the values of the other radio buttons. They get cleared in the controller.
    put :update,
        params: {
          id: edition,
          edition: {
            access_limiting: "none",
            access_limiting_individual_emails: "user@example.com",
            access_limiting_organisation_ids: [organisation.id],
            editorial_remark: "Removing all access limiting",
          },
        }

    assert_redirected_to admin_editions_path
    assert_not edition.reload.access_limited?
    assert_empty edition.access_limiting_organisations
    assert_empty edition.access_limiting_individuals
  end

  view_test "PATCH :update re-renders the edit template with error and the submitted values, but does not persist the association, when access limiting individuals invalid" do
    feature_flags.switch! :access_limiting_individuals_ui, true

    edition = create(
      :consultation,
      access_limiting: :individuals,
      access_limiting_individual_emails: "user@example.com",
    )

    put :update,
        params: {
          id: edition,
          edition: {
            access_limiting: "individuals",
            access_limiting_individual_emails: "user@example.com, another_user@example.com, notanemail",
            editorial_remark: "Test",
          },
        }

    assert_template :edit
    assert_select ".govuk-error-summary a", text: "Access limiting individual emails must contain valid email addresses", href: "#access_limiting_individuals_emails"
    assert_select "textarea[name='edition[access_limiting_individual_emails]']", text: "user@example.com, another_user@example.com, notanemail"
    assert_select "textarea[name='edition[editorial_remark]']", text: "Test"

    assert edition.reload.access_limiting_individuals.exists?(email: "user@example.com")
    assert_not edition.access_limiting_individuals.exists?(email: "another_user@example.com")
  end

  # flags agnostic
  test "PATCH :update should enqueue the edition draft updater" do
    first_organisation = create(:organisation)
    second_organisation = create(:organisation)

    edition = create(
      :consultation,
      :access_limited_by_organisations,
      create_default_organisation: false,
      lead_organisations: [first_organisation],
    )

    draft_updater = mock("draft_updater")
    Whitehall.edition_services.expects(:draft_updater).with(edition).returns(draft_updater)
    draft_updater.expects(:can_perform?).returns(true)
    draft_updater.expects(:perform!).once

    patch :update,
          params: {
            id: edition,
            edition: {
              access_limiting: "organisations",
              access_limiting_organisation_ids: [first_organisation.id],
              lead_organisation_ids: [first_organisation.id, second_organisation.id],
              editorial_remark: "Updating lead organisations.",
            },
          }

    assert_equal [first_organisation, second_organisation], edition.reload.lead_organisations
  end

  # flags agnostic
  test "PATCH :update should enqueue the attachment updater" do
    first_organisation = create(:organisation)
    second_organisation = create(:organisation)

    edition = create(
      :consultation,
      :with_file_attachment,
      :access_limited_by_organisations,
      create_default_organisation: false,
      lead_organisations: [first_organisation],
    )

    AssetManager::AttachmentUpdater.expects(:call).with(edition.attachments.first.attachment_data)

    patch :update,
          params: {
            id: edition,
            edition: {
              access_limiting: "organisations",
              access_limiting_organisation_ids: [first_organisation.id],
              lead_organisation_ids: [first_organisation.id, second_organisation.id],
              editorial_remark: "Updating lead organisations.",
            },
          }

    assert_equal [first_organisation, second_organisation], edition.reload.lead_organisations

    AssetManagerAttachmentMetadataJob.drain
  end

  # flags agnostic
  test "PATCH :update does not change edition if in unmodifiable state" do
    edition = create(:published_consultation, create_default_organisation: true)

    patch :update,
          params: {
            id: edition,
            edition: {
              lead_organisation_ids: [create(:organisation).id],
              editorial_remark: "Updating lead organisations.",
            },
          }

    assert_template :edit
    assert_equal "A published edition may not be updated.", flash[:alert]
  end
end
