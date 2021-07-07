Then(/^the publication should reference the "([^"]*)" data set$/) do |data_set_name|
  @new_edition = Publication.last

  data_sets = @new_edition.statistical_data_sets

  expect(data_sets.count).to eq(1)
  expect(data_set_name).to eq(data_sets.first.title)
end
