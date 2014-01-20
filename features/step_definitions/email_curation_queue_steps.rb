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
    assert_equal @the_local_government_edition.title, page.first('tr td.title').text
    assert_equal @the_local_government_edition.summary, page.first('tr td.summary').text
  end
end

When /^I tweak the title and summary to better reflect why it is interesting to subscribers$/ do
  within page.first('#email_curation_queue_items tr td.actions') do
    click_on 'Edit'
  end

  @tweaked_copy_for_the_local_government_edition = {
    title: 'Totes changed title: ' + @the_local_government_edition.title,
    summary: 'Totes changed summary: ' + @the_local_government_edition.summary
  }

  fill_in 'Title for email', with: @tweaked_copy_for_the_local_government_edition[:title]
  fill_in 'Summary for email', with: @tweaked_copy_for_the_local_government_edition[:summary]

  click_on 'Save'

  within '#email_curation_queue_items' do
    assert_equal @tweaked_copy_for_the_local_government_edition[:title], page.first('tr td.title').text
    assert_equal @tweaked_copy_for_the_local_government_edition[:summary], page.first('tr td.summary').text

    within page.first('tr td.actions') do
      assert page.has_link? 'View on website', href: document_url(@the_local_government_edition, host: public_host_for_test)
    end
  end
end

When /^I decide the policy is ready to go out$/ do
  visit admin_email_curation_queue_items_path

  within page.first('#email_curation_queue_items tr td.actions') do
    click_on 'Send'
  end
end

Then /^then the policy is not listed on the email curation queue$/ do
  within '#email_curation_queue_items' do
    assert page.has_no_link? 'View document', href: document_url(@the_local_government_edition, host: public_host_for_test)
  end
end

When /^I decide the policy is not relevant to subscribers and delete it$/ do
  within page.first('#email_curation_queue_items tr td.actions') do
    click_on 'Delete'
  end
end

Then /^the policy should be sent to the notification service with the tweaked copy$/ do
  mock_client = mock
  mock_client.stub_everything
  Whitehall.stubs(govuk_delivery_client: mock_client)

  mock_client.expects(:notify).with(
    includes("http://www.example.com/government/policies.atom?relevant_to_local_government=1"),
    includes(@tweaked_copy_for_the_local_government_edition[:title]),
    includes(@tweaked_copy_for_the_local_government_edition[:summary])
  )
end

Then /^the policy should not be sent to the notification service$/ do
  mock_client = mock
  mock_client.stub_everything
  Whitehall.stubs(govuk_delivery_client: mock_client)

  mock_client.expects(:notify).never
end
