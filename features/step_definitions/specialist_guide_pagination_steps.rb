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

Then /^I should see only the first page of the specialist guide$/ do
  assert page.find("h2#page-1").visible?
  refute page.find("h2#page-2").visible?
  refute page.find("h2#page-3").visible?
end

When /^I navigate to the second page of the specialist guide$/ do
  click_link "Page 2"
end

Then /^I should see only the second page of the specialist guide$/ do
  refute page.find("h2#page-1").visible?
  assert page.find("h2#page-2").visible?
  refute page.find("h2#page-3").visible?
end

When /^I view the first page of the specialist guide$/ do
  visit "/specialist"
  click_link "Specialist guide with pages"
  click_link "Page 1"
end

Then /^I should see the specialist guide summary$/ do
  assert page.find(".summary").visible?
end

Then /^I should not see the specialist guide summary$/ do
  refute page.find(".summary").visible?
end

When /^I view a specialist guide page with internal headings$/ do
  visit "/specialist"
  click_link "Specialist guide with pages"
  click_link "Page 2"
end

Then /^I should not see navigation for headings within other specialist guide pages$/ do
  refute page.find("a[href$='#page-2-section-1']").visible?
  refute page.find("a[href$='#page-2-section-2']").visible?
end

Then /^I should see navigation for the headings within that specialist guide page$/ do
  assert page.find("a[href$='#page-2-section-1']").visible?
  assert page.find("a[href$='#page-2-section-2']").visible?
end

Then /^I should see the URL fragment for the second page of the specialist guide in my browser address bar$/ do
  assert_equal "page-2", URI.parse(evaluate_script("window.document.location.href")).fragment
end

When /^I navigate to a heading within the specialist guide page$/ do
  click_link "Page 2, Section 2"
end

Then /^I should see the URL fragment for the specialist guide heading in my browser address bar$/ do
  assert_equal "page-2-section-2", URI.parse(evaluate_script("window.document.location.href")).fragment
end

When /^I visit the URL for the second page of the specialist guide$/ do
  specialist_guide = SpecialistGuide.find_by_title!("Specialist guide with pages")
  visit specialist_guide_path(specialist_guide.document, anchor: "page-2")
end

When /^I visit the URL for a heading within the second page of the specialist guide$/ do
  specialist_guide = SpecialistGuide.find_by_title!("Specialist guide with pages")
  visit specialist_guide_path(specialist_guide.document, anchor: "page-2-section-2")
end
