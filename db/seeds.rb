# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def random_policy_text(number_of_paragraphs=3)
  @policy_data ||= File.read(File.expand_path("../seed_policy_bodies.txt", __FILE__)).split("\n")
  @policy_data.shuffle[0...number_of_paragraphs].join("\n\n")
end

["Regulation reform",
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
"Big Society"].each do |topic_name|
  Topic.create!(name: topic_name)
end

higher_education = Topic.find_by_name("Higher education")
consular_services = Topic.find_by_name("Consular Services")
fire_and_emergencies = Topic.find_by_name("Fire and emergencies")

alice = User.create!(name: "Alice Anderson")
bob = User.create!(name: "Bob Bailey")
clive = User.create!(name: "Clive Custer")

# Draft policies
alice.editions.create! title: "Free cats for pensioners", body: random_policy_text, submitted: false, document: Policy.new, topics: [higher_education]
bob.editions.create! title: "Decriminalise beards", body: random_policy_text(5), submitted: false, document: Policy.new, topics: [higher_education, consular_services]

# Submitted policies
alice.editions.create! title: "Less gravity on Sundays", body: random_policy_text, submitted: true, document: Policy.new, topics: [consular_services]
clive.editions.create! title: "Ducks pulling chariots of fire", body: random_policy_text(4), submitted: true, document: Policy.new, topics: [consular_services, fire_and_emergencies]

# Published policies
clive.editions.create! title: "No more supernanny", body: random_policy_text, state: 'published', document: Policy.new, topics: [higher_education, consular_services, fire_and_emergencies]
alice.editions.create! title: "Laser eyes for millionaires", body: random_policy_text, state: 'published', document: Policy.new, topics: [higher_education, fire_and_emergencies]