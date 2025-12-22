require "test_helper"

class Admin::EditionActionsHelperTest < ActionView::TestCase
  setup do
    history_page = build_configurable_document_type("history_page", { "title" => "History page" })
    press_release = build_configurable_document_type("press_release", { "title" => "Press release", "key" => "press_release", "settings" => { "configurable_document_group" => "news_article" } })
    news_story = build_configurable_document_type("news_story", { "title" => "News story", "key" => "news_story", "settings" => { "configurable_document_group" => "news_article" } })
    government_response = build_configurable_document_type("government_response", { "title" => "Government response", "key" => "government_response", "settings" => { "configurable_document_group" => "news_article" } })
    world_news_story = build_configurable_document_type("world_news_story", { "title" => "World news story", "key" => "world_news_story", "settings" => { "configurable_document_group" => "news_article" } })
    duplicated_type = build_configurable_document_type("extra_type", { "title" => "Publication", "key" => "publication" })

    ConfigurableDocumentType.setup_test_types([history_page, press_release, news_story, government_response, world_news_story, duplicated_type].reduce(&:deep_merge))

    # This list includes all the "high-level" types, either stand-alone types, or a "group" with subtypes (such as Publication)
    @types = ["Calls for evidence",
              "Case studies",
              "Consultations",
              "Corporate information pages",
              "Detailed guides",
              "Document collections",
              "History pages",
              "News articles",
              "Publications",
              "Speeches",
              "Statistical data sets",
              "Worldwide organisations"]
    @news_article_sub_types_labels = ["Press releases", "News stories", "Government responses", "World news stories"]
    @news_article_sub_types_values = %w[press_release news_story government_response world_news_story]
  end

  test "#filter_edition_type_opt_groups should contain a formatted list of the types" do
    filter_options = filter_edition_type_opt_groups(create(:user), nil)
    types = filter_options[1].last.map { |type| type[:text] }

    assert_same_elements @types, types
  end

  test "#filter_edition_type_opt_groups should include fatality notices when the user can handle fatalities" do
    filter_options = filter_edition_type_opt_groups(create(:gds_editor), nil)
    types = filter_options[1].last.map { |type| type[:text] }

    assert_same_elements @types + ["Fatality notices"], types
  end

  test "#filter_edition_type_opt_groups should include landing pages when the user is an admin" do
    filter_options = filter_edition_type_opt_groups(create(:gds_admin), nil)
    types = filter_options[1].last.map { |type| type[:text] }

    assert_same_elements @types + ["Fatality notices", "Landing pages"], types
  end

  test "#filter_edition_type_opt_groups should include a 'News article sub-types' section" do
    filter_options = filter_edition_type_opt_groups(create(:gds_editor), nil)
    news_article_sub_types = filter_options[3]

    assert_equal "News article sub-types", news_article_sub_types[0]
    assert_same_elements(@news_article_sub_types_labels, news_article_sub_types[1].map { |type| type[:text] })
    assert_same_elements(@news_article_sub_types_values, news_article_sub_types[1].map { |type| type[:value] })
  end

  # When migrating a content type over to be config-driven, we will be supporting both "legacy" and config-driven documents for a while. Since the code dynamically fetches what options to render from both classes and configuration, we want to remove any duplicates from the list.
  test "#filter_edition_type_opt_groups should remove duplicates (for work in progress config-driven types)" do
    filter_options = filter_edition_type_opt_groups(create(:user), nil)
    types = filter_options[1].last.map { |type| type[:text] }

    assert_equal @types.count, types.count
  end
end
