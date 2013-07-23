# -*- coding: utf-8-*-
require "csv"

def clean_money(raw_money)
  if raw_money == '0'
    money = 0
  elsif /£[0-9,]+/.match(raw_money)
    money = raw_money.gsub(/[£,]/, '').to_i
  else
    money = nil
  end
  return money
end

namespace :public_bodies do
  task :import, [:filename, :year] => :environment do |_, args|
    csv = CSV.open(args[:filename], { :headers => :first_row })
    .map{ |body| body}

    Organisation.all.each do |organisation|
      csv_body = csv.find { |body| body["Name"] == organisation.name }
      unless csv_body.nil?
        raw_spending = csv_body["Total Gross Expenditure"]
        spending = clean_money(raw_spending)

        raw_funding = csv_body["Government Funding"]
        funding = clean_money(raw_funding)

        unless spending.nil? && funding.nil?
          financial_report = FinancialReport.new
          financial_report.year = args[:year].to_i
          financial_report.organisation_id = organisation.id
          financial_report.spending = spending
          financial_report.funding = funding
          financial_report.save
        end
      end
    end

  end
end
