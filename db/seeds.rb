def random_policy_text(number_of_paragraphs=3)
  @policy_data ||= File.read(File.expand_path("../seed_policy_bodies.txt", __FILE__)).split("\n")
  @policy_data.shuffle[0...number_of_paragraphs].join("\n\n")
end
alias :random_publication_text :random_policy_text

def organisations(*names)
  names.each do |name|
    Organisation.create!(name: name)
  end
end

def topics(*names)
  names.each do |name|
    Topic.create!(name: name, description: Faker::Lorem.sentence)
  end
end

def create_edition(type, attributes)
  attributes[:topics] = Topic.where(name: (attributes[:topics] || []))
  attributes[:organisations] = Organisation.where(name: (attributes[:organisations] || []))
  attributes[:author] ||= User.create(name: Faker::Name.name)
  attributes[:ministers] = Array.new(rand(2) + 1) { Minister.create!(name: Faker::Name.name) }
  Edition.create!({
    title: "title-n",
    body: random_policy_text,
    document: type.new
  }.merge(attributes))
end

def create_draft(type, attributes = {})
  create_edition(type, attributes)
end

def create_submitted(type, attributes = {})
  edition = create_edition(type, attributes.merge(submitted: true))
  edition.fact_check_requests.create email_address: Faker::Internet.email, comments: Faker::Lorem.paragraph
  edition
end

def create_published(type, attributes = {})
  create_edition(type, attributes.merge(submitted: true, state: "published"))
end

organisations(
  "Attorney General's Office",
  "Cabinet Office",
  "Department for Business, Innovation and Skills",
  "Department for Communities and Local Government",
  "Department for Culture, Media and Sport",
  "Department for Education",
  "Department for Environment, Food and Rural Affairs",
  "Department for International Development",
  "Department for Transport",
  "Department for Work and Pensions",
  "Department of Energy and Climate Change",
  "Department of Health",
  "Foreign and Commonwealth Office",
  "Government Equalities Office",
  "Her Majesty's Treasury",
  "Home Office",
  "Ministry of Defence",
  "Ministry of Justice",
  "Northern Ireland Office",
  "Office of the Advocate General for Scotland",
  "Office of the Leader of the House of Commons",
  "Office of the Leader of the House of Lords",
  "Scotland Office",
  "Wales Office"
)

topics(
  "Regulation reform",
  "International trade",
  "European Union",
  "Export control",
  "Employment rights",
  "Business law",
  "Consumer protection",
  "Further education and skills",
  "Higher education",
  "Economic growth",
  "Business support",
  "Green economy",
  "IT infrastructure",
  "Science and Innovation",
  "Government-owned businesses",
  "Public data corporation",
  "Public sector innovation",
  "Communities and neighbourhoods",
  "Fire and emergencies",
  "Housing",
  "Local Government",
  "Planning, building and the environment",
  "Regeneration and economic growth",
  "Education",
  "Health",
  "Economic Growth",
  "Governance and Conflict",
  "Climate and Environment",
  "Water and Sanitisation",
  "Food and Nutrition",
  "Humanitarian disasters and emergencies",
  "Consular Services",
  "Security",
  "Prosperity",
  "National Security",
  "Constitutional Reform",
  "Government Efficiency",
  "Transparency",
  "Big Society"
)

higher_education = Topic.find_by_name("Higher education")
consular_services = Topic.find_by_name("Consular Services")
fire_and_emergencies = Topic.find_by_name("Fire and emergencies")

create_draft(Policy, title: "Free cats for pensioners", topics: ["Higher Education"], organisations: ["Attorney General's Office", "Cabinet Office"])
create_draft(Policy, title: "Decriminalise beards", topics: ["Higher Education", "Consular Services"], organisations: ["Public sector innovation"])

create_submitted(Policy, title: "Less gravity on Sundays", topics: ["Local Government", "International trade"], organisations: ["Department for Environment, Food and Rural Affairs", "Home Office"])
create_submitted(Policy, title: "Ducks pulling chariots of fire", topics: ["Economic Growth", "Prosperity"], organisations: ["Her Majesty's Treasury"])

create_published(Policy, title: "No more supernanny", topics: ["Water and Sanitisation"], organisations: ["Foreign and Commonwealth Office"])
create_published(Policy, title: "Laser eyes for millionaires", topics: ["Constitutional Reform"], organisations: ["Northern Ireland Office"])

create_published(Publication, title: "Cat Extermination White Paper", topics: ["Water and Sanitisation"], organisations: ["Foreign and Commonwealth Office"])
create_published(Publication, title: "Dog Erradicated Green Paper", topics: ["Constitutional Reform"], organisations: ["Northern Ireland Office"])
create_published(Publication, title: "Canine Consultation", topics: ["Water and Sanitisation"], organisations: ["Foreign and Commonwealth Office"])
create_published(Publication, title: "Feline Consultation", topics: ["Constitutional Reform"], organisations: ["Northern Ireland Office"])
