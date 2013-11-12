require 'test_helper'

class Edition::StatisticalDataSetsTest < ActiveSupport::TestCase
  class EditionWithStatisticalDataSets < Edition
    include ::Edition::StatisticalDataSets
  end

  include ActionDispatch::TestProcess

  def valid_edition_attributes
    {
      title:   'edition-title',
      body:    'edition-body',
      summary: 'edition-summary',
      creator: create(:user)
    }
  end

  def statistical_data_sets
    @statistical_data_sets ||= [
      create(:statistical_data_set, document: create(:document)),
      create(:statistical_data_set, document: create(:document))
    ]
  end

  setup do
    @edition = EditionWithStatisticalDataSets.create(valid_edition_attributes.merge(statistical_data_sets: statistical_data_sets))
  end

  test "edition can be created with statistical data sets" do
    assert_equal statistical_data_sets, @edition.statistical_data_sets
  end

  test "edition does not require data sets" do
    assert EditionWithStatisticalDataSets.create(valid_edition_attributes).valid?
  end

  test "copies the data sets over to a create draft" do
    published = create :published_publication, statistical_data_sets: statistical_data_sets
    assert_equal statistical_data_sets, published.create_draft(create(:user)).statistical_data_sets
  end

  test "returns published data sets" do
    published_data_set = create :published_statistical_data_set, document: create(:document)
    draft_data_set = create :draft_statistical_data_set, document: create(:document)

    publication = EditionWithStatisticalDataSets.create!(valid_edition_attributes.merge(statistical_data_sets: [published_data_set, draft_data_set]))

    assert_equal [published_data_set], publication.published_statistical_data_sets
  end
end
