module AdminLegacyAssociationsHelper
  def set_all_legacy_associations
    tag_to_policy(policy_1)
    tag_to_policy_area(policy_area_3)
    tag_specialist_sectors
    click_button "Save legacy associations"
  end

  def check_associations_have_been_saved
    check_policies(policies: [policy_area_1, policy_1])
    check_policy_areas
    check_specialist_sectors
  end

  def check_legacy_associations_are_displayed_on_admin_page
    assert_selected_policies_are_displayed
    assert_selected_policy_areas_are_displayed
    assert_selected_specialist_sectors_are_displayed
  end

  def stub_topics
    @pol_area_1 = create(:topic, name: policy_area_1['title'])
    @pol_area_3 = create(:topic, name: policy_area_3['title'])
  end

private

  def assert_selected_policies_are_displayed
    assert has_css? ".policies li", text: policy_1['title']
    assert has_css? ".policies li", text: policy_area_1['title'] # TODO this seems wrong
    refute has_css? ".policies li", text: policy_2['title']
  end

  def check_policies(policies:)
    policy_content_ids = policies.map { |policy| policy["content_id"] }
    assert_equal policy_content_ids, Publication.last.policy_content_ids
  end

  def assert_selected_policy_areas_are_displayed
    refute has_css? ".policy-areas li", text: policy_area_1['title']
    assert has_css? ".policy-areas li", text: policy_area_3['title']
    refute has_css? ".policy-areas li", text: policy_area_2['title']
  end


  def check_policy_areas()
    topic_ids = [@pol_area_3.id]
    assert_equal topic_ids, Publication.last.topic_ids
  end
  
  def tag_to_policy(policy)
    select policy["title"], from: 'Policies'
  end

  def tag_to_policy_area(policy_area)
    select policy_area["title"], from: 'Policy Areas'
  end

  def tag_specialist_sectors
    select 'Oil and Gas: Wells', from: 'Primary specialist sector tag'
    select 'Oil and Gas: Fields', from: 'Additional specialist sectors'
    select 'Oil and Gas: Offshore', from: 'Additional specialist sectors'
  end

  def check_specialist_sectors
    assert_equal 'WELLS', Publication.last.primary_specialist_sector_tag
    assert_equal %w[FIELDS OFFSHORE], Publication.last.secondary_specialist_sector_tags
  end

  def assert_selected_specialist_sectors_are_displayed
    assert has_css? ".primary-specialist-sector li", text: 'Oil and Gas: Wells'
    refute has_css? ".primary-specialist-sector li", text: 'Oil and Gas: Fields'
    assert has_css? ".secondary-specialist-sectors li", text: 'Oil and Gas: Fields'
    assert has_css? ".secondary-specialist-sectors li", text: 'Oil and Gas: Offshore'
    refute has_css? ".secondary-specialist-sectors li", text: 'Oil and Gas: Wells'

  end
end

World(AdminLegacyAssociationsHelper)
