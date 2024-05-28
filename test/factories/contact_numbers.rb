FactoryBot.define do
  factory :contact_number, traits: [:translated] do
    contact
    label { "fax" }
    number { "123" }
  end
end
