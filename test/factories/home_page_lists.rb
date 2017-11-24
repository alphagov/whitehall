FactoryBot.define do
  factory :home_page_list do
    owner { create(:organisation) }
    name { 'contacts' }
  end
end
