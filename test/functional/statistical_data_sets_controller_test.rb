require "test_helper"

class StatisticalDataSetsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_display_attachments_for :statistical_data_set
  should_be_previewable :statistical_data_set
  should_set_meta_description_for :statistical_data_set

  view_test 'show displays published statistical data set' do
    published_statistical_data_set = create(:published_statistical_data_set)
    get :show, id: published_statistical_data_set.document
    assert_select 'h1', text: published_statistical_data_set.title
  end

  view_test "renders the summary of the statistical data set" do
    statistical_data_set = create(:published_statistical_data_set, summary: 'statistical-data-set-summary')
    get :show, id: statistical_data_set.document

    assert_select ".summary", text: "statistical-data-set-summary"
  end

  view_test "show renders the publication body using govspeak" do
    statistical_data_set = create(:published_statistical_data_set, body: "body-in-govspeak")
    govspeak_transformation_fixture "body-in-govspeak" => "body-in-html" do
      get :show, id: statistical_data_set.document
    end

    assert_select ".body", text: "body-in-html"
  end

  view_test "show links to the document collection that the statistical data set belongs to" do
    document = create(:published_statistical_data_set).document
    document_collection = create(:document_collection, :with_group)
    document_collection.groups.first.documents = [document]
    get :show, id: document

    assert_select "a[href=?]", public_document_path(document_collection)
  end

  view_test 'index should display a list of all published statistical data sets' do
    create(:published_statistical_data_set)
    create(:draft_statistical_data_set)
    get :index
    assert_select '.statistical_data_set', count: 1
  end
end
