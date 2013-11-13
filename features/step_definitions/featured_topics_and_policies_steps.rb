When /^I write some copy to describe the featured topics and policies for the executive office "([^"]*)"$/ do |org_name|
  @the_featuring_org = Organisation.find_by_name(org_name)
  @the_featuring_org_ftap_copy = "The #{@the_featuring_org.name} is totes involved in all of these things. Do ch-ch-check 'em out! LOL"
  visit admin_organisation_path(@the_featuring_org)
  click_on 'Featured topics and policies'
  fill_in 'Summary', with: @the_featuring_org_ftap_copy
  click_on 'Save'
end

When /^I feature some topics and policies for the executive office in a specific order$/ do
  topic_1 = create(:topic, name: 'Grooming')
  policy_1 = create(:published_policy, title: 'Beards to be removed from all statues')
  policy_2 = create(:published_policy, title: 'All eggs to be scrambled prior to consumption')

  visit admin_organisation_path(@the_featuring_org)
  click_on 'Featured topics and policies'

  within page.all('.featured-topics-and-policies-items .well')[0] do
    choose 'Topic'
    # no better way to identify the select than by direct name
    select topic_1.name, from: 'featured_topics_and_policies_list[featured_items_attributes][0][topic_id]'
    fill_in 'Ordering', with: '1'
  end
  click_on 'Save'

  within page.all('.featured-topics-and-policies-items .well')[1] do
    choose 'Policy'
    select policy_2.title, from: 'featured_topics_and_policies_list[featured_items_attributes][1][document_id]'
    fill_in 'Ordering', with: '2'
  end
  click_on 'Save'

  within page.all('.featured-topics-and-policies-items .well')[2] do
    choose 'Policy'
    select policy_1.title, from: 'featured_topics_and_policies_list[featured_items_attributes][2][document_id]'
    fill_in 'Ordering', with: '3'
  end
  click_on 'Save'

  @the_featured_items = [topic_1, policy_2, policy_1]
end

Then /^I see my copy on the executive office page$/ do
  visit_organisation @the_featuring_org.name

  within '#featured-topics-and-policies' do
    assert page.has_content?(@the_featuring_org_ftap_copy)
  end
end

Then /^the featured topics and policies are in my specified order$/ do
  visit_organisation @the_featuring_org.name

  features = page.all('#featured-topics-and-policies li').map(&:text)

  @the_featured_items.each.with_index do |item, idx|
    assert_equal (item.respond_to?(:name) ? item.name : item.title), features[idx]
  end
end

Then /^I am invited to click through to see all the policies the executive office is involved with$/ do
  visit_organisation @the_featuring_org.name

  click_on 'See all our policies'
  assert page.has_css?('h1', text: 'Policies')
  assert page.has_content?("about All topics by #{@the_featuring_org.name}")
end

Given /^there are some topics and policies featured for the executive office "([^"]*)"$/ do |org_name|
  @the_featuring_org = Organisation.find_by_name(org_name)
  topic_1 = create(:topic, name: 'Grooming')
  topic_2 = create(:topic, name: 'Cooking')
  policy_1 = create(:published_policy, title: 'Beards to be removed from all statues')
  policy_2 = create(:published_policy, title: 'All eggs to be scrambled prior to consumption')

  list = create(:featured_topics_and_policies_list, organisation: @the_featuring_org)
  list.featured_items << build(:featured_item, item: policy_2.document, started_at: 3.days.ago)
  list.featured_items << build(:featured_item, item: topic_1, started_at: 4.years.ago)
  list.featured_items << build(:featured_item, item: policy_1.document, started_at: 1.day.ago)
  list.featured_items << build(:featured_item, item: topic_2, started_at: 2.weeks.ago)

  @the_featured_items = [policy_2, topic_1, policy_1, topic_2]
end

When /^I remove some items from the featured topics and policies list for the executive office$/ do
  visit admin_organisation_path(@the_featuring_org)
  click_on 'Featured topics and policies'

  @the_removed_featured_items = []
  within page.all('.featured-topics-and-policies-items .well')[1] do
    check "Remove"
    @the_removed_featured_items << @the_featured_items[1]
  end
  within page.all('.featured-topics-and-policies-items .well')[2] do
    check "Remove"
    @the_removed_featured_items << @the_featured_items[2]
  end

  click_on "Save"
end

Then /^the removed items are no longer displayed on the executive office page$/ do
  visit_organisation @the_featuring_org.name

  features = page.all('#featured-topics-and-policies li').map(&:text)

  (@the_featured_items - @the_removed_featured_items).each.with_index do |item, idx|
    assert_equal (item.respond_to?(:name) ? item.name : item.title), features[idx]
  end
  @the_removed_featured_items.each do |item|
    assert page.has_no_css?("li", text: item.respond_to?(:name) ? item.name : item.title)
  end
end
