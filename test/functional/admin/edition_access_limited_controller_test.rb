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
      access_limited: :organisations,
      create_default_organisation: false,
      lead_organisations: [organisation],
    )

    get :edit, params: { id: edition }

    assert_select "form[action='#{update_access_limited_admin_edition_path(edition.id)}']" do
      assert_select "input[name='edition[access_limited]'][type=radio][value='organisations'][checked=checked]"
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
      access_limited: :organisations,
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
            access_limited: :organisations,
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
      access_limited: :organisations,
      create_default_organisation: false,
      lead_organisations: [first_organisation],
      supporting_organisations: [second_organisation],
    )

    editorial_remark = "Removing access limited at the users request."

    put :update,
        params: {
          id: edition,
          edition: {
            lead_organisation_ids: [first_organisation.id],
            supporting_organisation_ids: [second_organisation.id],
            editorial_remark:,
            access_limited: :disabled,
          },
        }

    assert_equal [first_organisation], edition.reload.lead_organisations
    assert_equal [second_organisation], edition.supporting_organisations
    assert_not edition.reload.access_limited?
    assert_redirected_to admin_editions_path
    assert_equal "Access updated for #{edition.title}", flash[:notice]
    assert_equal "Access options updated by GDS Admin: #{editorial_remark}", edition.editorial_remarks.last.body
  end

  test "PATCH :update re-renders edit template if editorial remark is not provided" do
    first_organisation = create(:organisation)
    second_organisation = create(:organisation)

    edition = create(
      :consultation,
      access_limited: :organisations,
      create_default_organisation: false,
      lead_organisations: [first_organisation],
      supporting_organisations: [second_organisation],
    )

    put :update,
        params: {
          id: edition,
          edition: {
            lead_organisation_ids: [first_organisation.id],
            supporting_organisation_ids: [second_organisation.id],
            editorial_remark: "",
            access_limited: :disabled,
          },
        }

    assert_template :edit
    assert_equal ["Editorial remark cannot be blank"], assigns(:edition).errors.full_messages
    assert edition.reload.access_limited?
  end

  test "PATCH :update updates named_users access and creates an editorial remark" do
    edition = create(
      :consultation,
      access_limited: :disabled,
    )

    editorial_remark = "Limiting to named users."

    put :update,
        params: {
          id: edition,
          edition: {
            access_limited: :named_users,
            access_limited_named_users: "named@example.com",
            editorial_remark:,
          },
        }

    assert edition.reload.named_users?
    assert_includes edition.named_accesses.pluck(:email), "named@example.com"
    assert_redirected_to admin_editions_path
    assert_equal "Access updated for #{edition.title}", flash[:notice]
    assert_equal "Access options updated by GDS Admin: #{editorial_remark}", edition.editorial_remarks.last.body
  end

  test "PATCH :update doesn't create an editorial remark or re-render with an error when nothing has changed" do
    first_organisation = create(:organisation)
    second_organisation = create(:organisation)

    edition = create(
      :consultation,
      access_limited: :organisations,
      create_default_organisation: false,
      lead_organisations: [first_organisation],
      supporting_organisations: [second_organisation],
    )

    put :update,
        params: {
          id: edition,
          edition: {
            lead_organisation_ids: [first_organisation.id],
            supporting_organisation_ids: [second_organisation.id],
            editorial_remark: "",
            access_limited: :organisations,
          },
        }

    assert_redirected_to admin_editions_path
    assert_equal "Access updated for #{edition.title}", flash[:notice]
    assert_equal 0, edition.editorial_remarks.count
  end
end
