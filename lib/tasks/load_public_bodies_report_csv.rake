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
  task :import, [:filename, :start_year, :end_year] => :environment do |_, args|
    csv = CSV.open(args[:filename], { :headers => :first_row })
    .map{ |body| body}

    Organisation.all.each do |organisation|
      csv_body = csv.find { |body| body["Name"] == organisation.name }
      unless csv_body.nil?
        raw_expenditure = csv_body["Total Gross Expenditure"]
        expenditure = clean_money(raw_expenditure)

        raw_funding = csv_body["Government Funding"]
        funding = clean_money(raw_funding)

        unless expenditure.nil?
          spending_announcement = SpendingAnnouncement.new
          spending_announcement.startdate = DateTime.civil_from_format :local, args[:start_year].to_i
          spending_announcement.enddate = DateTime.civil_from_format :local, args[:end_year].to_i
          spending_announcement.organisation_id = organisation.id
          spending_announcement.spending = expenditure
          spending_announcement.save
        end
        unless funding.nil?
          funding_announcement = FundingAnnouncement.new
          funding_announcement.startdate = DateTime.civil_from_format :local, args[:start_year].to_i
          funding_announcement.enddate = DateTime.civil_from_format :local, args[:end_year].to_i
          funding_announcement.organisation_id = organisation.id
          funding_announcement.funding = funding
          funding_announcement.save
        end
      end
    end
    
  end
end
