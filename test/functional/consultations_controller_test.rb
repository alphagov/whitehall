require "test_helper"

class ConsultationsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_display_attachments_for :consultation
  should_show_featured_documents_for :consultation
  should_show_related_policies_and_policy_areas_for :consultation

  test "should avoid n+1 queries" do
    featured_consultations = Consultation.featured
    ordered_published_consultations = mock("ordered_published_consultations")
    ordered_published_consultations.expects(:includes).with(:document_identity, :organisations, :published_related_policies, ministerial_roles: [:current_people, :organisations]).returns([])
    published_consultations = mock("published_consultations")
    published_consultations.expects(:by_published_at).returns(ordered_published_consultations)
    published_consultations.stubs(:featured).returns(featured_consultations) # To avoid the 'featured consultation' query failing
    Consultation.stubs(:published).returns(published_consultations)

    get :index
  end

  test 'index lists all published consultations' do
    published_open_consultation = create(:published_consultation, opening_on: 1.day.ago, closing_on: 1.day.from_now)
    published_closed_consultation = create(:published_consultation, opening_on: 2.days.ago, closing_on: 1.day.ago)
    published_upcoming_consultation = create(:published_consultation, opening_on: 1.day.from_now, closing_on: 2.days.from_now)
    index_consultation = create(:consultation, opening_on: 1.day.from_now, closing_on: 2.days.from_now)
    get :index

    assert_select '#consultations' do
      assert_select_object published_upcoming_consultation
      assert_select_object published_open_consultation
      assert_select_object published_closed_consultation
      refute_select_object index_consultation
    end
  end

  test 'index lists newest consultations first' do
    oldest_consultation = create(:published_consultation, opening_on: 1.day.from_now, closing_on: 2.days.from_now, published_at: 4.hours.ago)
    newest_consultation = create(:published_consultation, opening_on: 1.day.from_now, closing_on: 2.days.from_now, published_at: 2.hours.ago)

    get :index

    assert_equal [newest_consultation, oldest_consultation], assigns[:consultations]
  end

  test 'index shows no list if no published consultations exist' do
    get :index

    refute_select '#consultations'
    assert_select 'p', text: 'There are no consultations at present.'
  end

  test "index shows the summary for each consultation" do
    consultation = create(:published_consultation, summary: 'a-simple-summary')

    get :index

    assert_select_object consultation do
      assert_select ".summary", text: "a-simple-summary"
    end
  end

  test "index shows response if one has been published" do
    consultation_response = create(:published_consultation_response, title: 'response')
    consultation = consultation_response.consultation

    get :index

    assert_select "a[href='#{consultation_response_path(consultation.document_identity)}']", text: consultation_response.title
  end

  test "should indicate that the list of consultations is limited to only those that are open" do
    get :open
    assert_select "h1", text: "Browse open consultations"
  end

  test "should show the featured consultations when filtering by just those that are open" do
    featured_consultation = create(:published_consultation, featured: true, summary: "consultation-summary")
    get :open
    assert_select featured_consultations_selector do
      assert_select_object featured_consultation do
        assert_select ".summary", text: "consultation-summary"
      end
    end
  end

  test 'open lists published open consultations' do
    published_open_consultation = create(:published_consultation, opening_on: 1.day.ago, closing_on: 1.day.from_now)
    published_closed_consultation = create(:published_consultation, opening_on: 2.days.ago, closing_on: 1.day.ago)
    published_index_consultation = create(:published_consultation, opening_on: 1.day.from_now, closing_on: 2.days.from_now)
    open_consultation = create(:consultation, opening_on: 1.day.ago, closing_on: 1.day.from_now)
    get :open

    assert_select '#consultations' do
      assert_select_object published_open_consultation
      refute_select_object published_closed_consultation
      refute_select_object published_index_consultation
      refute_select_object open_consultation
    end
  end

  test 'open lists newest consultations first' do
    oldest_consultation = create(:published_consultation, opening_on: 1.day.ago, closing_on: 1.day.from_now, published_at: 4.hours.ago)
    newest_consultation = create(:published_consultation, opening_on: 1.day.ago, closing_on: 1.day.from_now, published_at: 2.hours.ago)

    get :open

    assert_equal [newest_consultation, oldest_consultation], assigns[:consultations]
  end

  test 'open shows no list if no open consultations exist' do
    get :open

    refute_select '#consultations'
    assert_select 'p', text: 'There are no open consultations at present.'
  end

  test "should indicate that the list of consultations is limited to only those that are closed" do
    get :closed
    assert_select "h1", text: "Browse closed consultations"
  end

  test "should show the featured consultations when filtering by just those that are closed" do
    featured_consultation = create(:published_consultation, featured: true, summary: "consultation-summary")
    get :closed
    assert_select featured_consultations_selector do
      assert_select_object featured_consultation do
        assert_select ".summary", text: "consultation-summary"
      end
    end
  end

  test 'closed lists published closed consultations' do
    published_open_consultation = create(:published_consultation, opening_on: 1.day.ago, closing_on: 1.day.from_now)
    published_closed_consultation = create(:published_consultation, opening_on: 2.days.ago, closing_on: 1.day.ago)
    published_index_consultation = create(:published_consultation, opening_on: 1.day.from_now, closing_on: 2.days.from_now)
    closed_consultation = create(:consultation, opening_on: 2.days.ago, closing_on: 1.day.ago)
    get :closed

    assert_select '#consultations' do
      assert_select_object published_closed_consultation
      refute_select_object published_open_consultation
      refute_select_object published_index_consultation
      refute_select_object closed_consultation
    end
  end

  test 'closed lists newest consultations first' do
    oldest_consultation = create(:published_consultation, opening_on: 2.days.ago, closing_on: 1.day.ago, published_at: 4.hours.ago)
    newest_consultation = create(:published_consultation, opening_on: 2.days.ago, closing_on: 1.day.ago, published_at: 2.hours.ago)

    get :closed

    assert_equal [newest_consultation, oldest_consultation], assigns[:consultations]
  end

  test 'closed shows no list if no closed consultations exist' do
    get :closed

    refute_select '#consultations'
    assert_select 'p', text: 'There are no closed consultations at present.'
  end

  test 'show displays published consultations' do
    published_consultation = create(:published_consultation)
    get :show, id: published_consultation.document_identity
    assert_response :success
  end

  test 'show displays consultation opening date' do
    published_consultation = create(:published_consultation, opening_on: Date.new(2011, 10, 10))
    get :show, id: published_consultation.document_identity
    assert_select '.opening_on', text: 'Opened on October 10th, 2011'
  end

  test 'show displays consultation closing date' do
    published_consultation = create(:published_consultation, opening_on: Date.new(2010, 1, 1), closing_on: Date.new(2011, 01, 01))
    get :show, id: published_consultation.document_identity
    assert_select '.closing_on', text: 'Closed on January 1st, 2011'
  end

  test "should show inapplicable nations" do
    published_consultation = create(:published_consultation)
    northern_ireland_inapplicability = published_consultation.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://northern-ireland.com/")
    scotland_inapplicability = published_consultation.nation_inapplicabilities.create!(nation: Nation.scotland)

    get :show, id: published_consultation.document_identity

    assert_select inapplicable_nations_selector do
      assert_select "p", "This consultation does not apply to Northern Ireland and Scotland."
      assert_select_object northern_ireland_inapplicability do
        assert_select "a[href='http://northern-ireland.com/']"
      end
      refute_select_object scotland_inapplicability
    end
  end

  test "should explain that consultation applies to the whole of the UK" do
    published_consultation = create(:published_consultation)

    get :show, id: published_consultation.document_identity

    assert_select inapplicable_nations_selector do
      assert_select "p", "This consultation applies to the whole of the UK."
    end
  end

  test "should display the closing date of the featured consultation" do
    closing_date = 20.days.from_now
    consultation = create(:published_consultation, featured: true, closing_on: closing_date)
    get :index
    assert_select send("featured_consultations_selector") do
      assert_select "#{record_css_selector(consultation)} .time_remaining", text: "Closes in 21 days"
    end
  end
end
