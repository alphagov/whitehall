require 'test_helper'

class EmailSignupsControllerTest < ActionController::TestCase
  test 'GET show will make an empty email signup with 1 alert available' do
    get :show

    assert_not_nil assigns(:email_signup)
    assert_equal 1, assigns(:email_signup).alerts.size
  end

  test 'GET reveals the valid set of classifications' do
    EmailSignup.expects(:valid_topics_by_type).returns :a_hash_of_topics_by_type
    get :show

    assert_equal :a_hash_of_topics_by_type, assigns(:classifications)
  end

  test 'GET reveals the valid list of ministerial and other organisations' do
    orgs_by_type = {
      ministerial: :a_list_of_ministerial_orgs,
      other: :a_list_of_other_orgs
    }
    EmailSignup.expects(:valid_organisations_by_type).returns orgs_by_type
    get :show

    assert_equal :a_list_of_ministerial_orgs, assigns(:live_ministerial_departments)
    assert_equal :a_list_of_other_orgs, assigns(:live_other_departments)
  end

  test 'GET reveals the valid set of document types' do
    EmailSignup.expects(:valid_document_types_by_type).returns :a_hash_of_document_types_by_type
    get :show

    assert_equal :a_hash_of_document_types_by_type, assigns(:document_types)
  end

  test 'POST create will convert params[:email_signup][:alerts] from an numerically keyed hash into an array of hashes and pass them to the email signup object' do
    e = EmailSignup.new
    EmailSignup.expects(:new).returns(e)
    e.expects(:alerts=).with([{ 'topic' => 'energy' }, { 'organisation' => 'decc' }])

    post :create, email_signup: { alerts: { '0' => { topic: 'energy' }, '1' => { organisation: 'decc' } } }
  end

  test 'POST create will convert params[:email_signup][:alerts] from a single hash into an array of one hash and pass it to the email signup object' do
    e = EmailSignup.new
    EmailSignup.expects(:new).returns(e)
    e.expects(:alerts=).with([{ 'topic' => 'energy', 'organisation' => 'decc' }])

    post :create, email_signup: { alerts: { topic: 'energy', organisation: 'decc' } }
  end

  test 'POST create will leave params[:email_signup][:alerts] alone if it is already an array of hashes (but still pass it to the email signup object)' do
    e = EmailSignup.new
    EmailSignup.expects(:new).returns(e)
    e.expects(:alerts=).with([{ 'topic' => 'energy' }, { 'organisation' => 'decc' }])

    post :create, email_signup: { alerts: [ { topic: 'energy' }, { organisation: 'decc' } ] }
  end

  test 'POST create will re-render the "show" template if the constructed email signup is not valid' do
    e = EmailSignup.new
    EmailSignup.expects(:new).returns(e)
    e.stubs(:valid?).returns false

    post :create

    assert_template 'show'
  end

  test 'POST create will pass the first alert only (no matter how many are created) to the EmailSignup::GovDeliveryRedirector and redirect the user to it' do
    e = EmailSignup.new
    a = EmailSignup::Alert.new
    EmailSignup.expects(:new).returns(e)
    e.stubs(:valid?).returns true
    e.stubs(:alerts).returns [a, EmailSignup::Alert.new]

    r = EmailSignup::GovUkDeliveryRedirectUrlExtractor.new(a)
    EmailSignup::GovUkDeliveryRedirectUrlExtractor.expects(:new).with(a).returns(r)
    r.expects(:redirect_url).returns('http://govdelivery.example.com/new-signup')

    post :create

    assert_redirected_to 'http://govdelivery.example.com/new-signup'
  end

  test 'POST create will re-render the "show" template and preserve the error on the alert if extracting the redirect url causes an InvalidSlugError' do
    e = EmailSignup.new
    a = EmailSignup::Alert.new
    EmailSignup.expects(:new).returns(e)
    e.stubs(:valid?).returns true
    e.stubs(:alerts).returns [a, EmailSignup::Alert.new]

    r = EmailSignup::GovUkDeliveryRedirectUrlExtractor.new(a)
    EmailSignup::GovUkDeliveryRedirectUrlExtractor.expects(:new).with(a).returns(r)
    r.expects(:redirect_url).raises(EmailSignup::InvalidSlugError.new('slug', :invalid_slug_attribute))

    post :create

    assert_template 'show'
    refute assigns(:email_signup).alerts.first.errors[:invalid_slug_attribute].blank?
  end

end
