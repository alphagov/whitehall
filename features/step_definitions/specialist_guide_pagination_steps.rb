Given /^a specialist guide with section headings$/ do
  create(:published_specialist_guide,
         title: "Specialist guide with pages",
         summary: "Here's the summary of the guide",
         topics: [create(:topic)],
         body: <<-EOS
## Page 1

Here's the content for page one

## Page 2

Here's some content for page two

### Page 2, Section 1

A subsection! Well I never.

### Page 2, Section 2

And another! How rare.

## Page 3

You were expecting something a bit more tabloid? Shame on you.
EOS
)
end

When /^I view the specialist guide$/ do
  visit "/specialist"
  click_link "Specialist guide with pages"
end

Then /^I should see all pages of the specialist guide$/ do
  {
    first: 'page-1',
    second: 'page-2',
    third: 'page-3'
  }.each do |page_name, page_id|
    assert page.find("h2##{page_id}").visible?, "Element h2##{page_id} is not visible"
  end
end

