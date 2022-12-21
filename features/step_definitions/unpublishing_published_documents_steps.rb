Given(/^a published document exists with a slug that does not match the title$/) do
  @document = create(:published_publication, title: "Some Publication")
  @original_slug = @document.slug
  @document.title = "Published in error"
  @document.save!(validate: false)
end

Given(/^there is a published document that is a duplicate of another page$/) do
  @existing_edition = create(:published_publication, title: "An existing edition")
  @duplicate_edition = create(:published_publication, title: "A duplicate edition")
end

When(/^I unpublish the duplicate, marking it as consolidated into the other page$/) do
  visit admin_edition_path(@duplicate_edition)
  click_on "Withdraw or unpublish"
  choose "Unpublish: consolidated into another GOV.UK page"
  within ".js-unpublish-withdraw-form__consolidated" do
    fill_in "consolidated_alternative_url", with: @existing_edition.public_url
    click_button "Unpublish"
  end
end

def withdraw_publication(explanation)
  @publication = Publication.last
  visit admin_edition_path(@publication)
  click_on "Withdraw or unpublish"
  choose "Withdraw: no longer current government policy/activity"
  within ".js-unpublish-withdraw-form__withdrawal" do
    fill_in "Public explanation", with: explanation
    click_button "Withdraw"
  end

  expect(:withdrawn).to eq(@publication.reload.current_state)
end

When(/^I withdraw the publication with the explanation "([^"]*)"$/) do |explanation|
  withdraw_publication(explanation)
end

Given(/^the publication was withdrawn on ([\d\/]+) with the explanation "([^"]*)"$/) do |date, explanation|
  Timecop.travel date.to_date do
    withdraw_publication(explanation)
  end
end

When("I go to withdraw the publication again") do
  @publication = Publication.last
  visit admin_edition_path(@publication)
  click_on "Withdraw or unpublish"
  choose "Withdraw: no longer current government policy/activity"
end

When(/^I choose to reuse the withdrawal from ([\d\/]+)$/) do |date|
  date_formatted = date.to_date.to_fs(:long_ordinal)
  choose date_formatted
  click_button "Withdraw"

  expect(:withdrawn).to eq(@publication.reload.current_state)
end

When(/^I edit the public explanation for withdrawal to "([^"]*)"$/) do |explanation|
  publication = Publication.last
  visit admin_edition_path(publication)
  click_on "Edit withdrawal explanation"
  fill_in "Public explanation", with: explanation
  click_button "Update withdrawal explanation"
end

Then(/^the unpublishing should redirect to the existing edition$/) do
  unpublishing = @duplicate_edition.unpublishing
  path = @existing_edition.public_path
  expect(unpublishing.alternative_url.end_with?(path)).to be(true)
end

When(/^I unpublish the document because it was published in error$/) do
  unpublish_edition(Edition.last)
end

Then(/^there should be an editorial remark recording the fact that the document was unpublished$/) do
  edition = Edition.last
  expect("Reset to draft").to eq(edition.editorial_remarks.last.body)
end

Then(/^there should be an editorial remark recording the fact that the document was withdrawn$/) do
  edition = Edition.last
  expect("Withdrawn").to eq(edition.editorial_remarks.last.body)
end

Then(/^there should be an unpublishing explanation of "([^"]*)" and a reason of "([^"]*)"$/) do |explanation, reason_name|
  edition = Edition.last
  unpublishing = edition.unpublishing

  expect(unpublishing.present?).to be(true)

  reason = unpublishing.unpublishing_reason

  expect(explanation).to eq(unpublishing.explanation)
  expect(reason_name).to eq(reason.name)
end

Then(/^the withdrawal date should be (today|[\d\/]+)$/) do |date|
  edition = Edition.last
  unpublishing = edition.unpublishing

  date = if date == "today"
           Time.zone.today
         else
           Time.zone.parse(date).to_date
         end

  expect(unpublishing.unpublished_at.to_date).to eq(date)
end

When(/^I unpublish the document and ask for a redirect to "([^"]*)"$/) do |url|
  unpublish_edition(Edition.last) do
    fill_in "published_in_error_alternative_url", with: url
    check "Redirect to URL automatically?"
  end
end

Then(/^the unpublishing should redirect to "([^"]*)"$/) do |url|
  edition = Edition.last

  unpublishing = edition.unpublishing

  expect(unpublishing.redirect).to be(true)
  expect(url).to eq(unpublishing.alternative_url)
end

Then(/^I should not be able to discard the draft resulting from the unpublishing$/) do
  visit admin_edition_path(Edition.last)

  expect(page).not_to have_button("Discard draft")
end
