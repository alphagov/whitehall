require "csv"

def creator
  @creator ||= User.find_by_name!("Neil Williams")
end

def import_stub(stub)
  title = stub["What we're doing"].strip
  policy_area_names = stub["Policy areas"] ? stub["Policy areas"].split(";").map(&:strip) : []
  lead_org_name = stub["Lead org"].strip
  other_org_names = stub["Other orgs"] ? stub["Other orgs"].split(";").map(&:strip) : []
  url = stub["URL for info on current policies"].strip
  # ignore ministers as they are people's names, not roles

  policy_areas = PolicyArea.where("name IN (?)", policy_area_names)
  lead_org = Organisation.find_by_name(lead_org_name) || Organisation.find_by_acronym(lead_org_name)
  raise "Couldn't find lead org #{lead_org_name.inspect}" unless lead_org.present?
  orgs = Organisation.where("name IN (?)", other_org_names)

  body = %{## Sample content

This policy definition is a sample only, to give a flavour of what GOV.UK might look like if it contained a full list of government policies from all central departments. The title has been adapted from the text of the #{lead_org.name} business plan, published May 2011, and may therefore be out of date.

For accurate, reliable and up to date information on this policy, visit the #{lead_org.name} website at [#{url}](#{url})}

  attributes = {
    title: title, policy_areas: policy_areas, organisations: [lead_org, *orgs], 
    ministerial_roles: lead_org.ministerial_roles, body: body,
    creator: creator
  }

  puts "importing #{title.inspect}"
  policy = Policy.stub.create!(attributes)
  policy.publish_as(creator, force: true)
end

stubs = CSV.read(Rails.root + "db/policy_stubs.csv", headers: true)
stubs.each do |stub|
  begin
    import_stub(stub)
  rescue => e
    puts "failed to import: #{stub.inspect}"
    puts e
    exit(-1)
  end
end