def create_document(type, attributes)
  attributes[:topics] = Topic.where(name: (attributes[:topics] || [])) if type.new.respond_to?(:topics=)
  attributes[:organisations] = Organisation.where(name: (attributes[:organisations] || []))
  attributes[:author] ||= User.create(name: Faker::Name.name)
  attributes[:ministerial_roles] = Array.new(rand(2) + 1) { MinisterialRole.order("RAND()").first }
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
  create_document(type, attributes.merge(state: "published"))
end

def create_supporting(document, attributes={})
  document.supporting_documents.create!(attributes)
end

def random_policy_text(number_of_paragraphs=3)
  @policy_data ||= File.read(File.expand_path("../seed_policy_bodies.txt", __FILE__)).split("\n")
  @policy_data.shuffle[0...number_of_paragraphs].join("\n\n")
end
alias :random_publication_text :random_policy_text

Topic.all.each do |topic|
  topic.update_attributes!(description: Faker::Lorem.sentence)
end

create_draft(Policy, title: "Free cats for pensioners", topics: ["Higher Education"], organisations: ["Attorney General's Office", "Cabinet Office"])
create_draft(Policy, title: "Decriminalise beards", topics: ["Higher Education", "Consular Services"], organisations: ["Public sector innovation"])

create_submitted(Policy, title: "Less gravity on Sundays", topics: ["Local Government", "International trade"], organisations: ["Department for Environment, Food and Rural Affairs", "Home Office"])
create_submitted(Policy, title: "Ducks pulling chariots of fire", topics: ["Economic Growth", "Prosperity"], organisations: ["Her Majesty's Treasury"])

create_published(Policy, title: "No more supernanny", topics: ["Water and Sanitisation"], organisations: ["Foreign and Commonwealth Office"])
policy = create_published(Policy, title: "Laser eyes for millionaires", topics: ["Constitutional Reform"], organisations: ["Northern Ireland Office"])

create_published(Publication, title: "Cat Extermination White Paper", organisations: ["Foreign and Commonwealth Office"])
create_published(Publication, title: "Dog Erradicated Green Paper", organisations: ["Northern Ireland Office"])
create_published(Publication, title: "Canine Consultation", organisations: ["Foreign and Commonwealth Office"])
create_published(Publication, title: "Feline Consultation", organisations: ["Northern Ireland Office"])
create_supporting(policy, title: "Some more cat details", body: "Miaaaaow.")