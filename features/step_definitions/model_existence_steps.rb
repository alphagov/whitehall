Given /^a published policy exists$/ do
  @edition = FactoryGirl.create(:published_edition)
end

Given /^a draft policy exists$/ do
  @edition = FactoryGirl.create(:draft_edition)
end