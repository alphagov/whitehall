require "test_helper"

class ConsultationsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_display_attachments_for :consultation
  should_display_inline_images_for :consultation
  should_show_inapplicable_nations :consultation
  should_set_meta_description_for :consultation

  test 'index redirects to the publications index filtering consultations' do
    get :index
    assert_redirected_to publications_path(publication_type: PublicationType::Consultation.plural_name.downcase)
  end

  test 'show displays published consultations' do
    published_consultation = create(:published_consultation)
    get :show, id: published_consultation.document
    assert_response :success
  end

  view_test 'show displays the summary of the published consultation response when there are response attachments' do
    closed_consultation = create(:published_consultation, opening_on: 2.days.ago, closing_on: 1.day.ago)
    response_attachment = create(:attachment)
    response = create(:consultation_outcome, consultation: closed_consultation)
    response.attachments << response_attachment

    get :show, id: closed_consultation.document

    assert_select '.consultation-response-summary article', text: response.summary
  end

  view_test 'show displays consultation dates when consultation has finished' do
    published_consultation = create(:published_consultation, opening_on: Date.new(2011, 8, 10), closing_on: Date.new(2011, 11, 1))
    get :show, id: published_consultation.document
    assert_select ".opening-on[title=#{Date.new(2011,8,10).iso8601}]"
    assert_select ".closing-on[title=#{Date.new(2011,11,1).iso8601}]"
  end

  view_test 'show displays consultation closing date on open consultation' do
    published_consultation = create(:published_consultation, opening_on: Date.new(2010, 1, 1), closing_on: 2.days.from_now)
    get :show, id: published_consultation.document
    assert_select ".closing-on[title=#{2.days.from_now.to_date.iso8601}]"
  end

  view_test "should not explicitly say that consultation applies to the whole of the UK" do
    published_consultation = create(:published_consultation)

    get :show, id: published_consultation.document

    refute_select inapplicable_nations_selector
  end

  view_test 'show displays consultation participation link and email' do
    consultation_participation = create(:consultation_participation,
      link_url: "http://telluswhatyouthink.com",
      email: "contact@example.com"
    )
    published_consultation = create(:published_consultation, consultation_participation: consultation_participation)
    get :show, id: published_consultation.document
    assert_select ".participation" do
      assert_select ".online a[href=?]", "http://telluswhatyouthink.com", text: "Respond online"
      assert_select ".email a[href=?]", "mailto:contact@example.com", text: "contact@example.com"
    end
  end

  view_test 'show does not display consultation participation link if none available' do
    consultation_participation = create(:consultation_participation, email: "contact@example.com")
    published_consultation = create(:published_consultation, consultation_participation: consultation_participation)
    get :show, id: published_consultation.document
    refute_select ".participation .online"
  end

  view_test 'show does not display consultation participation email if none available' do
    consultation_participation = create(:consultation_participation,
      link_url: "http://telluswhatyouthink.com"
    )
    published_consultation = create(:published_consultation, consultation_participation: consultation_participation)
    get :show, id: published_consultation.document
    refute_select ".participation .email"
  end

  view_test 'show does not display consultation participation link if consultation finished' do
    consultation_participation = create(:consultation_participation,
      email: "contact@example.com",
      link_url: "http://telluswhatyouthink.com"
    )
    published_consultation = create(:published_consultation, consultation_participation: consultation_participation, opening_on: 4.days.ago, closing_on: 2.days.ago)
    get :show, id: published_consultation.document
    refute_select ".participation .online"
    refute_select ".participation .email"
  end

  view_test 'show displays the postal address for participation' do
    address = %q{123 Example Street
London N123}
    consultation_participation = create(:consultation_participation,
                                        postal_address: address
                                        )
    published_consultation = create(:published_consultation, consultation_participation: consultation_participation)
    get :show, id: published_consultation.document

    assert_select ".participation" do
      assert_select ".postal-address", html: "123 Example Street<br />London N123"
    end
  end
end
