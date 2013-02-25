require "test_helper"

class Admin::CorporateInformationPagesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
    @organisation = create(:organisation)
  end

  should_be_an_admin_controller
  should_allow_attachments_for :corporate_information_page

  def process(action, parameters, session, flash, method)
    parameters ||= {}
    if !parameters.has_key?(:organisation_id)
      organisation = if parameters[:id]
        parameters[:id].organisation
      else
        create(:organisation_with_alternative_format_contact_email)
      end
      parameters = parameters.merge(organisation_id: organisation, organisation_type: organisation.class.to_s)
    end
    super(action, parameters, session, flash, method)
  end

  def make_invalid(controller_attributes)
    controller_attributes.merge(body: "")
  end

  def controller_attributes_for(edition_type, attributes = {})
    attributes_for(edition_type, attributes)
  end

  def create_draft(edition_type)
    create(edition_type)
  end

  test "GET :index" do
    corporate_information_page = create(:corporate_information_page, organisation: @organisation)
    get :index, organisation_id: @organisation.to_param

    assert_response :success
    assert_template :index
    assert_equal @organisation, assigns(:organisation)
    assert_equal [corporate_information_page], assigns(:corporate_information_pages)
  end

  view_test "GET :new should display form" do
    get :new, organisation_id: @organisation

    assert_select "form[action='#{admin_organisation_corporate_information_pages_path(@organisation)}']" do
      assert_select "textarea[name='corporate_information_page[body]']"
      assert_select "textarea[name='corporate_information_page[summary]']"
      assert_select "select[name='corporate_information_page[type_id]']"
      assert_select "input[type='submit']"
    end
  end

  test "POST :create for an Organisation corporate page" do
    post :create, organisation_id: @organisation, corporate_information_page: corporate_information_page_attributes

    assert_redirected_to admin_organisation_path(@organisation)
    assert_equal 1, @organisation.reload.corporate_information_pages.count

    page = @organisation.corporate_information_pages.last

    assert_equal "#{page.title} created successfully", flash[:notice]
    assert_equal corporate_information_page_attributes[:body], page.body
    assert_equal corporate_information_page_attributes[:type_id], page.type_id
    assert_equal corporate_information_page_attributes[:summary], page.summary
  end

  test "POST :create for WorldwideOrganisation corporation page" do
    organisation = create(:worldwide_organisation)
    post :create, worldwide_organisation_id: organisation, corporate_information_page: corporate_information_page_attributes

    assert_redirected_to admin_worldwide_organisation_path(organisation)
    assert_equal 1, organisation.reload.corporate_information_pages.count

    page = organisation.corporate_information_pages.last

    assert_equal "#{page.title} created successfully", flash[:notice]
    assert_equal corporate_information_page_attributes[:body], page.body
    assert_equal corporate_information_page_attributes[:type_id], page.type_id
    assert_equal corporate_information_page_attributes[:summary], page.summary
  end

  view_test "POST :create should redisplay form with error message on fail" do
    post :create, organisation_id: @organisation, corporate_information_page: corporate_information_page_attributes(body: nil)
    @organisation.reload
    assert_select "form[action='#{admin_organisation_corporate_information_pages_path(@organisation)}']"
    assert_match /^There was a problem:/, flash[:alert]
  end

  view_test "GET :edit should display form without type selector for existing corporate information page" do
    corporate_information_page = create(:corporate_information_page, organisation: @organisation)
    get :edit, organisation_id: @organisation, id: corporate_information_page

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
    put :update, organisation_id: @organisation, id: corporate_information_page, corporate_information_page: new_attributes
    corporate_information_page.reload
    assert_equal new_attributes[:body], corporate_information_page.body
    assert_equal new_attributes[:summary], corporate_information_page.summary
    assert_equal "#{corporate_information_page.title} updated successfully", flash[:notice]
    assert_redirected_to admin_organisation_path(@organisation)
  end

  view_test "PUT :update should redisplay form on failure" do
    corporate_information_page = create(:corporate_information_page, organisation: @organisation)
    new_attributes = {body: "", summary: "New summary"}
    put :update, organisation_id: @organisation, id: corporate_information_page, corporate_information_page: new_attributes
    assert_match /^There was a problem:/, flash[:alert]

    assert_select "form[action='#{admin_organisation_corporate_information_page_path(@organisation, corporate_information_page)}']" do
      assert_select "textarea[name='corporate_information_page[body]']", new_attributes[:body]
      assert_select "textarea[name='corporate_information_page[summary]']", new_attributes[:summary]
      assert_select "select[name='corporate_information_page[type_id]']", count: 0
      assert_select "input[type='submit']"
    end
  end

  test "PUT :delete should delete the page and redirect to the organisation" do
    corporate_information_page = create(:corporate_information_page, organisation: @organisation)
    put :destroy, organisation_id: @organisation, id: corporate_information_page
    assert_equal "#{corporate_information_page.title} deleted successfully", flash[:notice]
    assert_redirected_to admin_organisation_path(@organisation)
  end

  def corporate_information_page_attributes(overrides = {})
    {
      body: "This is the body",
      type_id: CorporateInformationPageType::TermsOfReference.id,
      summary: "This is the summary"
    }.merge(overrides)
  end
end
