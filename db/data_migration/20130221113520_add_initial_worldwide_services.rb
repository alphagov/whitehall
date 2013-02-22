{
  WorldwideServiceType::AssistanceServices => [
    'Emergency Travel Documents service',
    'Transferring funds for prisoners / for financial assistance service'
  ],
  WorldwideServiceType::DocumentaryServices => [
    'Marriage or Civil Partnership registrations',
    'Births and Deaths registration service',
    'Service of Process',
    'Notarial services',
    'Marriages or Civil Partnership service',
    'Citizenship Ceremony service'
  ],
  WorldwideServiceType::OtherServices => [
    'Legalisation Service',
    'Overseas Passports Service'
  ]
}.each do |service_type, service_list|
  service_list.each do |service_name|
    WorldwideService.create!(name: service_name, service_type: service_type)
    puts "Worldwide Service #{service_type.name}: #{service_name} created"
  end
end
