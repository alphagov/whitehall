require 'test_helper'

class Admin::FinancialReportsControllerTest < ActionController::TestCase

  setup do
    login_as :departmental_editor
  end
  
  should_be_an_admin_controller

  test "GET on :index is found" do
    organisation = FactoryGirl.create(:organisation)
    get :index, organisation_id: organisation

    assert_response :success
  end
  
  test "POST to :create with valid data creates a new financial_report" do
    organisation = FactoryGirl.create(:organisation)
    post :create,
    financial_report: {
      year: 2013,
      spending: 2400,
      funding: 2380
    },
    organisation_id: organisation.id

    assert_redirected_to admin_organisation_financial_reports_url(organisation)
    assert_equal "Created Financial Report", flash[:notice]
    assert_equal 1, organisation.financial_reports.count
  end
  
  test "PUT to :update with valid data updates the financial report" do
    financial_report = FactoryGirl.create(:financial_report)
    organisation = financial_report.organisation
    put :update,
    financial_report: {
      year: financial_report.year,
      spending: 4096,
      funding: 0,
    },
    id: financial_report.id,
    organisation_id: financial_report.organisation_id

    
    assert_redirected_to admin_organisation_financial_reports_url(organisation)
    assert_equal "Updated Financial Report", flash[:notice]
    assert_equal 1, organisation.financial_reports.count
  end

  test "PUT to :update with invalid data gives error 400" do
    financial_report = FactoryGirl.create(:financial_report)
    organisation = financial_report.organisation
    put :update,
    financial_report: {
      year: 'not-a-year',
      spending: 0,
      funding: 0
    },
    id: financial_report.id,
    organisation_id: financial_report.organisation_id
  
    assert_response :bad_request
  end

  test "DELETE on a financial report removes it" do
    financial_report = FactoryGirl.create(:financial_report, year: 2013, spending: 0, funding: 0)
    organisation = financial_report.organisation
    
    delete :destroy, organisation_id: financial_report.organisation_id, id: financial_report.id

    assert_redirected_to admin_organisation_financial_reports_url(organisation)
    assert_equal 0, organisation.financial_reports.count
  end
end
