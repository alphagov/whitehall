Given /^a specialist guide with section headings$/ do
  create(:published_specialist_guide,
         title: "Specialist guide with pages",
         summary: "Here's the summary of the guide",
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

When /^I view the guide$/ do
  visit "/specialist"
  click_link "Specialist guide with pages"
end

Then /^I should see only the first page of the guide$/ do
  assert page.find("h2#page-1").visible?
  refute page.find("h2#page-2").visible?
  refute page.find("h2#page-3").visible?
end

When /^I navigate to the second page$/ do
  click_link "Page 2"
end

Then /^I should see only the second page of the guide$/ do
  refute page.find("h2#page-1").visible?
  assert page.find("h2#page-2").visible?
  refute page.find("h2#page-3").visible?
end

When /^I view the first page$/ do
  visit "/specialist"
  click_link "Specialist guide with pages"
  click_link "Page 1"
end

Then /^I should see the guide summary$/ do
  assert page.find(".summary").visible?
end

Then /^I should not see the guide summary$/ do
  refute page.find(".summary").visible?
end

When /^I view a page with internal headings$/ do
  visit "/specialist"
  click_link "Specialist guide with pages"
  click_link "Page 2"
end

Then /^I should not see navigation for headings within other pages$/ do
  refute page.find("a[href='#page-2-section-1']").visible?
  refute page.find("a[href='#page-2-section-2']").visible?
end

Then /^I should see navigation for the headings within that page$/ do
  assert page.find("a[href='#page-2-section-1']").visible?
  assert page.find("a[href='#page-2-section-2']").visible?
end
