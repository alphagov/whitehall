def create_document(type, attributes)
  attributes[:policy_areas] = PolicyArea.where(name: (attributes[:policy_areas] || [])) if type.new.respond_to?(:policy_areas=)
  attributes[:organisations] = Organisation.where(name: (attributes[:organisations] || []))
  attributes[:creator] ||= User.create(name: Faker::Name.name)
  attributes[:ministerial_roles] = Array.new(rand(2) + 1) { MinisterialRole.order("RAND()").first } unless type == Speech
  attributes.merge!(
    publication_date: rand(365).days.ago,
    unique_reference: rand(1000000).to_s,
    isbn: "0140621431",
    research: rand(2).even?,
    order_url: "http://example.com/#{Whitehall::Random.base32}"
  ) if type == Publication
  type.create!({
    title: "title-n",
    body: random_policy_text
  }.merge(attributes))
end

def create_draft(type, attributes = {})
  create_document(type, attributes)
end

def create_submitted(type, attributes = {})
  document = create_document(type, attributes.merge(state: "submitted"))
  document.fact_check_requests.create email_address: Faker::Internet.email, comments: Faker::Lorem.paragraph
  document
end

def create_published(type, attributes = {})
  create_document(type, attributes.merge(state: "published", published_at: rand(365).days.ago))
end

def create_supporting(document, attributes={})
  document.supporting_pages.create!(attributes)
end

def random_policy_text(number_of_paragraphs=3)
  @policy_data ||= File.read(File.expand_path("../seed_policy_bodies.txt", __FILE__)).split("\n")
  @policy_data.shuffle[0...number_of_paragraphs].join("\n\n")
end
alias :random_publication_text :random_policy_text

PolicyArea.all.each do |policy_area|
  policy_area.update_attributes!(description: Faker::Lorem.sentence)
end

create_draft(Policy, title: "Free cats for pensioners", policy_areas: ["Higher Education"], organisations: ["Attorney General's Office", "Cabinet Office"])
create_draft(Policy, title: "Decriminalise beards", policy_areas: ["Higher Education", "Consular Services"], organisations: ["Public sector innovation"])

create_submitted(Policy, title: "Less gravity on Sundays", policy_areas: ["Local Government", "International trade"], organisations: ["Department for Environment, Food and Rural Affairs", "Home Office"])
create_submitted(Policy, title: "Ducks pulling chariots of fire", policy_areas: ["Economic Growth", "Prosperity"], organisations: ["Her Majesty's Treasury"])

create_published(Policy, title: "No more supernanny", policy_areas: ["Water and Sanitisation"], organisations: ["Foreign and Commonwealth Office"])
published_laser_eyes_policy = create_published(Policy, title: "Laser eyes for millionaires", policy_areas: ["Constitutional Reform"], organisations: ["Northern Ireland Office"])

create_published(Publication, title: "Cat Extermination White Paper", organisations: ["Foreign and Commonwealth Office"])
create_published(Publication, title: "Dog Erradicated Green Paper", organisations: ["Northern Ireland Office"])
create_published(Publication, title: "Canine Consultation", organisations: ["Foreign and Commonwealth Office"])
create_published(Publication, title: "Feline Consultation", organisations: ["Northern Ireland Office"])
create_supporting(published_laser_eyes_policy, title: "Some more cat details", body: "Miaaaaow.")

create_published(NewsArticle, title: "News about Laser eyes", related_policies: [published_laser_eyes_policy])
create_published(Consultation, title: "Consultation about Laser eyes", opening_on: 1.year.ago, closing_on: 6.months.ago, related_policies: [published_laser_eyes_policy])
transcript_speech_type = SpeechType.find_or_create_by_name("Transcript")
create_published(Speech, speech_type: transcript_speech_type, title: "Speech about Laser eyes", delivered_on: 1.day.ago, location: "Whitehall", role_appointment: RoleAppointment.first, related_policies: [published_laser_eyes_policy])

bis = Organisation.find_by_name! "Department for Business, Innovation and Skills"
bis.child_organisations << Organisation.create!(name: "Companies House", organisation_type: OrganisationType.first)
bis.child_organisations << Organisation.create!(name: "UKTI", organisation_type: OrganisationType.first)

the_stabilisation_unit = Organisation.create!(name: "The stabilisation unit", organisation_type: OrganisationType.first)
the_stabilisation_unit.parent_organisations << Organisation.find_by_name!("Department for International Development")
the_stabilisation_unit.parent_organisations << Organisation.find_by_name!("Foreign and Commonwealth Office")