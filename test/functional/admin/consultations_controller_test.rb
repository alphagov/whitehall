require 'test_helper'

class Admin::ConsultationsControllerTest < ActionController::TestCase
  setup do
    @user = login_as "George"
  end

  test 'is an document controller' do
    assert @controller.is_a?(Admin::DocumentsController), "the controller should have the behaviour of an Admin::DocumentsController"
  end

  test 'new displays consultation form' do
    get :new

    assert_select "form[action='#{admin_consultations_path}']" do
      assert_select "input[name='document[title]'][type='text']"
      assert_select "textarea[name='document[body]']"
      assert_select "select[name*='document[opening_on']", count: 3
      assert_select "select[name*='document[closing_on']", count: 3
      assert_select "input[type='submit']"
    end
  end

  test 'creating creates a new consultation' do
    attributes = attributes_for(:consultation)
    post :create, document: attributes

    created_consultation = Consultation.last
    assert_equal attributes[:title], created_consultation.title
    assert_equal attributes[:body], created_consultation.body
    assert_equal attributes[:opening_on].to_date, created_consultation.opening_on
    assert_equal attributes[:closing_on].to_date, created_consultation.closing_on
  end

  test 'creating takes the writer to the consultation page' do
    post :create, document: attributes_for(:consultation)

    assert_redirected_to admin_consultation_path(Consultation.last)
    assert_equal 'The document has been saved', flash[:notice]
  end

  test 'show displays consultation opening date' do
    consultation = create(:consultation, opening_on: Date.new(2011, 10, 10))
    get :show, id: consultation
    assert_select '.opening_on', text: 'Opened on October 10th, 2011'
  end

  test 'show displays consultation closing date' do
    consultation = create(:consultation, opening_on: Date.new(2010, 01, 01), closing_on: Date.new(2011, 01, 01))
    get :show, id: consultation
    assert_select '.closing_on', text: 'Closed on January 1st, 2011'
  end

  test 'edit displays consultation form' do
    consultation = create(:consultation)

    get :edit, id: consultation

    assert_select "form[action='#{admin_consultation_path(consultation)}']" do
      assert_select "input[name='document[title]'][type='text']"
      assert_select "textarea[name='document[body]']"
      assert_select "select[name*='document[opening_on']", count: 3
      assert_select "select[name*='document[closing_on']", count: 3
      assert_select "input[type='submit']"
    end
  end

  test 'update updates consultation' do
    consultation = create(:consultation)

    put :update, id: consultation, document: consultation.attributes.merge(opening_on: 1.day.ago, closing_on: 50.days.from_now)

    consultation.reload
    assert_equal 1.day.ago.to_date, consultation.opening_on
    assert_equal 50.days.from_now.to_date, consultation.closing_on
  end
end