When /^a policy relevant to local government is published$/ do
  begin_drafting_policy title: 'A local policy, for local people'
  fill_in_change_note_if_required
  check "Relevant to local government"
  click_on 'Save'
  publish(force: true)
  @the_local_government_edition = Policy.published.last
end

Then /^the policy is listed at the top of the email curation queue$/ do
  pending
end

When /^I tweak the title and summary to better reflect why it is interesting to subscribers$/ do
  pending
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
