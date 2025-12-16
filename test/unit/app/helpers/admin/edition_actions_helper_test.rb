require "test_helper"

class Admin::EditionActionsHelperTest < ActionView::TestCase
  extend Minitest::Spec::DSL

  setup do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("history_page", { "title" => "History page", "settings" => { "configurable_document_group" => "history" } }))
    @editions = ["Calls for evidence",
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
  end

  test "#filter_edition_type_opt_groups should contain a formatted list of the editions" do
    filter_options = filter_edition_type_opt_groups(create(:user), nil)
    types = filter_options[1].last.map { |type| type[:text] }

    assert_same_elements @editions, types
  end

  test "#filter_edition_type_opt_groups should include fatality notices when the user can handle fatalities" do
    filter_options = filter_edition_type_opt_groups(create(:gds_editor), nil)
    types = filter_options[1].last.map { |type| type[:text] }

    assert_same_elements @editions + ["Fatality notices"], types
  end

  test "#filter_edition_type_opt_groups should include landing pages when the user is an admin" do
    filter_options = filter_edition_type_opt_groups(create(:gds_admin), nil)
    types = filter_options[1].last.map { |type| type[:text] }

    assert_same_elements @editions + ["Fatality notices", "Landing pages"], types
  end

  context "Tests using forms schema for configurable content blocks" do
    setup do
      ConfigurableDocumentType.setup_test_types(build_configurable_document_type_with_forms("history_page", { "title" => "History page", "settings" => { "configurable_document_group" => "history" } }))
      @editions = ["Calls for evidence",
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
    end

    test "#filter_edition_type_opt_groups should contain a formatted list of the editions" do
      filter_options = filter_edition_type_opt_groups(create(:user), nil)
      types = filter_options[1].last.map { |type| type[:text] }

      assert_same_elements @editions, types
    end

    test "#filter_edition_type_opt_groups should include fatality notices when the user can handle fatalities" do
      filter_options = filter_edition_type_opt_groups(create(:gds_editor), nil)
      types = filter_options[1].last.map { |type| type[:text] }

      assert_same_elements @editions + ["Fatality notices"], types
    end

    test "#filter_edition_type_opt_groups should include landing pages when the user is an admin" do
      filter_options = filter_edition_type_opt_groups(create(:gds_admin), nil)
      types = filter_options[1].last.map { |type| type[:text] }

      assert_same_elements @editions + ["Fatality notices", "Landing pages"], types
    end
  end
end
