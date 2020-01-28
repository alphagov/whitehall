Given(/^a document that has gone through many changes$/) do
  begin_drafting_publication('An frequently changed publication')
  click_on "Save and continue"
  assert_text 'An frequently changed publication'
  @the_publication = Publication.find_by(title: 'An frequently changed publication')
  # fake it
  states = %w[draft submitted published]
  50.times do |i|
    Timecop.travel i.hours.from_now do
      @the_publication.versions.create event: 'update', whodunnit: @user, state: states.sample
    end
  end
end

When(/^I visit the document to see the audit trail$/) do
  visit admin_publication_path(@the_publication)
end

Then(/^I can traverse the audit trail with newer and older navigation$/) do
  click_on 'History'
  within '#history' do
    assert_selector '.version', count: 30
    assert has_no_link?('<< Newer')
    find('.audit-trail-nav', match: :first).click_link('Older >>')
  end
  within '#history' do
    # there are 51 versions (1 real via create 50 fake from step above)
    assert_selector '.version', count: 21
    assert has_no_link?('Older >>')
    find('.audit-trail-nav', match: :first).click_link('<< Newer')
  end
  within '#history' do
    assert_selector '.version', count: 30
  end
end
