# encoding: utf-8

puts "Seeding data in #{Rails.env} environment..." unless Rails.env.test?

def organisations(*names)
  names.each do |name|
    Organisation.find_or_create_by_name(name: name)
  end
end

def topics(*names)
  names.each do |name|
    Topic.create!(name: name, description: Faker::Lorem.sentence)
  end
end

def people(person_to_role_to_organisation)
  person_to_role_to_organisation.each do |person_name, role_to_organisation|
    person = Person.create!(name: person_name)
    role_to_organisation.each do |role_name, organisation_name|
      if organisation_name
        organisation = Organisation.find_or_create_by_name(organisation_name)
        role = organisation.roles.create!(name: role_name)
      else
        role = Role.create!(name: role_name)
      end
      person.roles << role
    end
  end
end

people({"The Rt Hon David Cameron" => {"Prime Minister" => "Cabinet Office, Prime Minister's Office"},
 "The Rt Hon Nick Clegg MP" => {"Deputy Prime Minister" => "Cabinet Office"},
 "The Rt Hon William Hague MP" => {"First Secretary of State" => "Foreign and Commonwealth Office"},
 "The Rt Hon George Osborne MP" => {"Chancellor of the Exchequer" => "HM Treasury"},
 "The Rt Hon Kenneth Clarke QC MP" => {"Secretary of State for Justice" => "Ministry of Justice"},
 "The Rt Hon Theresa May MP" => {"Secretary of State for the Home Department" => "Home Office, Government Equalities Office"},
 "The Rt Hon Dr Liam Fox MP" => {"Secretary of State for Defence" => nil},
 "The Rt Hon Dr Vincent Cable MP" => {"Secretary of State for Business, Innovation and Skills" => "Department for Business, Innovation and Skills"},
 "The Rt Hon Iain Duncan Smith MP" => {"Secretary of State for Work and Pensions" => "Department for Work and Pensions"},
 "The Rt Hon Chris Huhne MP" => {"Secretary of State for Energy and Climate Change" => "Department for Energy and Climate Change"},
 "The Rt Hon Andrew Lansley CBE MP" => {"Secretary of State for Health" => "Department of Health"},
 "The Rt Hon Michael Gove MP" => {"Secretary of State for Education" => "Department for Education"},
 "The Rt Hon Eric Pickles MP" => {"Secretary of State for Communities and Local Government" => "Department for Communities and Local Government"},
 "The Rt Hon Philip Hammond MP" => {"Secretary of State for Transport" => "Department for Transport"},
 "The Rt Hon Caroline Spelman MP" => {"Secretary of State for Environment, Food and Rural Affairs" => "Department for Environment, Food and Rural Affairs"},
 "The Rt Hon Andrew Mitchell MP" => {"Secretary of State for International Development" => "Department for International Development"},
 "The Rt Hon Jeremy Hunt MP" => {"Secretary of State for Culture, Olympics, Media and Sport" => nil},
 "The Rt Hon Owen Paterson MP" => {"Secretary of State for Northern Ireland" => "Northern Ireland Office"},
 "The Rt Hon Michael Moore MP" => {"Secretary of State for Scotland" => "Scotland Office"},
 "The Rt Hon Cheryl Gillan MP" => {"Secretary of State for Wales " => "Wales Office"},
 "The Rt Hon Danny Alexander MP" => {"Chief Secretary to the Treasury" => nil},
 "The Rt Hon Baroness Warsi" => {"Minister without Portfolio" => "Cabinet Office"},
 "The Rt Hon Lord Strathclyde" => {"Office of the Leader of the House of Lords" => nil},
 "The Rt Hon Francis Maude MP" => {"Minister for the Cabinet Office" => "Cabinet Office"},
 "The Rt Hon Oliver Letwin MP" => {"Minister of State, Cabinet Office (providing policy to the Prime Minister in the Cabinet Office)" => "Cabinet Office"},
 "The Rt Hon David Willetts MP" => {"Minister of State (Universities and Science), Department for Business, Innovation and Skills" => "Department for Business, Innovation and Skills"},
 "The Rt Hon Patrick McLoughlin MP" => {"Parliamentary Secretary to the Treasury and Chief Whip" => nil},
 "The Rt Hon Dominic Grieve QC MP" => {"Attorney General" => "Attornery General's Office"},
 "Edward Garnier QC MP" => {"Solicitor General" => "Attornery General's Office"},
 "John Hayes MP" => {"Minister of State (Further Education, Skills and Lifelong Learning)" => "Department for Business, Innovation and Skills"},
 "Mark Prisk MP" => {"Minister of State (Business and Enterprise)" => "Department for Business, Innovation and Skills"},
 "Edward Davey MP" => {"Parliamentary Under-Secretary of State (Employment Relations, Consumer and Postal Affairs)" => "Department for Business, Innovation and Skills"},
 "The Hon Ed Vaizey MP" => {"Parliamentary Under-Secretary of State (Culture, Communications and Creative Industries)" => "Department for Business, Innovation and Skills"},
 "Baroness Wilcox" => {"Parliamentary Under-Secretary of State (Business, Innovation and Skills)" => "Department for Business, Innovation and Skills"},
 "Mark Harper MP" => {"Parliamentary Secretary (Minister for Political and Constitutional Reform)" => "Cabinet Office"},
 "Nick Hurd MP" => {"Parliamentary Secretary (Minister for Civil Society)" => "Cabinet Office"},
 "The Rt Hon Greg Clark MP" => {"Minister of State (Decentralisation)" => "Department for Communities and Local Government"},
 "The Rt Hon Grant Shapps MP" => {"Minister of State" => "Department for Communities and Local Government"},
 "Andrew Stunell OBE MP" => {"Parliamentary Under-Secretary of State" => "Department for Communities and Local Government"},
 "Bob Neill MP" => {"Parliamentary Under-Secretary of State" => "Department for Communities and Local Government"},
 "Baroness Hanham CBE" => {"Parliamentary Under-Secretary of State" => "Department for Communities and Local Government"},
 "John Penrose MP" => {"Parliamentary Under-Secretary of State (Tourism and Heritage)" => "Department for Culture, Olympics, Media and Sport"},
 "Hugh Robertson MP" => {"Parliamentary Under-Secretary of State (Sport and Olympics)" => "Department for Culture, Olympics, Media and Sport"},
 "Nick Harvey MP" => {"Minister of State (Minister for the Armed Forces)" => "Ministry of Defence"},
 "Gerald Howarth MP" => {"Parliamentary Under-Secretary of State (International Security Strategy)" => "Ministry of Defence"},
 "Andrew Robathan MP" => {"Parliamentary Under-Secretary of State (Defence Personnel, Welfare and Veterans)" => "Ministry of Defence"},
 "Peter Luff MP" => {"Parliamentary Under-Secretary of State (Defence Equipment, Support and Technology)" => "Ministry of Defence"},
 "Lord Astor of Hever DL" => {"Parliamentary Under-Secretary of State" => "Ministry of Defence"},
 "Sarah Teather MP" => {"Minister of State (Children and Families)" => "Department for Education"},
 "Nick Gibb MP" => {"Minister of State (Schools)" => "Department for Education"},
 "Tim Loughton MP" => {"Parliamentary Under-Secretary of State (Children and Young Families)" => "Department for Education"},
 "Lord Hill of Oareford CBE" => {"Parliamentary Under-Secretary of State (Schools)" => "Department for Education"},
 "Gregory Barker MP" => {"Minister of State" => "Department for Energy and Climate Change"},
 "Charles Hendry MP" => {"Minister of State" => "Department for Energy and Climate Change"},
 "The Lord Marland" => {"Parliamentary Under-Secretary of State" => "Department for Energy and Climate Change"},
 "James Paice MP" => {"Minister of State (Agriculture and Food)" => "Department for Environment, Food and Rural Affairs"},
 "Richard Benyon MP" => {"Parliamentary Under-Secretary of State (Natural Environment and Fisheries)" => "Department for Environment, Food and Rural Affairs"},
 "Lord Henley" => {"Parliamentary Under Secretary of State" => "Department for Environment, Food and Rural Affairs"},
 "Jeremy Browne MP" => {"Minister of State" => "Foreign and Commonwealth Office"},
 "David Lidington MP" => {"Minister of State" => "Foreign and Commonwealth Office"},
 "The Rt Hon Lord Howell of Guildford" => {"Minister of State" => "Foreign and Commonwealth Office"},
 "Henry Bellingham MP" => {"Parliamentary Under-Secretary of State" => "Foreign and Commonwealth Office"},
 "Alistair Burt MP" => {"Parliamentary Under-Secretary of State" => "Foreign and Commonwealth Office"},
 "Lynne Featherstone MP" => {"Parliamentary Under-Secretary of State" => "Government Equalities Office"},
 "Paul Burstow MP" => {"Minister of State (Care Services)" => "Department of Health"},
 "Simon Burns MP" => {"Minister of State (Health)" => "Department of Health"},
 "Anne Milton MP" => {"Parliamentary Under-Secretary of State (Public Health)" => "Department of Health"},
 "Earl Howe" => {"Parliamentary Under-Secretary of State (Quality)" => "Department of Health"},
 "Damian Green MP" => {"Minister of State (Immigration)" => "Home Office"},
 "The Rt Hon Nick Herbert MP" => {"Minister of State (Policing and Criminal Justice)" => "Home Office"},
 "The Rt Hon Baroness Neville-Jones" => {"Minister of State (Security and Counter-Terrorism)" => "Home Office"},
 "James Brokenshire MP" => {"Parliamentary Under-Secretary of State (Crime Prevention)" => "Home Office"},
 "The Rt Hon Alan Duncan MP" => {"Minister of State" => "Department for International Development"},
 "Stephen O’Brien MP" => {"Parliamentary Under-Secretary of State" => "Department for International Development"},
 "The Rt Hon Lord McNally" => {"Minister of State" => "Ministry of Justice"},
 "Crispin Blunt MP" => {"Parliamentary Under-Secretary of State" => "Ministry of Justice"},
 "Jonathan Djanogly MP" => {"Parliamentary Under-Secretary of State" => "Ministry of Justice"},
 "Hugo Swire MP" => {"Minister of State" => "Northern Ireland Office"},
 "The Rt Hon The Lord Wallace of Tankerness QC" => {"HM Advocate General for Scotland" => "Office of the Advocate General for Scotland"},
 "The Rt Hon Sir George Young Bt MP" => {"Leader of the House of Commons and Lord Privy Seal" => "Office of the Leader of House of Commons and Lord Privy Seal"},
 "David Heath CBE MP" => {"Parliamentary Secretary (Deputy Leader of the House of Commons)" => "Office of the Leader of House of Commons and Lord Privy Seal"},
 "The Rt Hon David Mundell " => {"Parliamentary Under-Secretary of State" => "Scotland Office"},
 "The Rt Hon Theresa Villiers MP" => {"Minister of State" => "Department for Transport"},
 "Norman Baker MP" => {"Parliamentary Under-Secretary of State" => "Department for Transport"},
 "Mike Penning MP" => {"Parliamentary Under-Secretary of State" => "Department for Transport"},
 "Mark Hoban MP" => {"Financial Secretary to the Treasury" => "HM Treasury"},
 "David Gauke MP" => {"Exchequer Secretary to the Treasury" => "HM Treasury"},
 "Justine Greening MP" => {"Economic Secretary to the Treasury" => "HM Treasury"},
 "Lord Sassoon of Ashley Park" => {"Commercial Secretary to the Treasury" => "HM Treasury"},
 "David Jones MP" => {"Parliamentary Under-Secretary of State" => "Wales Office"},
 "The Rt Hon Chris Grayling MP" => {"Minister of State (Employment)" => "Department for Work and Pensions"},
 "Steve Webb MP" => {"Minister of State (Pensions)" => "Department for Work and Pensions"},
 "Maria Miller MP" => {"Parliamentary Under-Secretary of State (Minister for Disabled People)" => "Department for Work and Pensions"},
 "Lord Freud" => {"Parliamentary Under-Secretary of State (Welfare Reform)" => "Department for Work and Pensions"}})

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


# Randomly generated document-type data

def create_document(type, attributes)
  attributes[:topics] = Topic.where(name: (attributes[:topics] || []))
  attributes[:organisations] = Organisation.where(name: (attributes[:organisations] || []))
  attributes[:author] ||= User.create(name: Faker::Name.name)
  attributes[:roles] = Array.new(rand(2) + 1) { Role.order("RAND()").first }
  type.create!({
    title: "title-n",
    body: random_policy_text,
    document_identity: DocumentIdentity.new
  }.merge(attributes))
end

def create_draft(type, attributes = {})
  create_document(type, attributes)
end

def create_submitted(type, attributes = {})
  document = create_document(type, attributes.merge(submitted: true))
  document.fact_check_requests.create email_address: Faker::Internet.email, comments: Faker::Lorem.paragraph
  document
end

def create_published(type, attributes = {})
  create_document(type, attributes.merge(submitted: true, state: "published"))
end

def random_policy_text(number_of_paragraphs=3)
  @policy_data ||= File.read(File.expand_path("../seed_policy_bodies.txt", __FILE__)).split("\n")
  @policy_data.shuffle[0...number_of_paragraphs].join("\n\n")
end
alias :random_publication_text :random_policy_text


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

puts "...done." unless Rails.env.test?