if User.where(name: "Test user").present?
  puts "Skipping because user already exists"
else
  gds_organisation_id = "af07d5a5-df63-4ddc-9383-6a666845ebe9"
  User.create!(
    name: "Test user",
    permissions: ["signin", "GDS Admin", "GDS Editor", "Managing Editor"],
    organisation_content_id: gds_organisation_id,
    organisation_slug: "test-organisation"
  )
end

if Organisation.where(name: "HM Revenue & Customs").present?
  puts "Skipping because HMRC organisation already exists"
else
  Organisation.create!(
    name: "HM Revenue & Customs",
    slug: "hm-revenue-customs",
    acronym: "HRMC",
    organisation_type_key: :other,
    logo_formatted_name: "Test",
    content_id: "6667cce2-e809-4e21-ae09-cb0bdc1ddda3"
  )
end

if Organisation.where(name: "Test Organisation").present?
  puts "Skipping because Test Organisation already exists"
else
  Organisation.create!(
    name: "Test Organisation",
    slug: "test-organisation",
    acronym: "TO",
    organisation_type_key: :other,
    logo_formatted_name: "Test"
  )
end

if Government.where(name: "Test Government").present?
  puts "Skipping because Test Government already exists"
else
  Government.create(
    name: "Test Government",
    start_date: Time.new(2001, 1, 1)
  )
end

if Topic.where(name: "Test Policy Area").present?
  puts "Skipping because Test Policy Area already exists"
else
  Topic.create(
    name: "Test Policy Area",
    description: "Test Policy Area Description"
  )
end
