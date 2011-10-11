Given /^ministers exist:$/ do |table|
  table.hashes.each do |row|
    person = Person.find_or_create_by_name(row["Person"])
    person.roles.find_or_create_by_name(row["Role"])
  end
end