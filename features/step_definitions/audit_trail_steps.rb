Given /^a document that has gone through many changes$/ do
  begin_drafting_publication('An exciting new publication')
  click_on "Save"
  assert page.has_content?('An exciting new publication')
  @the_publication = Publication.find_by_title('An exciting new publication')
  # fake it
  states = ['draft', 'submitted', 'published', 'archived']
  50.times do |i|
    Timecop.travel i.hours.from_now do
      @the_publication.versions.create event: 'update', whodunnit: @user, state: states.sample
    end
  end
end

When /^I visit the document to see the audit trail$/ do
  visit admin_publication_path(@the_publication)
end

Then /^I can traverse the audit trail with newer and older navigation$/ do
  click_on 'History'
  within '#history' do
    assert page.has_css?('.version', count: 30)
    refute page.has_link? '<< Newer'
    find('.audit-trail-nav', match: :first).click_link('Older >>')
  end
  within '#history' do
    # there are 51 versions (1 real via create 50 fake from step above)
    assert page.has_css?('.version', count: 21)
    refute page.has_link? 'Older >>'
    find('.audit-trail-nav', match: :first).click_link('<< Newer')
  end
  within '#history' do
    assert page.has_css?('.version', count: 30)
  end
end
