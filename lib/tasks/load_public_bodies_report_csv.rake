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

def clean_yes_no(raw_boolean)
  if raw_boolean.downcase == 'yes'
    return true
  elsif raw_boolean.downcase == 'no'
    return false
  else
    return nil
  end
end

namespace :public_bodies do
  task :import, [:filename, :year] => :environment do |_, args|
    csv = CSV.open(args[:filename], { :headers => :first_row })
      .map{ |body| body}

    Organisation.all.each do |organisation|
      if organisation.non_departmental_public_body?
        csv_body = csv.find { |body| body["Name"] == organisation.name }
        unless csv_body.nil?
          raw_spending = csv_body["Total Gross Expenditure"]
          spending = clean_money(raw_spending)

          raw_funding = csv_body["Government Funding"]
          funding = clean_money(raw_funding)

          raw_ocpa_regulated = csv_body["OCPA Regulated"]
          raw_public_meetings = csv_body["Public Meetings"]
          raw_public_minutes = csv_body["Public Minutes"]
          raw_register_of_interests = csv_body["Register of Interests"]
          raw_regulatory_function = csv_body["Regulatory Function"]

          organisation.ocpa_regulated = clean_yes_no(raw_ocpa_regulated)
          organisation.public_meetings = clean_yes_no(raw_public_meetings)
          organisation.public_minutes = clean_yes_no(raw_public_minutes)
          organisation.register_of_interests = clean_yes_no(raw_register_of_interests)
          organisation.regulatory_function = clean_yes_no(raw_regulatory_function)

          unless spending.nil? && funding.nil?
            financial_report = FinancialReport.where(organisation_id: organisation, year: args[:year].to_i).first_or_initialize
            financial_report.spending = spending
            financial_report.funding = funding
            financial_report.save
          end

          organisation.save
        end
      end
    end
  end
end
