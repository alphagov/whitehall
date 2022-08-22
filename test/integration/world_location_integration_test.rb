require "test_helper"
require "gds_api/test_helpers/publishing_api"
require "capybara/rails"

class WorldLocationIntegrationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Capybara::DSL
  include Rails.application.routes.url_helpers
  include TaxonomyHelper

  before do
    organisation = create(:organisation)
    managing_editor = create(:managing_editor, organisation: organisation, uid: "user-uid")

    login_as managing_editor
  end

  setup do
    @original_french_mission_statement = "Enseigner aux gens comment infuser le thé"
    @original_english_title = "France and the UK"
    @original_english_mission_statement = "a mission statement"
    @original_french_title = "Le Royaume-Uni et la France"
    @world_location = create(:world_location,
                             slug: "france",
                             mission_statement: @original_english_mission_statement,
                             news_page_content_id: "id-123",
                             title: @original_english_title,
                             translated_into:
                               { fr: {
                                 name: "La France",
                                 title: @original_french_title,
                                 mission_statement: @original_french_mission_statement,
                               } })
  end

  def put_content_hash_containing(locale, title, mission_statement)
    has_entries(locale: locale, title: title, details: has_entries(mission_statement: mission_statement))
  end

  test "when updating the english news page, other translations retains their original values" do
    Sidekiq::Testing.inline! do
      visit edit_admin_world_location_path(@world_location)
      new_mission_statement = "a different mission"
      fill_in "world_location_mission_statement", with: new_mission_statement
      new_title = "a new title"
      fill_in "Title", with: new_title

      Services.publishing_api.expects(:put_content).once.with("id-123", put_content_hash_containing("en", new_title, new_mission_statement))
      Services.publishing_api.expects(:put_content).once.with("id-123", put_content_hash_containing("fr", @original_french_title, @original_french_mission_statement))
      Services.publishing_api.expects(:put_content).once.with(@world_location.content_id, has_entries(document_type: "world_location"))
      Services.publishing_api.expects(:publish).at_least_once

      click_on "Save"
    end
  end

  test "when updating a non-english news page, the english version retains its original values" do
    Sidekiq::Testing.inline! do
      visit admin_world_location_path(@world_location)
      click_link "Translations"
      click_link "Français"
      new_mission_statement = "un mission différent"
      fill_in "world_location_mission_statement", with: new_mission_statement
      new_title = "un titre différent"
      fill_in "Title", with: new_title

      Services.publishing_api.expects(:put_content).once.with("id-123", put_content_hash_containing("en", @original_english_title, @original_english_mission_statement))
      Services.publishing_api.expects(:put_content).once.with("id-123", put_content_hash_containing("fr", new_title, new_mission_statement))
      Services.publishing_api.expects(:put_content).at_least_once.with(@world_location.content_id, has_entries(document_type: "world_location"))
      Services.publishing_api.expects(:publish).at_least_once

      click_on "Save"
    end
  end
end
