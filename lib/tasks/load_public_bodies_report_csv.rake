# -*- coding: utf-8-*-
require "csv"

def cleanMoney(raw_money)
  if raw_money == '0'
    money = 0
  elsif /£[0-9,]+/.match(raw_money)
    money = raw_money.gsub(/[£,]/, '').to_i
  else
    money = nil
  end
  return money
end

namespace :publicbodies do
  task :import, [:filename, :startYear, :endYear] => :environment do |_, args|
    csv = CSV.open(args[:filename], { :headers => :first_row })
    .map{ |body| body}

    Organisation.all.each do |organisation|
      csvBody = csv.find { |body| body["Name"] == organisation.name }
      unless csvBody.nil?
        raw_expenditure = csvBody["Total Gross Expenditure"]
        expenditure = cleanMoney(raw_expenditure)

        raw_funding = csvBody["Government Funding"]
        funding = cleanMoney(raw_funding)

        unless expenditure.nil?
          puts 'Publishing Spending and Funding Announcements for %s' % organisation.name
          
          spending_announcement = SpendingAnnouncement.new
          spending_announcement.startdate = DateTime.civil_from_format :local, args[:startYear].to_i
          spending_announcement.enddate = DateTime.civil_from_format :local, args[:endYear].to_i
          spending_announcement.organisation_id = organisation.id
          spending_announcement.spending = expenditure
          spending_announcement.save
        end
        unless funding.nil?
          funding_announcement = FundingAnnouncement.new
          funding_announcement.startdate = DateTime.civil_from_format :local, args[:startYear].to_i
          funding_announcement.enddate = DateTime.civil_from_format :local, args[:endYear].to_i
          funding_announcement.organisation_id = organisation.id
          funding_announcement.funding = funding
          funding_announcement.save
        end
      end
    end
    
  end
end
