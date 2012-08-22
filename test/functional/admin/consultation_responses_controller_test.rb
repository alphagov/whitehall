require 'test_helper'

class Admin::ConsultationResponsesControllerTest < ActionController::TestCase
  setup do
    @user = login_as :policy_writer
    @consultation = create(:published_consultation)
  end

  should_be_an_admin_controller
  should_allow_attachments_for :consultation_response
  should_allow_alternative_format_provider_for :consultation_response

  test 'new displays consultation response form' do
    get :new, edition: {consultation_id: @consultation}

    assert_select "form[action='#{admin_consultation_responses_path}']" do
      assert_select "input[name='edition[title]'][type='text']"
      assert_select "textarea[name='edition[body]']"
      assert_select "input[type='submit']"
    end
  end

  test 'create creates response to given consultation' do
    attributes = attributes_for(:consultation_response).merge(consultation_id: @consultation.id)

    post :create, consultation_id: @consultation, edition: attributes

    consultation_response = ConsultationResponse.last
    assert_equal attributes[:title], consultation_response.title
    assert_equal attributes[:body], consultation_response.body
    assert_equal @consultation, consultation_response.consultation
  end

  test 'show displays existing consultation response' do
    consultation_response = create(:consultation_response, consultation: @consultation)
    get :show, id: consultation_response

    assert_select ".title", consultation_response.title
    assert_select ".body", consultation_response.body
  end

  test 'show links back to consultation' do
    consultation_response = create(:consultation_response, consultation: @consultation)
    get :show, id: consultation_response
    assert_select "a[href='#{admin_consultation_path(@consultation)}']", text: @consultation.title
  end

  test 'show displays link to public view of published consultation response' do
    consultation_response = create(:published_consultation_response, consultation: @consultation)
    get :show, id: consultation_response
    assert_select "a[href='#{consultation_response_url(@consultation.document)}']"
  end

  def controller_attributes_for(edition_type, attributes = {})
    super(edition_type, attributes.merge(consultation_id: @consultation.id))
  end
end
