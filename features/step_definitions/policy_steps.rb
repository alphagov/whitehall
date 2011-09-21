Given /^"([^"]*)" submitted "([^"]*)" with body "([^"]*)"$/ do |author, title, body|
  Given %{I am logged in as "#{author}"}
  And %{I visit the new policy page}
  And %{I write and save a policy called "#{title}" with body "#{body}"}
end