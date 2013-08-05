FactoryGirl.define do
  sequence :year do |n|
    Time.zone.now.year + n
  end
  
  factory :financial_report do
    year { generate(:year) }
    organisation
  end
end
