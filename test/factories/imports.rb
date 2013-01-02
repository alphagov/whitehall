FactoryGirl.define do
  factory :import do
    data_type "consultation"
    organisation
    csv_data (
      "old_url,title,summary,body,organisation,"+
      "policy_1,policy_2,policy_3,policy_4," +
      "opening_date,closing_date,consultation_isbn," +
      "consultation_urn,response_date,response_summary\n") * 2
  end
end
