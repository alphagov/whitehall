Given /^ministers exist:$/ do |table|
  table.hashes.each do |row|
    person = Person.find_or_create_by_name(row["Person"])
    person.ministerial_roles.find_or_create_by_name(row["Ministerial Role"])
  end
end

When /^I visit the minister page for "([^"]*)"$/ do |name|
  visit "/"
  click_link "Ministers"
  click_link name
end

Then /^I should see that the minister is responsible for the documents:$/ do |table|
  table.raw.each do |(document_title)|
    document = Document.find_by_title(document_title)
    assert page.has_css?(record_css_selector(document), text: document.title), "document '#{document.title}' wasn't there"
  end
end