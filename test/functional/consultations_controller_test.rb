require "test_helper"

class ConsultationsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_display_attachments_for :consultation
  should_display_inline_images_for :consultation
  should_not_display_lead_image_for :consultation
  should_show_change_notes :consultation
  should_show_inapplicable_nations :consultation

  test "should avoid n+1 queries" do
    10.times { create(:published_consultation, featured: true) }
    assert 10 > count_queries { get :index }
  end

  test 'index lists all published consultations' do
    published_open_consultation = create(:published_consultation, opening_on: 1.day.ago, closing_on: 1.day.from_now)
    published_closed_consultation = create(:published_consultation, opening_on: 2.days.ago, closing_on: 1.day.ago)
    published_upcoming_consultation = create(:published_consultation, opening_on: 1.day.from_now, closing_on: 2.days.from_now)
    index_consultation = create(:consultation, opening_on: 1.day.from_now, closing_on: 2.days.from_now)
    get :index

    assert_select '#index-consultations' do
      assert_select_object published_upcoming_consultation
      assert_select_object published_open_consultation
      assert_select_object published_closed_consultation
      refute_select_object index_consultation
    end
  end

  test 'index lists consultations with most recent significant change first' do
    consultation_1 = create(:published_consultation, first_published_at: 7.days.ago, opening_on: 6.days.ago, closing_on: 5.days.ago)
    create(:published_consultation_response, consultation: consultation_1, first_published_at: 4.days.ago)
    consultation_2 = create(:published_consultation, first_published_at: 5.days.ago, opening_on: 4.days.ago, closing_on: 3.days.ago)
    consultation_3 = create(:published_consultation, first_published_at: 3.days.ago, opening_on: 2.days.ago, closing_on: 1.day.from_now)
    consultation_4 = create(:published_consultation, first_published_at: 1.day.ago, opening_on: 1.day.from_now, closing_on: 2.days.from_now)

    get :index

    assert_equal [consultation_4, consultation_3, consultation_2, consultation_1], assigns(:consultations)
  end

  test 'index lists consultations with most recently published first if most recent significant change is same' do
    consultation_1 = create(:published_consultation, first_published_at: 1.day.ago, opening_on: 1.day.from_now, closing_on: 2.days.from_now)
    consultation_2 = create(:published_consultation, first_published_at: 2.days.ago, opening_on: 1.day.ago, closing_on: 1.day.from_now)
    consultation_3 = create(:published_consultation, first_published_at: 3.days.ago, opening_on: 2.days.ago, closing_on: 1.day.ago)
    consultation_4 = create(:published_consultation, first_published_at: 4.days.ago, opening_on: 3.days.ago, closing_on: 2.day.ago)
    create(:published_consultation_response, consultation: consultation_4, first_published_at: 1.day.ago)

    get :index

    assert_equal [consultation_1, consultation_2, consultation_3, consultation_4], assigns(:consultations)
  end

  test 'index shows no list if no published consultations exist' do
    get :index

    refute_select '#index-consultations .consultation'
    assert_select '#index-consultations p.no-content'
  end

  test "index shows the summary for each consultation" do
    consultation = create(:published_consultation, summary: 'a-simple-summary')

    get :index

    assert_select_object consultation do
      assert_select ".summary", text: "a-simple-summary"
    end
  end

  test "should indicate that the list of consultations is limited to only those that are open" do
    get :open
    assert_select "h1", text: "Open consultations"
  end

  test 'open lists published open consultations' do
    published_open_consultation = create(:published_consultation, opening_on: 1.day.ago, closing_on: 1.day.from_now)
    published_closed_consultation = create(:published_consultation, opening_on: 2.days.ago, closing_on: 1.day.ago)
    published_index_consultation = create(:published_consultation, opening_on: 1.day.from_now, closing_on: 2.days.from_now)
    open_consultation = create(:consultation, opening_on: 1.day.ago, closing_on: 1.day.from_now)
    get :open

    assert_select '#open-consultations' do
      assert_select_object published_open_consultation
      refute_select_object published_closed_consultation
      refute_select_object published_index_consultation
      refute_select_object open_consultation
    end
  end

  test 'open lists consultations with most recently opened first' do
    less_recently_opened = create(:published_consultation, opening_on: 2.days.ago, closing_on: 1.day.from_now)
    more_recently_opened = create(:published_consultation, opening_on: 1.days.ago, closing_on: 2.days.from_now)

    get :open

    assert_equal [more_recently_opened, less_recently_opened], assigns(:consultations)
  end

  test 'open lists consultations with most recently published first if opened on same date' do
    less_recently_published = create(:published_consultation, first_published_at: 2.days.ago, opening_on: 1.day.ago, closing_on: 1.day.from_now)
    more_recently_published = create(:published_consultation, first_published_at: 1.day.ago, opening_on: 1.day.ago, closing_on: 1.day.from_now)

    get :open

    assert_equal [more_recently_published, less_recently_published], assigns(:consultations)
  end

  test 'open shows no list if no open consultations exist' do
    get :open

    refute_select '#open-consultations .consultation'
    assert_select '#open-consultations p.no-content'
  end

  test "should indicate that the list of consultations is limited to only those that are closed" do
    get :closed
    assert_select 'h1', text: "Closed consultations"
  end

  test 'closed lists published closed consultations' do
    published_open_consultation = create(:published_consultation, opening_on: 1.day.ago, closing_on: 1.day.from_now)
    published_closed_consultation = create(:published_consultation, opening_on: 2.days.ago, closing_on: 1.day.ago)
    published_index_consultation = create(:published_consultation, opening_on: 1.day.from_now, closing_on: 2.days.from_now)
    closed_consultation = create(:consultation, opening_on: 2.days.ago, closing_on: 1.day.ago)
    get :closed

    assert_select '#closed-consultations' do
      assert_select_object published_closed_consultation
      refute_select_object published_open_consultation
      refute_select_object published_index_consultation
      refute_select_object closed_consultation
    end
  end

  test 'closed lists most recently closed consultations first' do
    opening_on = 3.days.ago
    less_recently_closed_consultation = create(:published_consultation, opening_on: opening_on, closing_on: 2.days.ago)
    more_recently_closed_consultation = create(:published_consultation, opening_on: opening_on, closing_on: 1.day.ago)

    get :closed

    assert_equal [more_recently_closed_consultation, less_recently_closed_consultation], assigns(:consultations)
  end

  test 'closed lists consultations with most recent response first' do
    opening_on, closing_on = 4.days.ago, 3.days.ago
    consultation_with_less_recent_response = create(:published_consultation, opening_on: opening_on, closing_on: closing_on)
    create(:published_consultation_response, consultation: consultation_with_less_recent_response, published_at: 2.days.ago)
    consultation_with_more_recent_response = create(:published_consultation, opening_on: opening_on, closing_on: closing_on)
    create(:published_consultation_response, consultation: consultation_with_more_recent_response, published_at: 1.days.ago)

    get :closed

    assert_equal [consultation_with_more_recent_response, consultation_with_less_recent_response], assigns(:consultations)
  end

  test 'closed lists consultations with most recent response appearing before most recently closed' do
    consultation_with_response = create(:published_consultation, opening_on: 4.days.ago, closing_on: 3.days.ago)
    create(:published_consultation_response, consultation: consultation_with_response, published_at: 1.day.ago)
    consultation_without_response = create(:published_consultation, opening_on: 3.days.ago, closing_on: 2.days.ago)

    get :closed

    assert_equal [consultation_with_response, consultation_without_response], assigns(:consultations)
  end

  test 'closed lists consultations with most recently published first if closed on same date' do
    less_recently_published = create(:published_consultation, first_published_at: 3.days.ago, opening_on: 2.day.ago, closing_on: 1.day.ago)
    more_recently_published = create(:published_consultation, first_published_at: 2.days.ago, opening_on: 2.days.ago, closing_on: 1.day.ago)

    get :closed

    assert_equal [more_recently_published, less_recently_published], assigns(:consultations)
  end

  test 'closed lists consultations with most recently published first if response on same date' do
    less_recently_published = create(:published_consultation, first_published_at: 5.days.ago, opening_on: 3.day.ago, closing_on: 2.days.ago)
    create(:published_consultation_response, consultation: less_recently_published, first_published_at: 1.day.ago)
    more_recently_published = create(:published_consultation, first_published_at: 4.days.ago, opening_on: 3.days.ago, closing_on: 2.days.ago)
    create(:published_consultation_response, consultation: more_recently_published, first_published_at: 1.day.ago)

    get :closed

    assert_equal [more_recently_published, less_recently_published], assigns(:consultations)
  end

  test 'closed shows no list if no closed consultations exist' do
    get :closed

    refute_select '#closed-consultations .consultation'
    assert_select 'p.no-content'
  end

  test 'show displays published consultations' do
    published_consultation = create(:published_consultation)
    get :show, id: published_consultation.document
    assert_response :success
  end

  test 'show displays consultation dates when consultation has finished' do
    published_consultation = create(:published_consultation, opening_on: Date.new(2011, 8, 10), closing_on: Date.new(2011, 11, 1))
    get :show, id: published_consultation.document
    assert_select ".opening-on[title=#{Date.new(2011,8,10).iso8601}]"
    assert_select ".closing-on[title=#{Date.new(2011,11,1).iso8601}]"
  end

  test 'show displays consultation closing date on open consultation' do
    published_consultation = create(:published_consultation, opening_on: Date.new(2010, 1, 1), closing_on: 2.days.from_now)
    get :show, id: published_consultation.document
    assert_select ".closing-on[title=#{2.days.from_now.to_date.iso8601}]"
  end

  test "should not explicitly say that consultation applies to the whole of the UK" do
    published_consultation = create(:published_consultation)

    get :show, id: published_consultation.document

    refute_select inapplicable_nations_selector
  end

  test 'show displays consultation participation link and email' do
    consultation_participation = create(:consultation_participation,
      link_url: "http://telluswhatyouthink.com",
      link_text: "Tell us what you think",
      email: "contact@example.com"
    )
    published_consultation = create(:published_consultation, consultation_participation: consultation_participation)
    get :show, id: published_consultation.document
    assert_select ".participation" do
      assert_select ".online a[href=?]", "http://telluswhatyouthink.com", text: "Tell us what you think"
      assert_select ".email a[href=?]", "mailto:contact@example.com", text: "contact@example.com"
    end
  end

  test 'show does not display consultation participation link if none available' do
    consultation_participation = create(:consultation_participation, email: "contact@example.com")
    published_consultation = create(:published_consultation, consultation_participation: consultation_participation)
    get :show, id: published_consultation.document
    refute_select ".participation .online"
  end

  test 'show does not display consultation participation email if none available' do
    consultation_participation = create(:consultation_participation,
      link_url: "http://telluswhatyouthink.com",
      link_text: "Tell us what you think"
    )
    published_consultation = create(:published_consultation, consultation_participation: consultation_participation)
    get :show, id: published_consultation.document
    refute_select ".participation .email"
  end

  test 'show does not display consultation participation link if consultation finished' do
    consultation_participation = create(:consultation_participation,
      email: "contact@example.com",
      link_url: "http://telluswhatyouthink.com",
      link_text: "Tell us what you think"
    )
    published_consultation = create(:published_consultation, consultation_participation: consultation_participation, opening_on: 4.days.ago, closing_on: 2.days.ago)
    get :show, id: published_consultation.document
    refute_select ".participation .online"
    refute_select ".participation .email"
  end
end
