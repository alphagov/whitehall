require 'test_helper'

class TopicTreePresenterTest < ActiveSupport::TestCase
  test ".toggle_classes when there is only a single taxonomy" do
    result = TopicTreePresenter.new(nil, 1).toggle_classes
    assert_equal "taxon-name", result
  end

  test ".toggle_classes when there are multiple taxonomies" do
    result = TopicTreePresenter.new(nil, 2).toggle_classes
    assert_equal "taxon-name collapsed", result
  end

  test ".tree_classes when there is only a single taxonomy" do
    result = TopicTreePresenter.new(nil, 1).tree_classes
    assert_equal "collapse in", result
  end

  test ".tree_classes when there are multiple taxonomies" do
    result = TopicTreePresenter.new(nil, 2).tree_classes
    assert_equal "collapse", result
  end

  test "other method calls are delegated to the taxon" do
    result = TopicTreePresenter.new(:taxon, nil).to_s
    assert_equal "taxon", result
  end
end
