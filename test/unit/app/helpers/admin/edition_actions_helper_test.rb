require "test_helper"

class Admin::EditionActionsHelperTest < ActionView::TestCase
  setup do
    @editions = ["Case studies",
                 "Calls for evidence",
                 "Consultations",
                 "Corporate information pages",
                 "Detailed guidances",
                 "Document collections",
                 "News articles",
                 "Publications",
                 "Speeches",
                 "Statistical data sets",
                 "Worldwide organisations"]

    @editions << "History pages"
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
