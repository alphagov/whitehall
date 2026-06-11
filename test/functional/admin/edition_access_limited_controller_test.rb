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

  view_test "GET :edit should display the correct fields" do
    organisation = create(:organisation)

    edition = create(
      :consultation,
      access_limiting: "organisations",
      access_limiting_organisation_ids: [organisation.id],
      create_default_organisation: false,
      lead_organisations: [organisation],
    )

    get :edit, params: { id: edition }

    assert_select "form[action='#{update_access_limited_admin_edition_path(edition.id)}']" do
      assert_select "input[name='edition[access_limiting]'][type=checkbox][value=organisations][checked=checked]"
      assert_select "textarea[name='edition[editorial_remark]']"

      (1..4).each do |i|
        assert_select "label[for=edition_lead_organisation_ids_#{i}]", text: "Lead organisation #{i}"
        assert_select("#edition_lead_organisation_ids_#{i}")
      end

      assert_select("#edition_lead_organisation_ids_1") do
        assert_select "option[selected='selected']", value: organisation.id
      end

      refute_select "#edition_lead_organisation_ids_5"
      assert_select("#edition_supporting_organisation_ids")
    end
  end

  view_test "GET :edit should show radio buttons instead of checkbox when access_limiting_organisations_ui flag is on" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    organisation = create(:organisation)
    edition = create(
      :consultation,
      access_limiting: :none,
      create_default_organisation: false,
      lead_organisations: [organisation],
    )

    get :edit, params: { id: edition }

    assert_select "input[name='edition[access_limiting]'][type=radio]"
    assert_select "input[name='edition[access_limited]'][type=checkbox]", count: 0
  end

  view_test "GET :edit should pre-select organisation_access_limiting radio and populate org select when access_limiting_organisations_ui flag is on" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    organisation = create(:organisation)
    edition = create(
      :consultation,
      access_limiting: :organisations,
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

  test "PATCH :update should be forbidden unless user is a GDS Admin" do
    edition = create(:consultation)
    login_as :gds_editor
    get :edit, params: { id: edition }
    assert_response :forbidden
  end

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

    put :update,
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

  test "PATCH :update allows access_limited to be updated and creates an editorial remark" do
    first_organisation = create(:organisation)
    second_organisation = create(:organisation)

    edition = create(
      :consultation,
      access_limiting: "organisations",
      create_default_organisation: false,
      lead_organisations: [first_organisation],
      supporting_organisations: [second_organisation],
      access_limiting_organisation_ids: [first_organisation.id],
    )

    editorial_remark = "Removing access limited at the users request."

    put :update,
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

  test "PATCH :update re-renders edit template if editorial remark is not provided" do
    first_organisation = create(:organisation)
    second_organisation = create(:organisation)

    edition = create(
      :consultation,
      access_limiting: "organisations",
      create_default_organisation: false,
      lead_organisations: [first_organisation],
      supporting_organisations: [second_organisation],
      access_limiting_organisation_ids: [first_organisation.id],
    )

    put :update,
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

  test "PATCH :update doesn't create an editorial remark or re-render with an error when nothing has changed" do
    first_organisation = create(:organisation)
    second_organisation = create(:organisation)

    edition = create(
      :consultation,
      access_limiting: "organisations",
      create_default_organisation: false,
      lead_organisations: [first_organisation],
      supporting_organisations: [second_organisation],
      access_limiting_organisation_ids: [first_organisation.id],
    )

    put :update,
        params: {
          id: edition,
          edition: {
            lead_organisation_ids: [first_organisation.id],
            supporting_organisation_ids: [second_organisation.id],
            editorial_remark: "",
            access_limiting: "organisations",
          },
        }

    assert_redirected_to admin_editions_path
    assert_equal "Access updated for #{edition.title}", flash[:notice]
    assert_equal 0, edition.editorial_remarks.count
  end

  test "PATCH :update remains access limited when flag is off and access_limiting_organisations were previously set" do
    organisation = create(:organisation)
    edition = create(
      :consultation,
      access_limiting: :organisations,
      create_default_organisation: false,
      lead_organisations: [organisation],
      access_limiting_organisation_ids: [organisation.id],
    )

    put :update,
        params: {
          id: edition,
          edition: {
            lead_organisation_ids: [organisation.id],
            access_limiting: "organisations",
            editorial_remark: "No change to access limiting",
          },
        }

    assert_redirected_to admin_editions_path
    assert edition.reload.access_limited?
    assert edition.access_limiting_organisations.exists?(id: organisation.id)
  end

  test "PATCH :update should save access_limiting_organisation_ids and set access_limited when access_limiting_organisations_ui flag is on" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    organisation = create(:organisation)
    edition = create(
      :consultation,
      access_limiting: :none,
      create_default_organisation: false,
      lead_organisations: [organisation],
    )

    put :update,
        params: {
          id: edition,
          edition: {
            lead_organisation_ids: [organisation.id],
            access_limiting: "organisations",
            access_limiting_organisation_ids: [organisation.id.to_s],
            editorial_remark: "Test",
          },
        }

    assert_redirected_to admin_editions_path
    assert edition.reload.access_limited?
    assert edition.access_limiting_organisations.exists?(id: organisation.id)
  end

  test "PATCH :update should render a validation error when access_limited is set without access_limiting_organisations and access_limiting_organisations_ui flag is on" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    organisation = create(:organisation)
    edition = create(
      :consultation,
      access_limiting: :none,
      create_default_organisation: false,
      lead_organisations: [organisation],
    )

    put :update,
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

  test "PATCH :update should render a validation error when access_limiting_organisations are cleared on an existing access-limited edition and access_limiting_organisations_ui flag is on" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    organisation = create(:organisation)
    edition = create(
      :consultation,
      access_limiting: :organisations,
      create_default_organisation: false,
      lead_organisations: [organisation],
      access_limiting_organisation_ids: [organisation.id],
    )

    put :update,
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
    assert edition.reload.access_limited?
    assert edition.access_limiting_organisations.exists?(id: organisation.id)
    assert_includes assigns(:edition).errors[:access_limiting_organisation_ids],
                    "must include at least one organisation when access limiting is enabled"
  end

  test "PATCH :update should clear access_limiting_organisations when access_limited is set to false and access_limiting_organisations_ui flag is on" do
    feature_flags.switch! :access_limiting_organisations_ui, true

    organisation = create(:organisation)
    edition = create(
      :consultation,
      access_limiting: :organisations,
      create_default_organisation: false,
      lead_organisations: [organisation],
      access_limiting_organisation_ids: [organisation.id],
    )

    put :update,
        params: {
          id: edition,
          edition: {
            lead_organisation_ids: [organisation.id],
            access_limiting: "none",
            access_limiting_organisation_ids: [],
            editorial_remark: "Removing access limiting",
          },
        }

    assert_redirected_to admin_editions_path
    assert_not edition.reload.access_limited?
    assert_empty edition.access_limiting_organisations
  end
end
