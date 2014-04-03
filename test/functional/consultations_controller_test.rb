require "test_helper"

class ConsultationsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_display_attachments_for :consultation
  should_display_localised_attachments
  should_display_inline_images_for :consultation
  should_show_inapplicable_nations :consultation
  should_set_meta_description_for :consultation
  should_set_slimmer_analytics_headers_for :consultation
  should_set_the_article_id_for_the_edition_for :consultation
  should_show_share_links_for :consultation

  test 'index redirects to the publications index filtering consultations, retaining any other filter params' do
    get :index, topics: ["a-topic-slug"], departments: ['an-org-slug']
    assert_redirected_to publications_path(publication_filter_option: Whitehall::PublicationFilterOption::Consultation.slug, topics: ["a-topic-slug"], departments: ['an-org-slug'])
  end

  test 'show displays published consultations' do
    published_consultation = create(:published_consultation)
    get :show, id: published_consultation.document
    assert_response :success
  end

  view_test 'show displays the summary of the published consultation response when there are response attachments' do
    closed_consultation = create(:published_consultation, opening_at: 2.days.ago, closing_at: 1.day.ago)
    response = create(:consultation_outcome, consultation: closed_consultation, attachments: [
      response_attachment = build(:file_attachment)
    ])

    get :show, id: closed_consultation.document

    assert_select '.consultation-response-summary article', text: response.summary
  end

  view_test 'show displays consultation dates when consultation has finished' do
    opening_at = Time.zone.local(2011, 8, 10, 8, 15)
    closing_at = Time.zone.local(2011, 11, 1, 19, 45)

    published_consultation = create(:published_consultation, opening_at: opening_at, closing_at: closing_at)
    get :show, id: published_consultation.document

    assert_select ".opening-at[title=#{opening_at.iso8601}]"
    assert_select ".closing-at[title=#{closing_at.iso8601}]"
  end

  view_test 'show displays consultation closing date on open consultation' do
    closing_at = Time.zone.now + 2.days
    published_consultation = create(:published_consultation, opening_at: DateTime.new(2010, 1, 1), closing_at: closing_at)
    get :show, id: published_consultation.document
    assert_select ".closing-at[title=#{closing_at.iso8601}]"
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
    published_consultation = create(:published_consultation, consultation_participation: consultation_participation, opening_at: 4.days.ago, closing_at: 2.days.ago)
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
