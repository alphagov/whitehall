Given /^a published policy exists$/ do
  @edition = create(:published_edition)
end

Given /^a draft policy exists$/ do
  @edition = create(:draft_edition)
end