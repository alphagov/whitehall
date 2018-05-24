When(/^I start editing a draft document which can be tagged to the new taxonomy$/) do
  create(:organisation, content_id: 'ebd15ade-73b2-4eaf-b1c3-43034a42eb37', name: 'Taxon Org')
  begin_drafting_publication('The Pub')
  stub_taxonomy_data
  stub_patch_links
  within('.lead-organisations') do
    select('Taxon Org', from: 'Organisation 1')
  end
end

Then(/^I should be on the taxonomy tagging page$/) do
  @publication = Publication.last
  assert_equal current_path, edit_admin_edition_tags_path(@publication)
end

Then(/^I should be able to update the taxonomy$/) do
  select_taxon_and_save "School Curriculum"
  check_links_patched_in_publishing_api
  assert_path admin_edition_path(Publication.last)
end

When(/^I start editing a draft document which cannot be tagged to the new taxonomy$/) do
  stub_publishing_api_policies
  stub_topics
  stub_specialist_sectors
  create(:organisation, content_id: 'otherzzz-zzzz-zzzz-zzzz-zzzz0000zzzz', name: 'Non Taxon Org')
  begin_drafting_publication('The Pub', skip_topic_selection: true)
  within('.lead-organisations') do
    select('Non Taxon Org', from: 'Organisation 1')
  end
end

Then(/^I should be on the legacy tagging page$/) do
  @publication = Publication.last
  assert_equal current_path, edit_admin_edition_legacy_associations_path(@publication)
end

Then(/^I should be able to update the legacy tags$/) do
  set_all_legacy_associations
  check_associations_have_been_saved
  check_legacy_associations_are_displayed_on_admin_page
end
