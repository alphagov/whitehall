FactoryBot.define do
  factory :home_page_list_item do
    item { create(:contact) }
    home_page_list
    ordering { 99 }
  end
end
