require 'test_helper'

class Admin::FinancialReportsControllerTest < ActionController::TestCase

  setup do
    login_as :departmental_editor
  end
  
  should_be_an_admin_controller

  view_test "GET :index lists the organisation's reports" do
    report = create(:financial_report, funding: 20000)
    get :index, organisation_id: report.organisation
    assert_select 'td', text: report.year
    assert_select 'td', /20,000/
  end
  
  test "POST to :create with valid data creates a new financial_report" do
    organisation = create(:organisation)
    post :create, organisation_id: organisation, financial_report: {
      year: 2013, spending: 2400, funding: 2380
    }

    assert_redirected_to admin_organisation_financial_reports_url(organisation)
    assert_equal "Created Financial Report", flash[:notice]
    assert_equal 1, organisation.financial_reports.count
  end
  
  test "PUT to :update with valid data updates the financial report" do
    financial_report = create(:financial_report)
    organisation = financial_report.organisation
    put :update, organisation_id: organisation, id: financial_report, financial_report: {
      year: financial_report.year, spending: 4096, funding: 0
    }
    
    assert_redirected_to admin_organisation_financial_reports_url(organisation)
    assert_equal "Updated Financial Report", flash[:notice]
    assert_equal 1, organisation.financial_reports.count
  end

  view_test "PUT to :update with invalid data re-renders the form with code 400" do
    financial_report = create(:financial_report)
    organisation = financial_report.organisation
    put :update, organisation_id: organisation, id: financial_report, financial_report: {
      year: 'not-a-year', spending: 0, funding: 0
    }
    assert_select 'div.alert'
    assert_response :bad_request
  end

  test "DELETE on a financial report removes it" do
    financial_report = create(:financial_report, year: 2013, spending: 0, funding: 0)
    organisation = financial_report.organisation
    
    assert_difference 'organisation.financial_reports.count', -1 do
      delete :destroy, organisation_id: organisation, id: financial_report
    end

    assert_redirected_to admin_organisation_financial_reports_url(organisation)
  end
end
