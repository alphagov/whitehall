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

    @world_location_news = build(:world_location_news,
                                 mission_statement: @original_english_mission_statement,
                                 title: @original_english_title,
                                 translated_into:
                                   { fr: { mission_statement: @original_french_mission_statement, title: @original_french_title } })

    @world_location = create(:world_location,
                             slug: "france",
                             translated_into:
                               { fr: { name: "La France" } },
                             world_location_news: @world_location_news,
                             active: true)
  end

  def search_index_add_parameters(world_location_name, new_title = nil)
    {
      "content_id" => world_location_name.content_id,
      "link" => "/world/#{world_location_name.slug}/news",
      "format" => "world_location_news",
      "title" => new_title || world_location_name.title,
      "description" => "Updates, news and events from the UK government in #{world_location_name.name}",
    }
  end

  def put_content_hash_containing(locale, title, mission_statement)
    has_entries(locale: locale, title: title, details: has_entries(mission_statement: mission_statement))
  end

  test "when updating, makes the correct calls to publishing api" do
    Sidekiq::Testing.inline! do
      world_location_news_without_translations = build(:world_location_news)
      world_location = create(:world_location, world_location_news: world_location_news_without_translations, name: "germany")
      visit edit_admin_world_location_news_path(world_location_news_without_translations)
      new_mission_statement = "a different mission"
      fill_in "world_location_news_mission_statement", with: new_mission_statement

      Services.publishing_api.expects(:put_content).once.with(world_location_news_without_translations.content_id, put_content_hash_containing("en", world_location_news_without_translations.title, new_mission_statement))
      Services.publishing_api.expects(:put_content).once.with(world_location.content_id, has_entries(document_type: "world_location"))
      Services.publishing_api.expects(:publish).at_least_once

      click_on "Save"
    end
  end

  test "when updating a world location news without translations, makes the correct call to search api" do
    Sidekiq::Testing.inline! do
      world_location_news_without_translations = build(:world_location_news)
      create(:world_location, world_location_news: world_location_news_without_translations, name: "germany", active: true)
      visit edit_admin_world_location_news_path(world_location_news_without_translations)
      new_mission_statement = "a different mission"
      fill_in "world_location_news_mission_statement", with: new_mission_statement

      Whitehall::FakeRummageableIndex.any_instance.expects(:add).twice.with(search_index_add_parameters(world_location_news_without_translations))

      click_on "Save"
    end
  end

  test "when updating an inactive location, does not make any calls to search api" do
    Sidekiq::Testing.inline! do
      world_location_news_without_translations = build(:world_location_news)
      create(:world_location, world_location_news: world_location_news_without_translations, name: "germany", active: false)
      visit edit_admin_world_location_news_path(world_location_news_without_translations)
      new_mission_statement = "a different mission"
      fill_in "world_location_news_mission_statement", with: new_mission_statement

      Whitehall::FakeRummageableIndex.any_instance.expects(:add).never

      click_on "Save"
    end
  end

  test "when updating a world location news with translations, does not make any calls to search api" do
    Sidekiq::Testing.inline! do
      visit admin_world_location_news_path(@world_location_news)
      click_link "Translations"
      click_link "Français"
      new_mission_statement = "un mission différent"
      fill_in "world_location_news_mission_statement", with: new_mission_statement

      Whitehall::FakeRummageableIndex.any_instance.expects(:add).never

      click_on "Save"
    end
  end

  test "when updating the english news page, other translations retains their original values" do
    Sidekiq::Testing.inline! do
      visit edit_admin_world_location_news_path(@world_location_news)
      new_mission_statement = "a different mission"
      fill_in "world_location_news_mission_statement", with: new_mission_statement
      new_title = "a new title"
      fill_in "Title", with: new_title

      Services.publishing_api.expects(:put_content).once.with(@world_location_news.content_id, put_content_hash_containing("en", new_title, new_mission_statement))
      Services.publishing_api.expects(:put_content).once.with(@world_location_news.content_id, put_content_hash_containing("fr", @original_french_title, @original_french_mission_statement))
      Services.publishing_api.expects(:put_content).once.with(@world_location.content_id, has_entries(document_type: "world_location"))
      Services.publishing_api.expects(:publish).at_least_once
      Whitehall::FakeRummageableIndex.any_instance.expects(:add).twice.with(search_index_add_parameters(@world_location_news, new_title))

      click_on "Save"
    end
  end

  # FIXME
  test "when updating a non-english news page, the english version retains its original values" do
    Sidekiq::Testing.inline! do
      visit admin_world_location_news_path(@world_location_news)
      click_link "Translations"
      click_link "Français"
      new_mission_statement = "un mission différent"
      fill_in "world_location_news_mission_statement", with: new_mission_statement
      new_title = "un titre différent"
      fill_in "Title", with: new_title

      Services.publishing_api.expects(:put_content).once.with(@world_location_news.content_id, put_content_hash_containing("en", @original_english_title, @original_english_mission_statement))
      Services.publishing_api.expects(:put_content).at_least_once.with(@world_location_news.content_id, put_content_hash_containing("fr", new_title, new_mission_statement))
      Services.publishing_api.expects(:put_content).at_least_once.with(@world_location.content_id, has_entries(document_type: "world_location"))
      Services.publishing_api.expects(:publish).at_least_once

      click_on "Save"
    end
  end
end
