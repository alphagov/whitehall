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

  body = %{This policy originates from the #{lead_org.name} business plan.\n\nMore details can be found at [#{url}](#{url}).}

  attributes = {
    title: title, policy_areas: policy_areas, organisations: [lead_org, *orgs], 
    ministerial_roles: lead_org.ministerial_roles, body: body,
    creator: creator
  }

  puts "importing #{title.inspect}"
  policy = Policy.stub.create!(attributes)
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