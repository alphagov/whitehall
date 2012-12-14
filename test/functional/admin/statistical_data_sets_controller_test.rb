require 'test_helper'

class Admin::StatisticalDataSetsControllerTest < ActionController::TestCase
  setup do
    StatisticalDataSet.stubs(access_limited_by_default?: false)
    login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_showing_of :statistical_data_set
  should_allow_creating_of :statistical_data_set
  should_allow_editing_of :statistical_data_set
  should_allow_revision_of :statistical_data_set

  should_show_document_audit_trail_for :statistical_data_set, :show
  should_show_document_audit_trail_for :statistical_data_set, :edit

  should_allow_organisations_for :statistical_data_set
  should_allow_attachments_for :statistical_data_set
  should_require_alternative_format_provider_for :statistical_data_set
  show_should_display_attachments_for :statistical_data_set
  should_allow_attachment_references_for :statistical_data_set
  should_show_inline_attachment_help_for :statistical_data_set
  should_be_rejectable :statistical_data_set
  should_be_publishable :statistical_data_set
  should_allow_unpublishing_for :statistical_data_set
  should_be_force_publishable :statistical_data_set
  should_be_able_to_delete_an_edition :statistical_data_set
  should_link_to_public_version_when_published :statistical_data_set
  should_not_link_to_public_version_when_not_published :statistical_data_set
  should_link_to_preview_version_when_not_published :statistical_data_set
  should_prevent_modification_of_unmodifiable :statistical_data_set
  should_allow_alternative_format_provider_for :statistical_data_set
  should_allow_assignment_to_document_series :statistical_data_set
  should_allow_scheduled_publication_of :statistical_data_set

  test "new shows checked limited access checkbox by default" do
    StatisticalDataSet.stubs(access_limited_by_default?: true)
    get :new

    assert_select "form#edition_new" do
      assert_select "input[name='edition[access_limited]'][type=checkbox][value=1][checked=checked]"
    end
  end

  test "create limits access if limited access checkbox is checked" do
    StatisticalDataSet.stubs(access_limited_by_default?: true)
    post :create, edition: controller_attributes_for(:statistical_data_set, access_limited: true)

    assert created_data_set = StatisticalDataSet.last
    assert created_data_set.access_limited?
  end

  test "create limits access if limited access checkbox is not checked" do
    StatisticalDataSet.stubs(access_limited_by_default?: true)
    post :create, edition: controller_attributes_for(:statistical_data_set, access_limited: false)

    assert created_data_set = StatisticalDataSet.last
    refute created_data_set.access_limited?
  end

  test "create shows checked limited access checkbox if checkbox was checked and validation fails" do
    StatisticalDataSet.stubs(access_limited_by_default?: true)
    post :create, edition: controller_attributes_for(:statistical_data_set, title: nil, access_limited: true)

    assert_select "form#edition_new" do
      assert_select "input[name='edition[access_limited]'][type=checkbox][value=1][checked=checked]"
    end
  end

  test "create shows unchecked limited access checkbox if checkbox was unchecked and validation fails" do
    StatisticalDataSet.stubs(access_limited_by_default?: true)
    post :create, edition: controller_attributes_for(:statistical_data_set, title: nil, access_limited: false)

    assert_select "form#edition_new" do
      assert_select "input[name='edition[access_limited]'][type=checkbox][value=1]"
      refute_select "input[name='edition[access_limited]'][type=checkbox][value=1][checked=checked]"
    end
  end

  test "edit shows checked limited access checkbox if data set has limited access" do
    StatisticalDataSet.stubs(access_limited_by_default?: true)
    data_set = create(:statistical_data_set, access_limited: true, authors: [@current_user])

    get :edit, id: data_set

    assert_select "form#edition_edit" do
      assert_select "input[name='edition[access_limited]'][type=checkbox][value=1][checked=checked]"
    end
  end

  test "edit shows unchecked limited access checkbox if data set does not have limited access" do
    StatisticalDataSet.stubs(access_limited_by_default?: true)
    data_set = create(:statistical_data_set, access_limited: false)

    get :edit, id: data_set

    assert_select "form#edition_edit" do
      refute_select "input[name='edition[access_limited]'][type=checkbox][value=1][checked=checked]"
    end
  end

  test "update should limit access if limited access checkbox is checked" do
    StatisticalDataSet.stubs(access_limited_by_default?: true)
    data_set = create(:statistical_data_set, access_limited: false)

    put :update, id: data_set, edition: controller_attributes_for_instance(data_set,
      access_limited: true
    )

    assert created_data_set = StatisticalDataSet.last
    assert created_data_set.access_limited?
  end

  test "update should not limit access if limited access checkbox is not checked" do
    StatisticalDataSet.stubs(access_limited_by_default?: true)
    data_set = create(:statistical_data_set, access_limited: true, authors: [@current_user])

    put :update, id: data_set, edition: controller_attributes_for_instance(data_set,
      access_limited: false
    )

    assert created_data_set = StatisticalDataSet.last
    refute created_data_set.access_limited?
  end

  test "update shows checked limited access checkbox if checkbox was checked and validation fails" do
    StatisticalDataSet.stubs(access_limited_by_default?: true)
    data_set = create(:statistical_data_set, access_limited: false)

    put :update, id: data_set, edition: controller_attributes_for(:statistical_data_set,
      title: nil,
      access_limited: true
    )

    assert_select "form#edition_edit" do
      assert_select "input[name='edition[access_limited]'][type=checkbox][value=1][checked=checked]"
    end
  end

  test "update shows unchecked limited access checkbox if checkbox was unchecked and validation fails" do
    StatisticalDataSet.stubs(access_limited_by_default?: true)
    data_set = create(:statistical_data_set, access_limited: true, authors: [@current_user])

    put :update, id: data_set, edition: controller_attributes_for(:statistical_data_set,
      title: nil,
      access_limited: false
    )

    assert_select "form#edition_edit" do
      assert_select "input[name='edition[access_limited]'][type=checkbox][value=1]"
      refute_select "input[name='edition[access_limited]'][type=checkbox][value=1][checked=checked]"
    end
  end

  private

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:alternative_format_provider).reverse_merge(
      alternative_format_provider_id: create(:alternative_format_provider).id
    )
  end
end
