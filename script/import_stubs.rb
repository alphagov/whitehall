require "csv"

def creator
  @creator ||= User.find_by_name!("Neil Williams")
end

def import_stub(stub)
  title = stub["What we're doing"].strip
  topic_names = stub["Topics"] ? stub["Topics"].split(";").map(&:strip) : []
  lead_org_name = stub["Lead org"].strip
  other_org_names = stub["Other orgs"] ? stub["Other orgs"].split(";").map(&:strip) : []
  url = stub["URL for info on current policies"].strip
  people_names = stub["Ministers"] ? stub["Ministers"].split(";").map(&:strip) : []

  topics = Topic.where("name IN (?)", topic_names)
  lead_org = Organisation.find_by_name(lead_org_name) || Organisation.find_by_acronym(lead_org_name)
  raise "Couldn't find lead org #{lead_org_name.inspect}" unless lead_org.present?
  orgs = Organisation.where("name IN (?)", other_org_names)
  people = Person.where("CONCAT_WS(' ', forename, surname) IN (:names) OR CONCAT_WS(' ', title, surname) IN (:names)", names: people_names)
  raise "Couldn't find all people in #{people_names.inspect} (found: #{people.map(&:name).inspect})" unless people.length == people_names.length
  ministerial_roles = people.map(&:ministerial_roles).flatten

  body = %{## Sample content

This policy definition is a sample only, to give a flavour of what GOV.UK might look like if it contained a full list of government policies from all central departments. The title has been adapted from the text of the #{lead_org.name} business plan, published May 2011, and may therefore be out of date.

For accurate, reliable and up to date information on this policy, visit the #{lead_org.name} website at [#{url}](#{url})}

  backdate = 3.months.ago

  attributes = {
    title: title, topics: topics, organisations: [lead_org, *orgs],
    ministerial_roles: ministerial_roles, body: body,
    creator: creator,
    created_at: backdate, updated_at: backdate
  }

  puts "importing #{title.inspect}"
  policy = Policy.stub.create!(attributes)
  policy.publish_as(creator, force: true)
  policy.update_column(:major_change_published_at, backdate)
  policy.update_column(:updated_at, backdate)
end

stubs = CSV.parse(File.open(Rails.root + "db/policy_stubs.csv", "r:UTF-8"), headers: true)
stubs.each do |stub|
  begin
    import_stub(stub)
  rescue => e
    puts "failed to import: #{stub.inspect}"
    puts e
    exit(-1)
  end
end
