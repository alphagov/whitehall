FactoryGirl.define do
  factory :worldwide_service do
    name { 'worldwide-service-name' }
    service_type_id { WorldwideServiceType::DocumentaryServices.id }
  end
end
