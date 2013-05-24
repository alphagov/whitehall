When /^I draft and then publish a new document$/ do
  begin_drafting_publication('An exciting new publication')
  click_on "Save"
  click_on 'Force Publish'
  @the_publication = Publication.find_by_title('An exciting new publication')
end

Then /^I should see an audit trail describing my publishing activity on the publication$/ do
  visit admin_publication_path(@the_publication)

  within '#history' do
    assert page.has_css?('.version', text: 'Published by '+@user.name)
    assert page.has_css?('.version', text: 'Created by '+@user.name)
  end
end

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
  within '#history' do
    assert page.has_css?('.version', count: 30)
    refute page.has_link? '<< Newer'
    click_on 'Older >>'
  end
  within '#history' do
    # there are 51 versions (1 real via create 50 fake from step above)
    assert page.has_css?('.version', count: 21)
    refute page.has_link? 'Older >>'
    click_on '<< Newer'
  end
  within '#history' do
    assert page.has_css?('.version', count: 30)
  end
end
