When /^I write some copy to describe the featured topics and policies for the executive office "([^"]*)"$/ do |org_name|
  @the_featuring_org = Organisation.where(name: org_name).first
  @the_featuring_org_ftap_copy = "The #{@the_featuring_org.name} is totes involved in all of these things. Do ch-ch-check 'em out! LOL"
  visit admin_organisation_path(@the_featuring_org)
  click_on 'Featured topics and policies'
  fill_in 'Summary', with: @the_featuring_org_ftap_copy
  click_on 'Save'
end

When /^I feature some topics and policies for the executive office in a specific order$/ do
  topic_1 = create(:topic)
  policy_1 = create(:published_policy)
  policy_2 = create(:published_policy)

  visit admin_organisation_path(@the_featuring_org)
  click_on 'Featured topics and policies'

  within('.featured-topics-and-policies-items .well:nth-child(1)') do
    choose 'Topic'
    # no better way to identify the select than by direct name
    select topic_1.name, from: 'featured_topics_and_policies_list[featured_items_attributes][0][topic_id]'
    fill_in 'Ordering', with: '1'
  end
  click_on 'Save'

  within('.featured-topics-and-policies-items .well:nth-child(2)') do
    choose 'Policy'
    select policy_2.title, from: 'featured_topics_and_policies_list[featured_items_attributes][1][document_id]'
    fill_in 'Ordering', with: '2'
  end
  click_on 'Save'

  within('.featured-topics-and-policies-items .well:nth-child(3)') do
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

  within '#featured-topics-and-policies' do
    @the_featured_items.each.with_index do |item, idx|
      assert page.has_css?("li:nth-child(#{idx + 1})", text: item.respond_to?(:name) ? item.name : item.title)
    end
  end
end

Then /^I am invited to click through to see all the policies the executive office is involved with$/ do
  visit_organisation @the_featuring_org.name

  click_on 'See all our policies'
  assert page.has_css?(".page_title", text: 'Policies')
  assert page.has_content?("about All topics by #{@the_featuring_org.name}")
end
