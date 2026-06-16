require "test_helper"

class Admin::EditionAccessLimitedControllerTest < ActionController::TestCase
  setup do
    login_as :gds_admin
  end

  should_be_an_admin_controller

  # access_limiting_organisations_ui flag agnostic
  test "GET :edit should be forbidden unless user is a GDS Admin" do
    edition = create(:consultation)
    login_as :gds_editor
    get :edit, params: { id: edition }
    assert_response :forbidden
  end

  # access_limiting_organisations_ui flag is off
  view_test "GET :edit should display the correct fields" do
    organisation = create(:organisation)

    edition = create(
      :consultation,
      access_limiting: "organisations",
      create_default_organisation: false,
      lead_organisations: [organisation],
    )

    get :edit, params: { id: edition }

    assert_select "form[action='#{update_access_limited_admin_edition_path(edition.id)}']" do
      assert_select "input[name='edition[access_limiting]'][type=checkbox][value=organisations][checked=checked]"
      assert_select "textarea[name='edition[editorial_remark]']"

      (1..4).each do |i|
        select_label = i == 1 && assigns(:edition).lead_organisation_association_required? ? "Lead organisation #{i} (required)" : "Lead organisation #{i}"
        assert_select "label[for=edition_lead_organisation_ids_#{i}]", text: select_label
        assert_select("#edition_lead_organisation_ids_#{i}")
      end

      assert_select("#edition_lead_organisation_ids_1") do
        assert_select "option[selected='selected']", value: organisation.id
      end

      refute_select "#edition_lead_organisation_ids_5"
      assert_select("#edition_supporting_organisation_ids")
    end
  end

  # access_limiting_organisations_ui is on
  view_test "GET :edit should show radio buttons instead of checkbox when access_limiting_organisations_ui flag is on" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    organisation = create(:organisation)
    edition = create(
      :consultation,
      access_limiting: "none",
      create_default_organisation: false,
      lead_organisations: [organisation],
    )

    get :edit, params: { id: edition }

    assert_select "input[name='edition[access_limiting]'][type=radio]"
    assert_select "input[name='edition[access_limited]'][type=checkbox]", count: 0
  end

  # access_limiting_organisations_ui is on
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

  # Flag reversal scenario, access_limiting_organisations_ui turned on and then off
  view_test "GET :edit shows the persisted editions's access limiting value, and preserves already set access limiting organisations, when flag is turned off" do
    organisation = create(:organisation)
    edition = create(
      :consultation,
      access_limiting: "organisations",
      create_default_organisation: false,
      lead_organisations: [organisation],
      access_limiting_organisation_ids: [organisation.id],
    )

    get :edit, params: { id: edition }

    assert edition.access_limited?
    assert_equal "organisations", edition.access_limiting
    assert edition.access_limiting_organisations.exists?(id: organisation.id)
    assert_select "input[name='edition[access_limiting]'][value='organisations'][checked=checked]"
    refute_select "select[name='edition[access_limiting_organisation_ids][]']"
  end

  # access_limiting_organisations_ui flag agnostic
  test "PATCH :update should be forbidden unless user is a GDS Admin" do
    edition = create(:consultation)
    login_as :gds_editor
    patch :update, params: { id: edition }
    assert_response :forbidden
  end

  # access_limiting_organisations_ui flag agnostic
  test "PATCH :update should update editions organisations correctly and creates an editorial remark" do
    first_organisation = create(:organisation)
    second_organisation = create(:organisation)
    third_organisation = create(:organisation)

    edition = create(
      :consultation,
      access_limiting: "organisations",
      create_default_organisation: false,
      lead_organisations: [first_organisation],
      supporting_organisations: [second_organisation],
    )

    PublishingApiDocumentRepublishingJob.expects(:perform_async).with(edition.document_id, false)

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

  # access_limiting_organisations_ui flag is off
  test "PATCH :update allows access_limited to be updated and creates an editorial remark" do
    first_organisation = create(:organisation)
    second_organisation = create(:organisation)

    edition = create(
      :consultation,
      access_limiting: "organisations",
      create_default_organisation: false,
      lead_organisations: [first_organisation],
      supporting_organisations: [second_organisation],
    )

    editorial_remark = "Removing access limited at the users request."

    patch :update,
          params: {
            id: edition,
            edition: {
              lead_organisation_ids: [first_organisation.id],
              supporting_organisation_ids: [second_organisation.id],
              editorial_remark:,
              access_limiting: "none",
            },
          }

    assert_equal [first_organisation], edition.reload.lead_organisations
    assert_equal [second_organisation], edition.supporting_organisations
    assert_not edition.access_limited?
    assert_redirected_to admin_editions_path
    assert_equal "Access updated for #{edition.title}", flash[:notice]
    assert_equal "Access options updated by GDS Admin: #{editorial_remark}", edition.editorial_remarks.last.body
  end

  # access_limiting_organisations_ui is on
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

  # access_limiting_organisations_ui is on
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
              access_limiting_organisation_ids: [],
              editorial_remark: editorial_remark,
            },
          }

    assert_redirected_to admin_editions_path
    assert_equal "none", edition.reload.access_limiting
    assert_empty edition.access_limiting_organisations
    assert_equal "Access updated for #{edition.title}", flash[:notice]
    assert_equal "Access options updated by GDS Admin: #{editorial_remark}", edition.editorial_remarks.last.body
  end

  # access_limiting_organisations_ui flag is off
  test "PATCH :update re-renders edit template if editorial remark is not provided" do
    first_organisation = create(:organisation)
    second_organisation = create(:organisation)

    edition = create(
      :consultation,
      access_limiting: "organisations",
      create_default_organisation: false,
      lead_organisations: [first_organisation],
      supporting_organisations: [second_organisation],
    )

    patch :update,
          params: {
            id: edition,
            edition: {
              lead_organisation_ids: [first_organisation.id],
              supporting_organisation_ids: [second_organisation.id],
              editorial_remark: "",
              access_limiting: "none",
            },
          }

    assert_template :edit
    assert_equal ["Editorial remark cannot be blank"], assigns(:edition).errors.full_messages
    assert edition.reload.access_limited?
  end

  # access_limiting_organisations_ui is on
  test "PATCH :update re-renders edit template when editorial remark is not provided" do
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

  # access_limiting_organisations_ui is on
  test "PATCH :update renders a validation error when access_limiting is set to organisations, but no organisations provided" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    organisation = create(:organisation)
    edition = create(
      :consultation,
      access_limiting: "none",
      create_default_organisation: false,
      lead_organisations: [organisation],
    )

    patch :update,
          params: {
            id: edition,
            edition: {
              lead_organisation_ids: [organisation.id],
              access_limiting: "organisations",
              access_limiting_organisation_ids: [],
              editorial_remark: "Test",
            },
          }

    assert_template :edit
    assert_includes assigns(:edition).errors[:access_limiting_organisation_ids],
                    "must include at least one organisation when access limiting is enabled"
  end

  # access_limiting_organisations_ui is on
  # TODO - When future validation is added to the field, we also needs to cover the scenario where the field itself is invalid, but the submitted value is not empty.
  # It should re-render the edit template with the submitted access limiting organisations, and not change the database association value.
  test "PATCH :update does not clear access_limiting_organisations in DB when the access_limiting_organisations invalid" do
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
              access_limiting_organisation_ids: [],
              editorial_remark: "Test",
            },
          }

    assert_template :edit
    assert_includes assigns(:edition).errors[:access_limiting_organisation_ids], "must include at least one organisation when access limiting is enabled"
    assert_equal "organisations", edition.reload.access_limiting
    assert edition.access_limiting_organisations.exists?(id: organisation.id)
  end

  # access_limiting_organisations_ui is on
  # TODO - This is a characterisation test. The desired behaviour is that the access limiting organisations would not be persisted.
  view_test "PATCH :update re-renders the edit template with the submitted access limiting organisations and persists the association, when unrelated field fails validation" do
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
              lead_organisation_ids: [organisation.id],
              access_limiting: "organisations",
              access_limiting_organisation_ids: [organisation.id, new_organisation.id],
            },
          }

    assert_template :edit
    assert_equal ["Editorial remark cannot be blank"], assigns(:edition).errors.full_messages
    assert_select "input[name='edition[access_limiting]'][value='organisations'][checked=checked]"
    assert_select "select[name='edition[access_limiting_organisation_ids][]']" do
      assert_select "option[selected='selected'][value='#{organisation.id}']"
      assert_select "option[selected='selected'][value='#{new_organisation.id}']"
    end
    # Current behaviour
    assert_equal [organisation.id, new_organisation.id], edition.reload.access_limiting_organisation_ids
    # Desired behaviour
    # assert_equal [organisation.id], edition.reload.access_limiting_organisation_ids
  end
end
