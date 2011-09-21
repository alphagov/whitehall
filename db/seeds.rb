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

alice = User.create!(name: "Alice Anderson")
bob = User.create!(name: "Bob Bailey")
clive = User.create!(name: "Clive Custer")

alice.policies.create! title: "Free cats for pensioners", body: random_policy_text, submitted: false
bob.policies.create! title: "Decriminalise beards", body: random_policy_text(5), submitted: false
alice.policies.create! title: "Less gravity on Sundays", body: random_policy_text, submitted: true
clive.policies.create! title: "Ducks pulling chariots of fire", body: random_policy_text(4), submitted: true