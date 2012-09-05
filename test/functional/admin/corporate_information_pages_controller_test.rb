require "test_helper"

class Admin::CorporateInformationPagesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
    @organisation = create(:organisation)
  end

  should_be_an_admin_controller

  test "GET :new should display form" do
    get :new, organisation_id: @organisation.id

    assert_select "form[action='#{admin_organisation_corporate_information_pages_path(@organisation)}']" do
      assert_select "textarea[name='corporate_information_page[body]']"
      assert_select "textarea[name='corporate_information_page[summary]']"
      assert_select "select[name='corporate_information_page[type_id]']"
      assert_select "input[type='submit']"
    end
  end

  test "POST :create should create a new corporate information page" do
    post :create, organisation_id: @organisation.id, corporate_information_page: corporate_information_page_attributes
    @organisation.reload

    assert_equal 1, @organisation.corporate_information_pages.count
    assert_equal corporate_information_page_attributes[:body], @organisation.corporate_information_pages.first.body
    assert_equal corporate_information_page_attributes[:type_id], @organisation.corporate_information_pages.first.type_id
    assert_equal corporate_information_page_attributes[:summary], @organisation.corporate_information_pages.first.summary
  end

  test "POST :create should redirect to organisation with flash on success" do
    post :create, organisation_id: @organisation.id, corporate_information_page: corporate_information_page_attributes
    @organisation.reload
    assert_redirected_to admin_organisation_path(@organisation)
    assert_equal "Corporate information page created successfully", flash[:notice]
  end

  test "POST :create should redisplay form with error message on fail" do
    post :create, organisation_id: @organisation.id, corporate_information_page: corporate_information_page_attributes(body: nil)
    @organisation.reload
    assert_select "form[action='#{admin_organisation_corporate_information_pages_path(@organisation)}']"
    assert_match /^There was a problem:/, flash[:alert]
  end

  test "GET :edit should display form without type selector for existing corporate information page" do
    corporate_information_page = create(:corporate_information_page, organisation: @organisation)
    get :edit, organisation_id: @organisation.id, id: corporate_information_page.id

    assert_select "form[action='#{admin_organisation_corporate_information_page_path(@organisation, corporate_information_page)}']" do
      assert_select "textarea[name='corporate_information_page[body]']", corporate_information_page.body
      assert_select "textarea[name='corporate_information_page[summary]']", corporate_information_page.summary
      assert_select "select[name='corporate_information_page[type_id]']", count: 0
      assert_select "input[type='submit']"
    end
  end

  test "PUT :update should update an existing corporate information page and redirect to the organisation on success" do
    corporate_information_page = create(:corporate_information_page, organisation: @organisation)
    new_attributes = {body: "New body", summary: "New summary"}
    put :update, organisation_id: @organisation.id, id: corporate_information_page.id, corporate_information_page: new_attributes
    corporate_information_page.reload
    assert_equal new_attributes[:body], corporate_information_page.body
    assert_equal new_attributes[:summary], corporate_information_page.summary
    assert_equal "Corporate information page updated successfully", flash[:notice]
    assert_redirected_to admin_organisation_path(@organisation)
  end

  test "PUT :update should redisplay form on failure" do
    corporate_information_page = create(:corporate_information_page, organisation: @organisation)
    new_attributes = {body: "", summary: "New summary"}
    put :update, organisation_id: @organisation.id, id: corporate_information_page.id, corporate_information_page: new_attributes
    assert_match /^There was a problem:/, flash[:alert]

    assert_select "form[action='#{admin_organisation_corporate_information_page_path(@organisation, corporate_information_page)}']" do
      assert_select "textarea[name='corporate_information_page[body]']", new_attributes[:body]
      assert_select "textarea[name='corporate_information_page[summary]']", new_attributes[:summary]
      assert_select "select[name='corporate_information_page[type_id]']", count: 0
      assert_select "input[type='submit']"
    end
  end

  # test "if creation fails then error message shown" do
  #   post :create, organisation_id: @organisation.id, corporate_information_page: {}

  #   assert_equal '', flash[:notice]
  # end

  def corporate_information_page_attributes(overrides = {})
    {
      body: "This is the body",
      type_id: CorporateInformationPageType::TermsOfReference.id,
      summary: "This is the summary"
    }.merge(overrides)
  end

end