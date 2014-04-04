require "test_helper"

class Admin::CorporateInformationPagesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
    @organisation = create(:organisation)
  end

  should_be_an_admin_controller

  test "GET :index" do
    corporate_information_page = create(:corporate_information_page, organisation: @organisation)
    get :index, organisation_id: @organisation

    assert_response :success
    assert_template :index
    assert_equal @organisation, assigns(:organisation)
    assert_equal [corporate_information_page], assigns(:filter).editions
    assert assigns(:filter).page_title
    assert_equal false, assigns(:filter).show_stats
    assert assigns(:filter).hide_type
  end

  view_test "GET :new should display form" do
    get :new, organisation_id: @organisation

    assert_select "form[action='#{admin_organisation_corporate_information_pages_path(@organisation)}']" do
      assert_select "textarea[name='edition[body]']"
      assert_select "textarea[name='edition[summary]']"
      assert_select "select[name='edition[corporate_information_page_type_id]']"
      assert_select "input[type='submit']"
    end
  end

  test "POST :create can create a corporate information page for an Organisation" do
    post :create, organisation_id: @organisation, edition: corporate_information_page_attributes

    assert_redirected_to admin_organisation_corporate_information_pages_path(@organisation)

    assert page = @organisation.corporate_information_pages.last
    assert_equal "#{page.title} created successfully", flash[:notice]
    assert_equal corporate_information_page_attributes[:body], page.body
    assert_equal corporate_information_page_attributes[:corporate_information_page_type_id], page.corporate_information_page_type_id
    assert_equal corporate_information_page_attributes[:summary], page.summary
  end

  test "POST :create can create a corporation information page for a WorldwideOrganisation" do
    organisation = create(:worldwide_organisation)
    post :create, worldwide_organisation_id: organisation, edition: corporate_information_page_attributes

    assert_redirected_to admin_worldwide_organisation_corporate_information_pages_path(organisation)

    assert page = organisation.corporate_information_pages.last
    assert_equal "#{page.title} created successfully", flash[:notice]
    assert_equal corporate_information_page_attributes[:body], page.body
    assert_equal corporate_information_page_attributes[:corporate_information_page_type_id], page.corporate_information_page_type_id
    assert_equal corporate_information_page_attributes[:summary], page.summary
  end

  view_test "POST :create should redisplay form with error message on fail" do
    post :create, organisation_id: @organisation, edition: corporate_information_page_attributes(body: nil)
    @organisation.reload
    assert_select "form[action='#{admin_organisation_corporate_information_pages_path(@organisation)}']"
    assert_match /^There was a problem:/, flash[:alert]
  end

  view_test "GET :edit should display form without type selector for existing corporate information page" do
    corporate_information_page = create(:corporate_information_page, organisation: @organisation)
    get :edit, organisation_id: @organisation, id: corporate_information_page

    assert_select "form[action='#{admin_organisation_corporate_information_page_path(@organisation, corporate_information_page)}']" do
      assert_select "textarea[name='edition[body]']", corporate_information_page.body
      assert_select "textarea[name='edition[summary]']", corporate_information_page.summary
      assert_select "select[name='edition[corporate_information_page_type_id]']", count: 0
      assert_select "input[type='submit']"
    end
  end

  test "PUT :update should update an existing corporate information page and redirect on success" do
    corporate_information_page = create(:corporate_information_page, organisation: @organisation)
    new_attributes = {body: "New body", summary: "New summary"}
    put :update, organisation_id: @organisation, id: corporate_information_page, edition: new_attributes
    corporate_information_page.reload
    assert_equal new_attributes[:body], corporate_information_page.body
    assert_equal new_attributes[:summary], corporate_information_page.summary
    assert_equal "#{corporate_information_page.title} updated successfully", flash[:notice]
    assert_redirected_to admin_organisation_corporate_information_page_path(@organisation, corporate_information_page)
  end

  view_test "PUT :update should redisplay form on failure" do
    corporate_information_page = create(:corporate_information_page, organisation: @organisation)
    new_attributes = {body: "", summary: "New summary"}
    put :update, organisation_id: @organisation, id: corporate_information_page, edition: new_attributes
    assert_match /^There are some problems/, flash[:alert]

    assert_select "form[action='#{admin_organisation_corporate_information_page_path(@organisation, corporate_information_page)}']" do
      assert_select "textarea[name='edition[body]']", new_attributes[:body]
      assert_select "textarea[name='edition[summary]']", new_attributes[:summary]
      assert_select "select[name='edition[corporate_information_page_type_id]']", count: 0
      assert_select "input[type='submit']"
    end
  end

  test "PUT :delete should delete the page and redirect to the organisation" do
    corporate_information_page = create(:corporate_information_page, organisation: @organisation)
    put :destroy, organisation_id: @organisation, id: corporate_information_page
    assert_equal "#{corporate_information_page.title} deleted successfully", flash[:notice]
    assert_redirected_to admin_organisation_path(@organisation)
  end

private
  def corporate_information_page_attributes(overrides = {})
    {
      body: "This is the body",
      corporate_information_page_type_id: CorporateInformationPageType::TermsOfReference.id,
      summary: "This is the summary"
    }.merge(overrides)
  end
end
