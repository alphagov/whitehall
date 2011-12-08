require "test_helper"

class ConsultationsControllerTest < ActionController::TestCase
  include DocumentControllerTestHelpers

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

  test "should ignore unpublished featured consultations" do
    draft_featured_consultation = create(:draft_consultation, featured: true)
    get :index
    refute assigns[:featured_consultations].include?(draft_featured_consultation)
  end

  test "should ignore published non-featured consultations" do
    published_consultation = create(:published_consultation, featured: false)
    get :index
    refute assigns[:featured_consultations].include?(published_consultation)
  end

  test "should order published featured consultations by publication date" do
    old_consultation = create(:published_consultation, featured: true, published_at: 1.month.ago)
    new_consultation = create(:published_consultation, featured: true, published_at: 1.day.ago)
    get :index
    assert_equal [new_consultation, old_consultation], assigns[:featured_consultations]
  end

  test "should not display the featured consultation list if there aren't featured consultations" do
    create(:published_consultation)
    get :index
    refute_select featured_consultations_selector
  end

  test "should display a link to the featured consultation" do
    consultation = create(:published_consultation, featured: true)
    get :index
    assert_select featured_consultations_selector do
      assert_select "#{record_css_selector(consultation)} a[href=#{consultation_path(consultation.document_identity)}]"
    end
  end

  test "should display the date the featured consultation was published" do
    published_at = Time.zone.now
    consultation = create(:published_consultation, featured: true, published_at: published_at)
    get :index
    assert_select featured_consultations_selector do
      assert_select "#{record_css_selector(consultation)} .published_at[title=#{published_at.iso8601}]"
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

  test 'show displays related published policies' do
    published_policy = create(:published_policy)
    consultation = create(:published_consultation, related_documents: [published_policy])
    get :show, id: consultation.document_identity
    assert_select_object published_policy
  end

  test 'show doesn\'t display related unpublished policies' do
    draft_policy = create(:draft_policy)
    consultation = create(:published_consultation, related_documents: [draft_policy])
    get :show, id: consultation.document_identity
    refute_select_object draft_policy
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

  should_display_attachments_for :consultation
end
