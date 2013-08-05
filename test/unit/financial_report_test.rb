require "test_helper"

class FinancialReportTest < ActiveSupport::TestCase
  test 'a year must be specified' do
    financial_report = FactoryGirl.build(:financial_report)
    financial_report.year = nil
    refute financial_report.valid?
  end

  test 'accepts nil spending' do
    financial_report = FactoryGirl.build(:financial_report)
    financial_report.spending = nil
    assert financial_report.valid?
  end
  test 'accepts nil funding' do
    financial_report = FactoryGirl.build(:financial_report)
    financial_report.funding = nil
    assert financial_report.valid?
  end
  test 'accepts nil funding and spending' do
    financial_report = FactoryGirl.build(:financial_report)
    financial_report.spending = nil
    financial_report.funding = nil
    assert financial_report.valid?
  end
  test 'rejects non-numeric data for funding' do
    financial_report = FactoryGirl.build(:financial_report)
    financial_report.funding = 'abc'
    refute financial_report.valid?
  end
  test 'rejects non-numeric data for spending' do
    financial_report = FactoryGirl.build(:financial_report)
    financial_report.spending = 'abc'
    refute financial_report.valid?
  end
  test 'rejects non-numeric data for year' do
    financial_report = FactoryGirl.build(:financial_report)
    financial_report.year = 'abc'
    refute financial_report.valid?
  end
  test 'an organisation cannot have two financial reports for one year' do
    organisation = FactoryGirl.create(:organisation)
    financial_report_1 = FactoryGirl.create(:financial_report, year: 2003, organisation: organisation)
    assert financial_report_1.valid?
    financial_report_2 = FactoryGirl.build(:financial_report, year: 2003, organisation: organisation)

    refute financial_report_2.valid?
  end
end
