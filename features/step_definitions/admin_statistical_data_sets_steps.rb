Then(/^the publication should reference the "([^"]*)" data set$/) do |data_set_name|
  @new_edition = Publication.last

  data_sets = @new_edition.statistical_data_sets

  assert_equal 1, data_sets.count
  assert_equal data_set_name, data_sets.first.title
end
