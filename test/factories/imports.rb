FactoryGirl.define do
  factory :import do
    data_type "consultation"
    csv_data "old_url,title,summary,body,organisation,policy_1,policy_2,policy_3,policy_4,minister_1,minister_2,opening_date,closing_date,respond_url,respond_email,respond_postal_address,respond_form_title,respond_form_attachment,consultation_isbn,consultation_urn,publication_date,order_url,command_paper_number,price,response_date,response_summary,comments\n" * 2
  end
end