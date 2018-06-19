require 'test_helper'
require 'capybara/rails'

class WorldTaggingFlow < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include TaxonomyHelper
  include Rails.application.routes.url_helpers

  setup do
    login_as_admin
  end

  context 'given I want to tag to the WorldWide taxonomy' do
    let(:world_organisation) do
      create(:organisation, content_id: "9adfc4ed-9f6c-4976-a6d8-18d34356367c")
    end
    let(:world_edition) do
      create(:publication, :guidance, organisations: [world_organisation])
    end

    before do
      setup_world_tagging_page
    end

    it "asserts WorldWide tagging path" do
      visit_world_tags_path
      assert_equal(200, page.status_code)
    end

    it "asserts a selected checkbox' " do
      visit_world_tags_path
      expand_and_check_checkbox
      assert page.has_checked_field?('World grandchild taxon')
    end

    it "asserts redirect by clicking 'Save topic changes'" do
      visit_world_tags_path
      stub_publishing_api_expanded_links_with_taxons(
        world_edition.content_id,
        [world_child_taxon]
      )
      click_save_topic_changes
      assert_current_path "/government/admin/publications/#{world_edition.id}"
      assert_equal(200, page.status_code)
    end
  end

  def click_save_topic_changes
    click_button "Save topic changes"
  end

  def expand_and_check_checkbox
    click_link "World child taxon"
    check "World grandchild taxon"
  end

  def visit_world_tags_path
    visit "/government/admin/editions/#{world_edition.id}/world_tags/edit"
  end

  def setup_world_tagging_page
    redis_cache_has_world_taxons([world_child_taxon])
    stub_publishing_api_links_with_taxons(world_edition.content_id, [])
  end
end
