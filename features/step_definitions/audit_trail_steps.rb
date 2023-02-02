Given(/^a document that has gone through many changes$/) do
  begin_drafting_publication("An frequently changed publication")
  click_button "Save and continue"
  expect(page).to have_content("An frequently changed publication")
  @the_publication = Publication.find_by(title: "An frequently changed publication")
  # fake it
  states = %w[draft submitted published]
  50.times do |i|
    Timecop.travel i.hours.from_now do
      @the_publication.versions.create event: "update", whodunnit: @user, state: states.sample
    end
  end
end

When(/^I visit the document to see the audit trail$/) do
  visit edit_admin_publication_path(@the_publication)
end

Then(/^I can traverse the audit trail with newer and older navigation$/) do
  click_on "History"
  within "#history" do
    expect(page).to have_selector(".version", count: 30)
    expect(page).to_not have_link("<< Newer")
    find(".audit-trail-nav", match: :first).click_link("Older >>")
  end
  within "#history" do
    # there are 51 versions (1 real via create 50 fake from step above)
    expect(page).to have_selector(".version", count: 21)
    expect(page).to_not have_link("Older >>")
    find(".audit-trail-nav", match: :first).click_link("<< Newer")
  end
  within "#history" do
    expect(page).to have_selector(".version", count: 30)
  end
end
