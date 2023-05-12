Given(/^a published statistical data set "([^"]*)"$/) do |data_set_title|
  create(:published_statistical_data_set, title: data_set_title)
end
