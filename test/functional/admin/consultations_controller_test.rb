require 'test_helper'

class Admin::ConsultationsControllerTest < ActionController::TestCase
  setup do
    @user = login_as "George"
  end

  test 'is an document controller' do
    assert @controller.is_a?(Admin::DocumentsController), "the controller should have the behaviour of an Admin::DocumentsController"
  end

  test 'shows consultation opening date' do
    consultation = create(:consultation, opening_on: Date.new(2011, 10, 10))
    get :show, id: consultation
    assert_select '.opening_on', text: 'Opened on October 10th, 2011'
  end

  test 'shows consultation closing date' do
    consultation = create(:consultation, closing_on: Date.new(2011, 01, 01))
    get :show, id: consultation
    assert_select '.closing_on', text: 'Closed on January 1st, 2011'
  end
end