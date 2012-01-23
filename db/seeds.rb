# encoding: utf-8
["England", "Scotland", "Wales", "Northern Ireland"].each do |nation_name|
  Nation.find_or_create_by_name(nation_name)
end

["Ministerial Department", "Non-ministerial department"].each do |name|
  OrganisationType.find_or_create_by_name(name: name)
end

def organisations(*names)
  organisation_type_ids = OrganisationType.all.map(&:id)
  names.each do |name|
    Organisation.find_or_create_by_name(name: name, organisation_type_id: organisation_type_ids.shuffle.first)
  end
end

def countries(*names)
  names.each do |name|
    Country.find_or_create_by_name(name: name)
  end
end

def policy_areas(*names)
  names.each do |name|
    PolicyArea.create!(name: name, description: "A description of the #{name} policy_area goes here.")
  end
end

NAME_PATTERN = /^
  (
    .*                                                            # title prefix (e.g. "The")
    \b(?:Baroness|Dame|Dr|Earl|General|Hon|Lord|Professor|Sir)\b  # title
  )?
  \s*
  (.+?)                                                           # personal name
  \s*
  ((?:(?:[[:upper:]]+|Bt)\s*)*)                                   # letters ("Bt" means "Baronet")
$/x

def split_person_name(name)
  if match = NAME_PATTERN.match(name)
    title, personal_name, letters = match.captures

    personal_names = personal_name.split(/\s+/)
    forename = personal_names.shift unless personal_names.one? || personal_names.second == 'of'
    surname = personal_names.join(' ')

    { title: title, forename: forename, surname: surname, letters: letters }
  else
    raise "couldn't split \"#{name}\""
  end
end

def politicians(person_to_role_to_organisation)
  person_to_role_to_organisation.each do |person_name, role_to_organisation|
    name_parts = split_person_name(person_name)
    privy = name_parts[:title] == "The Rt Hon"
    person = Person.create!(name_parts.merge(privy_councillor: privy))
    role_to_organisation.each do |role_name, organisation_name|
      if organisation_name
        organisation = Organisation.find_by_name!(organisation_name)
        role = organisation.ministerial_roles.create!(name: role_name)
      else
        role = MinisterialRole.create!(name: role_name)
      end
      RoleAppointment.create!(role: role, person: person, started_at: 2.years.ago)
    end
  end
end

def civil_servants(person_to_role_to_organisation, permanent_secretary = false)
  person_to_role_to_organisation.each do |person_name, role_to_organisation|
    name_parts = split_person_name(person_name)
    privy = name_parts[:title] == "The Rt Hon"
    person = Person.create!(name_parts.merge(privy_councillor: privy))
    role_to_organisation.each do |role_name, organisation_name|
      if organisation_name
        organisation = Organisation.find_by_name!(organisation_name)
        role = organisation.board_member_roles.create!(name: role_name, permanent_secretary: permanent_secretary)
      else
        role = BoardMemberRole.create!(name: role_name, permanent_secretary: permanent_secretary)
      end
      RoleAppointment.create!(role: role, person: person, started_at: 2.years.ago)
    end
  end
end

def permanent_secretary_civil_servants(person_to_role_to_organisation)
  civil_servants(person_to_role_to_organisation, true)
end

def other_civil_servants(person_to_role_to_organisation)
  civil_servants(person_to_role_to_organisation, false)
end

countries(
  "Afganistan",
  "Albania",
  "Algeria",
  "Angola",
  "Anguilla",
  "Argentina",
  "Armenia",
  "Australia",
  "Austria",
  "Azerbaijan",
  "Bahrain",
  "Bangladesh",
  "Barbados",
  "Belarus",
  "Belgium",
  "Belize",
  "Bolivia",
  "Bosnia and Herzegovina",
  "Botswana",
  "Brazil",
  "British Antarctic Territory",
  "British Virgin Islands",
  "Brunei",
  "Bulgaria",
  "Burma",
  "Cambodia",
  "Cameroon",
  "Canada",
  "Cayman Islands",
  "Chile",
  "China",
  "Colombia",
  "Costa Rica",
  "Croatia",
  "Cuba",
  "Cyprus",
  "Czech Republic",
  "Democratic Republic of Congo",
  "Denmark",
  "Dominican Republic",
  "Ecuador",
  "Egypt",
  "Eritrea",
  "Estonia",
  "Ethiopia",
  "Fiji",
  "Finland",
  "France",
  "Gambia",
  "Georgia",
  "Germany",
  "Ghana",
  "Greece",
  "Guatemala",
  "Guyana",
  "Holy See",
  "Honduras",
  "Hong Kong",
  "Hungary",
  "Iceland",
  "India",
  "Indonesia",
  "Iran",
  "Iraq",
  "Ireland",
  "Israel",
  "Italy",
  "Jamaica",
  "Japan",
  "Jerusalem",
  "Jordan",
  "Kazakhstan",
  "Kenya",
  "Kosovo",
  "Kuwait",
  "Laos",
  "Latvia",
  "Lebanon",
  "Libya",
  "Lithuania",
  "Luxembourg",
  "Macedonia",
  "Madagascar",
  "Malawi",
  "Malaysia",
  "Maldives",
  "Mali",
  "Malta",
  "Mauritius",
  "Mexico",
  "Moldova",
  "Mongolia",
  "Montenegro",
  "Montserrat",
  "Morocco",
  "Mozambique",
  "Namibia",
  "Nepal",
  "Netherlands",
  "New Zealand",
  "Nigeria",
  "North Korea",
  "Norway",
  "Oman",
  "Pakistan",
  "Panama",
  "Papua New Guinea",
  "Peru",
  "Philippines",
  "Poland",
  "Portugal",
  "Qatar",
  "Romania",
  "Russia",
  "Rwanda",
  "Saudi Arabia",
  "Senegal",
  "Serbia",
  "Seychelles",
  "Sierra Leone",
  "Singapore",
  "Slovakia",
  "Slovenia",
  "Solomon Islands",
  "Somalia",
  "South Africa",
  "South Korea",
  "South Sudan",
  "Spain",
  "Sri Lanka",
  "Sudan",
  "Sweden",
  "Switzerland",
  "Syria",
  "Taiwan",
  "Tajikistan",
  "Tanzania",
  "Thailand",
  "Timor Leste",
  "Trinidad and Tobago",
  "Tunisia",
  "Turkey",
  "Turkmenistan",
  "Turks and Caicos Islands",
  "Uganda",
  "UK Delegation to Council of Europe",
  "UK Delegation to Organization for Security and Co-operation in Europe",
  "UK Delegation to the OECD",
  "UK Joint Delegation to NATO",
  "UK Mission to the UN Geneva",
  "UK Mission to the United Nations",
  "UK Representation to the EU",
  "UK Representation to the UN Conference on Disarmament in Geneva",
  "Ukraine",
  "United Arab Emirates",
  "Uruguay",
  "USA",
  "Uzbekistan",
  "Venezuela",
  "Vietnam",
  "Yemen",
  "Zambia",
  "Zimbabwe"
)

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
  "Department for Energy and Climate Change",
  "Department of Health",
  "Foreign and Commonwealth Office",
  "Government Equalities Office",
  "Her Majesty's Revenue and Customs",
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

politicians({"The Rt Hon David Cameron" => {"Prime Minister" => "Cabinet Office"},
 "The Rt Hon Nick Clegg MP" => {"Deputy Prime Minister" => "Cabinet Office"},
 "The Rt Hon William Hague MP" => {"First Secretary of State" => "Foreign and Commonwealth Office"},
 "The Rt Hon George Osborne MP" => {"Chancellor of the Exchequer" => "Her Majesty's Treasury"},
 "The Rt Hon Kenneth Clarke QC MP" => {"Secretary of State for Justice" => "Ministry of Justice"},
 "The Rt Hon Theresa May MP" => {"Secretary of State for the Home Department" => "Home Office", "Minister for Women and Equalities" => "Government Equalities Office"},
 "The Rt Hon Philip Hammond MP" => {"Secretary of State for Defence" => nil},
 "The Rt Hon Dr Vincent Cable MP" => {"Secretary of State for Business, Innovation and Skills" => "Department for Business, Innovation and Skills"},
 "The Rt Hon Iain Duncan Smith MP" => {"Secretary of State for Work and Pensions" => "Department for Work and Pensions"},
 "The Rt Hon Chris Huhne MP" => {"Secretary of State for Energy and Climate Change" => "Department for Energy and Climate Change"},
 "The Rt Hon Andrew Lansley CBE MP" => {"Secretary of State for Health" => "Department of Health"},
 "The Rt Hon Michael Gove MP" => {"Secretary of State for Education" => "Department for Education"},
 "The Rt Hon Eric Pickles MP" => {"Secretary of State for Communities and Local Government" => "Department for Communities and Local Government"},
 "Justine Greening MP" => {"Secretary of State for Transport" => "Department for Transport"},
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
 "The Rt Hon Dominic Grieve QC MP" => {"Attorney General" => "Attorney General's Office"},
 "Edward Garnier QC MP" => {"Solicitor General" => "Attorney General's Office"},
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
 "John Penrose MP" => {"Parliamentary Under-Secretary of State (Tourism and Heritage)" => "Department for Culture, Media and Sport"},
 "Hugh Robertson MP" => {"Parliamentary Under-Secretary of State (Sport and Olympics)" => "Department for Culture, Media and Sport"},
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
 "The Rt Hon Sir George Young Bt MP" => {"Leader of the House of Commons and Lord Privy Seal" => "Office of the Leader of the House of Commons"},
 "David Heath CBE MP" => {"Parliamentary Secretary (Deputy Leader of the House of Commons)" => "Office of the Leader of the House of Commons"},
 "The Rt Hon David Mundell " => {"Parliamentary Under-Secretary of State" => "Scotland Office"},
 "The Rt Hon Theresa Villiers MP" => {"Minister of State" => "Department for Transport"},
 "Norman Baker MP" => {"Parliamentary Under-Secretary of State" => "Department for Transport"},
 "Mike Penning MP" => {"Parliamentary Under-Secretary of State" => "Department for Transport"},
 "Mark Hoban MP" => {"Financial Secretary to the Treasury" => "Her Majesty's Treasury"},
 "David Gauke MP" => {"Exchequer Secretary to the Treasury" => "Her Majesty's Treasury"},
 "Chloe Smith MP" => {"Economic Secretary to the Treasury" => "Her Majesty's Treasury"},
 "Lord Sassoon of Ashley Park" => {"Commercial Secretary to the Treasury" => "Her Majesty's Treasury"},
 "David Jones MP" => {"Parliamentary Under-Secretary of State" => "Wales Office"},
 "The Rt Hon Chris Grayling MP" => {"Minister of State (Employment)" => "Department for Work and Pensions"},
 "Steve Webb MP" => {"Minister of State (Pensions)" => "Department for Work and Pensions"},
 "Maria Miller MP" => {"Parliamentary Under-Secretary of State (Minister for Disabled People)" => "Department for Work and Pensions"},
 "Lord Freud" => {"Parliamentary Under-Secretary of State (Welfare Reform)" => "Department for Work and Pensions"}})

permanent_secretary_civil_servants(
  "Alex Allan" => {"Permanent Secretary (Intelligence)" => "Cabinet Office"},
  "Jeremy Heywood" => {"Permanent Secretary (10 Downing Street)" => "Cabinet Office"},
  "Sir Gus O’Donnell" => {"Cabinet Secretary and Head of the Home Civil Service" => "Cabinet Office"},
  "Ian Watmore" => {"Permanent Secretary (Efficiency & Reform)" => "Cabinet Office"},
  "Sir Jon Cunliffe" => {"Permanent Secretary (International Economic Affairs and Europe)" => "Cabinet Office"},
  "Sir Peter Ricketts" => {"Permanent Secretary (Security)" => "Cabinet Office"},
  "Martin Donnelly" => {"Permanent Secretary" => "Department for Business, Innovation and Skills"},
  "Sir Bob Kerslake" => {"Permanent Secretary" => "Department for Communities and Local Government"},
  "Jonathan Stephens" => {"Permanent Secretary" => "Department for Culture, Media and Sport"},
  "David Bell" => {"Permanent Secretary" => "Department for Education"},
  "Bronwyn Hill" => {"Permanent Secretary" => "Department for Environment, Food and Rural Affairs"},
  "Mark Lowcock" => {"Permanent Secretary" => "Department for International Development"},
  "Lin Homer" => {"Permanent Secretary" => "Department for Transport"},
  "Robert Devereux" => {"Permanent Secretary" => "Department for Work and Pensions"},
  "Darra Singh" => {"Chief Executive of Jobcentre Plus" => "Department for Work and Pensions"},
  "Moira Wallace" => {"Permanent Secretary" => "Department for Energy and Climate Change"},
  "Una O’Brien" => {"Permanent Secretary" => "Department of Health"},
  "Professor Dame Sally Davies" => {"Chief Medical Officer" => "Department of Health"},
  "Sir David Nicholson" => {"NHS Chief Executive" => "Department of Health"},
  "Simon Fraser" => {"Permanent Secretary" => "Foreign and Commonwealth Office"},
  "Sir Nicholas Macpherson" => {"Permanent Secretary" => "Her Majesty's Treasury"},
  "Dame Helen Ghosh" => {"Permanent Secretary" => "Home Office"},
  "Ursula Brennan" => {"Permanent Secretary" => "Ministry of Defence"},
  "Bernard Gray" => {"Permanent Secretary" => "Ministry of Defence"},
  "Professor Mark Welland" => {"Permanent Secretary" => "Ministry of Defence"},
  "Jon Day" => {"Permanent Secretary" => "Ministry of Defence"},
  "Sir Suma Chakrabarti" => {"Permanent Secretary" => "Ministry of Justice"},
  "Dame Lesley Strathie" => {"Permanent Secretary" => "Her Majesty's Revenue and Customs"}
)

other_civil_servants(
  "Tom Scholar" => {"Second Permanent Secretary" => "Her Majesty's Treasury"},
  "Bernard Gray" => {"Chief of Defence Material" => "Ministry of Defence"},
  "Professor Mark Welland" => {"Chief Scientific Adviser" => "Ministry of Defence"},
  "Jon Day" => {"Second Permanent Secretary" => "Ministry of Defence"},
  "Tera Allas" => {"Director General (Economics, Strategy and Better Regulation)" => "Department for Business, Innovation and Skills"},
  "Nick Baird" => {"Chief Executive (UK Trade & Investment)" => "Department for Business, Innovation and Skills"},
  "Bernadette Kelly" => {"Director General (Market Frameworks)" => "Department for Business, Innovation and Skills"},
  "Stephen Lovegrove" => {"Chief Executive (Shareholder Executive)" => "Department for Business, Innovation and Skills"},
  "Howard Orme" => {"Director General (Finance and Commercial)" => "Department for Business, Innovation and Skills"},
  "Philip Rutnam" => {"Director General (Business and Skills)" => "Department for Business, Innovation and Skills"},
  "Rachel Sandby-Thomas" => {"The Solicitor and Director General Legal, People and Communications" => "Department for Business, Innovation and Skills"},
  "Sir Adrian Smith" => {"Director General (Knowledge and Innovation)" => "Department for Business, Innovation and Skills"})

policy_areas(
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

if Rails.env.development? || Rails.env.test?
  require Rails.root.join("db/random_seeds.rb")
end
