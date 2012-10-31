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
      creator: build(:user)
    }
  end

  def statistical_data_sets
    @statistical_data_sets ||= [build(:statistical_data_set), build(:statistical_data_set)]
  end

  setup do
    @edition = EditionWithStatisticalDataSets.new(valid_edition_attributes.merge(statistical_data_sets: statistical_data_sets))
  end

  test "edition can be created with statistical data sets" do
    assert_equal statistical_data_sets, @edition.statistical_data_sets
  end

  test "edition does not require data sets" do
    assert EditionWithStatisticalDataSets.new(valid_edition_attributes).valid?
  end

  test "copies the data sets over to a new draft" do
    published = build :published_publication, statistical_data_sets: statistical_data_sets
    assert_equal statistical_data_sets, published.create_draft(build(:user)).statistical_data_sets
  end
end
