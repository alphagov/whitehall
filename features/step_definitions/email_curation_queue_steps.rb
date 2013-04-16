When /^a policy relevant to local government is published$/ do
  begin_drafting_policy title: 'A local policy, for local people'
  fill_in_change_note_if_required
  check "Relevant to local government"
  click_on 'Save'
  publish(force: true)
  @the_local_government_edition = Policy.published.last
end

Then /^the policy is listed at the top of the email curation queue$/ do
  visit admin_email_curation_queue_items_path

  within '#email_curation_queue_items' do
    assert page.has_css? 'tr:nth-child(1) td.title', text: @the_local_government_edition.title
    assert page.has_css? 'tr:nth-child(1) td.summary', text: @the_local_government_edition.summary
    within 'tr:nth-child(1) td.actions' do
      assert page.has_link? 'View document', href: admin_edition_path(@the_local_government_edition)
    end
  end
end

When /^I tweak the title and summary to better reflect why it is interesting to subscribers$/ do
  within '#email_curation_queue_items tr:nth-child(1) td.actions' do
    click_on 'Edit'
  end

  @tweaked_copy_for_the_local_government_edition = {
    title: 'Totes changed title: ' + @the_local_government_edition.title,
    summary: 'Totes changed summary: ' + @the_local_government_edition.summary
  }

  fill_in 'Title', with: @tweaked_copy_for_the_local_government_edition[:title]
  fill_in 'Summary', with: @tweaked_copy_for_the_local_government_edition[:summary]

  click_on 'Save'

  within '#email_curation_queue_items' do
    assert page.has_css? 'tr:nth-child(1) td.title', text: @tweaked_copy_for_the_local_government_edition[:title]
    assert page.has_css? 'tr:nth-child(1) td.summary', text: @tweaked_copy_for_the_local_government_edition[:summary]
    within 'tr:nth-child(1) td.actions' do
      assert page.has_link? 'View document', href: admin_edition_path(@the_local_government_edition)
    end
  end
end

When /^I decide the policy is ready to go out$/ do
  pending
end

Then /^the policy is not listed on the email curation queue$/ do
  pending
end

Then /^the policy is sent to the notification service with the tweaked copy$/ do
  pending
end
