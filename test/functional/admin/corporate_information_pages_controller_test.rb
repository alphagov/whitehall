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

  test "POST :create can create a corporate information page for an Organisation" do
    post :create, organisation_id: @organisation, corporate_information_page: corporate_information_page_attributes

    assert_redirected_to admin_organisation_path(@organisation)

    assert page = @organisation.corporate_information_pages.last
    assert_equal "#{page.title} created successfully", flash[:notice]
    assert_equal corporate_information_page_attributes[:body], page.body
    assert_equal corporate_information_page_attributes[:type_id], page.type_id
    assert_equal corporate_information_page_attributes[:summary], page.summary
  end

  test "POST :create can create a corporation information page for a WorldwideOrganisation" do
    organisation = create(:worldwide_organisation)
    post :create, worldwide_organisation_id: organisation, corporate_information_page: corporate_information_page_attributes

    assert_redirected_to admin_worldwide_organisation_path(organisation)

    assert page = organisation.corporate_information_pages.last
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

  test 'creating a corporate information page should attach file' do
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
    attributes = attributes_for(:corporate_information_page)
    attachment_attributes = attributes_for(:file_attachment).merge(
      attachment_data_attributes: { file: greenpaper_pdf })
    attributes[:attachments_attributes] = { "0" => attachment_attributes }

    post :create, organisation_id: @organisation.id, corporate_information_page: attributes

    info_page = assigns(:corporate_information_page)
    assert assigns(:corporate_information_page).errors.empty?
    assert_equal 1, info_page.attachments.length
    attachment = info_page.attachments.first
    assert_equal attachment_attributes[:title], attachment.title
    assert_equal "greenpaper.pdf", attachment.attachment_data.carrierwave_file
    assert_equal "application/pdf", attachment.content_type
    assert_equal greenpaper_pdf.size, attachment.file_size
  end

  test "creating a corporate information page with invalid data does not add an extra attachment and preserves the uploaded data" do
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf')

    invalid_attributes = attributes_for(
      :corporate_information_page,
      body: '',
      attachments_attributes: {
        "0" => attributes_for(:file_attachment).merge(
          title: 'my attachment',
          attachment_data_attributes: { file: greenpaper_pdf })
      })

    post :create, organisation_id: @organisation.id, corporate_information_page: invalid_attributes

    attachments = assigns(:corporate_information_page).attachments
    assert_equal 1, attachments.size
    attachment = attachments.first
    assert attachment.new_record?
    assert_equal 'my attachment', attachment.title
    assert_match /greenpaper.pdf$/, attachment.attachment_data.file_cache
  end

  view_test 'creating a corporate information page with invalid data should not show any existing attachment info' do
    invalid_attributes = attributes_for(:corporate_information_page, body: '')
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf')
    invalid_attributes[:attachments_attributes] = {
      "0" => attributes_for(:file_attachment).merge(attachment_data_attributes: {
          file: greenpaper_pdf
      })
    }

    post :create, organisation_id: @organisation.id, corporate_information_page: invalid_attributes

    refute_select "p.attachment"
  end

  test 'updating a corporate information page should attach file' do
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
    info_page = create(:corporate_information_page, :with_alternative_format_provider)

    put :update, id: info_page, organisation_id: info_page.organisation_id, corporate_information_page: attributes_for(:corporate_information_page,
      attachments_attributes: {
        "0" => attributes_for(:file_attachment, title: "attachment-title").merge(
                   attachment_data_attributes: { file: greenpaper_pdf })
      }
    )

    info_page.reload
    assert_equal 1, info_page.attachments.length
    attachment = info_page.attachments.first
    assert_equal "attachment-title", attachment.title
    assert_equal "greenpaper.pdf", attachment.attachment_data.carrierwave_file
    assert_equal "application/pdf", attachment.content_type
    assert_equal greenpaper_pdf.size, attachment.file_size
  end

  test 'updating a corporate information page should attach multiple files' do
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
    csv_file = fixture_file_upload('sample-from-excel.csv', 'text/csv')
    info_page = create(:corporate_information_page, :with_alternative_format_provider)

    put :update, id: info_page, organisation_id: info_page.organisation_id, corporate_information_page: attributes_for(:corporate_information_page,
      attachments_attributes: {
        "0" => attributes_for(:file_attachment, title: "attachment-1-title").merge(
                   attachment_data_attributes: { file: greenpaper_pdf }),
        "1" => attributes_for(:file_attachment, title: "attachment-2-title").merge(
                   attachment_data_attributes: { file: csv_file })
      }
    )

    info_page.reload
    assert_equal 2, info_page.attachments.length
    attachment_1 = info_page.attachments.first
    assert_equal "attachment-1-title", attachment_1.title
    assert_equal "greenpaper.pdf", attachment_1.attachment_data.carrierwave_file
    assert_equal "application/pdf", attachment_1.content_type
    assert_equal greenpaper_pdf.size, attachment_1.file_size
    attachment_2 = info_page.attachments.last
    assert_equal "attachment-2-title", attachment_2.title
    assert_equal "sample-from-excel.csv", attachment_2.attachment_data.carrierwave_file
    assert_equal "text/csv", attachment_2.content_type
    assert_equal csv_file.size, attachment_2.file_size
  end

  test "updating a corporate information page with invalid data does not add an unsaved attachment, and preserves the uploaded data" do
    info_page = create(:corporate_information_page)
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf')

    put :update, id: info_page, organisation_id: info_page.organisation_id, corporate_information_page: attributes_for(:corporate_information_page, body: '',
      attachments_attributes: {
        "0" => attributes_for(:file_attachment).merge(
            title: 'my attachment',
            attachment_data_attributes: { file: greenpaper_pdf }
          )
      })

    attachments = assigns(:corporate_information_page).attachments
    assert_equal 1, attachments.size
    attachment = attachments.first
    assert attachment.new_record?
    assert_equal 'my attachment', attachment.title
    assert_match /greenpaper.pdf$/, attachment.attachment_data.file_cache
  end

  test 'updating should allow removal of attachments' do
    info_page = create(:corporate_information_page, :with_alternative_format_provider)
    attachment_1 = create(:file_attachment, attachable: info_page)
    attachment_2 = create(:file_attachment, attachable: info_page)

    info_page_params = attributes_for(:corporate_information_page,
      attachments_attributes: {
        "0" => { id: attachment_1.id.to_s, _destroy: "1" },
        "1" => { id: attachment_2.id.to_s, _destroy: "0" },
        "2" => { attachment_data_attributes: { file_cache: "" } }
      }
    )
    put :update, id: info_page, organisation_id: info_page.organisation_id, corporate_information_page: info_page_params

    assert assigns(:corporate_information_page).errors.empty?
    info_page.reload
    assert_equal [attachment_2], info_page.attachments
  end
private

  def corporate_information_page_attributes(overrides = {})
    {
      body: "This is the body",
      type_id: CorporateInformationPageType::TermsOfReference.id,
      summary: "This is the summary"
    }.merge(overrides)
  end
end
