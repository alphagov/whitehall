require 'test_helper'

class Admin::HistoricalAccountsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
    @person = create(:person)
    @role = create(:historic_role)
    @historical_account = create(:historical_account, person: @person, roles: [@role])
  end

  test "GET on :index assigns the person, their historical accounts and renders the :index template" do
    get :index, person_id: @person

    assert_response :success
    assert_template :index
    assert_equal @person, assigns(:person)
    assert_equal @person.historical_accounts, assigns(:historical_accounts)
  end

  test "GET on :new assigns the person, a fresh historical account and renders the :new template" do
    get :new, person_id: @person

    assert_response :success
    assert_template :new
    assert_equal @person, assigns(:person)
    assert assigns(:historical_account).is_a?(HistoricalAccount)
    assert assigns(:historical_account).new_record?
  end

  test "POST on :create saves the historical account and redirects to the historical accounts index" do
    historical_account_params = {
      summary: 'Summary',
      body: 'Body',
      role_ids: [@role.id],
      political_party_ids: [PoliticalParty::Labour.id],
      interesting_facts: 'Stuff',
      major_acts: 'Mo Stuff'
    }

    assert_difference('@person.historical_accounts.count') do
      post :create, person_id: @person, historical_account: historical_account_params
    end

    assert_redirected_to admin_person_historical_accounts_path(@person)

    historical_account = @person.historical_accounts.last
    assert_equal [@role], historical_account.roles
    assert_equal 'Summary', historical_account.summary
    assert_equal 'Body', historical_account.body
    assert_equal [PoliticalParty::Labour], historical_account.political_parties
    assert_equal 'Stuff', historical_account.interesting_facts
    assert_equal 'Mo Stuff', historical_account.major_acts
  end

  test "POST on :create with invalid paramters re-renders :new template" do
    assert_no_difference('@person.historical_accounts.count') do
      post :create, person_id: @person, historical_account: { summary: 'Only summary' }
    end
    assert_template :new
    assert_equal 'Only summary', assigns(:historical_account).summary
  end

  test "GET on :edit loads the historical account and renders the :edit template" do
    get :edit, person_id: @person, id: @historical_account

    assert_response :success
    assert_template :edit
    assert_equal @person, assigns(:person)
    assert_equal @historical_account, assigns(:historical_account)
  end

  test "PUT on :update updates the details of the historical account" do
    put :update, person_id: @person, id: @historical_account, historical_account: { summary: 'New summary' }

    assert_redirected_to admin_person_historical_accounts_path(@person)
    assert_equal 'New summary', @historical_account.reload.summary
  end

  test "PUT on :update with invalid paramters re-renders the :edit template" do
    summary_before = @historical_account.summary
    put :update, person_id: @person, id: @historical_account, historical_account: { summary: '' }
    assert_template :edit
    assert_equal summary_before, @historical_account.reload.summary
    assert_equal '', assigns(:historical_account).summary
  end

  test "Delete on :destroy destroys the historical account" do
    delete :destroy, person_id: @person, id: @historical_account
    refute HistoricalAccount.exists?(@historical_account)
    assert_redirected_to admin_person_historical_accounts_path(@person)
  end
end
