require "test_helper"

class StatisticalDataSetsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_display_attachments_for :statistical_data_set
  should_be_previewable :statistical_data_set

  test 'show displays published statistical data set' do
    published_statistical_data_set = create(:published_statistical_data_set)
    get :show, id: published_statistical_data_set.document
    assert_select '.title', text: published_statistical_data_set.title
  end

  test "renders the summary of the statistical data set" do
    statistical_data_set = create(:published_statistical_data_set, summary: 'statistical-data-set-summary')
    get :show, id: statistical_data_set.document

    assert_select ".summary", text: "statistical-data-set-summary"
  end

  test "show renders the publication body using govspeak" do
    statistical_data_set = create(:published_statistical_data_set, body: "body-in-govspeak")
    govspeak_transformation_fixture "body-in-govspeak" => "body-in-html" do
      get :show, id: statistical_data_set.document
    end

    assert_select ".body", text: "body-in-html"
  end

  test "show links to the document series that the statistical data set belongs to" do
    document_series = create(:document_series)
    statistical_data_set = create(:published_statistical_data_set, document_series: document_series)
    get :show, id: statistical_data_set.document
    assert_select "a[href=?]", organisation_document_series_path(document_series.organisation, document_series)
  end

  test 'index should display a list of all published statistical data sets' do
    create(:published_statistical_data_set)
    create(:draft_statistical_data_set)
    get :index
    assert_select '.statistical_data_set', count: 1
  end
end
