require 'test_helper'

class TopicTreePresenterTest < ActiveSupport::TestCase
  test ".toggle_classes when collapsed is false" do
    result = TopicTreePresenter.new(nil, collapsed: false).toggle_classes
    assert_equal "taxon-name", result
  end

  test ".toggle_classes when collapsed is true" do
    result = TopicTreePresenter.new(nil, collapsed: true).toggle_classes
    assert_equal "taxon-name collapsed", result
  end

  test ".tree_classes when collapsed is false" do
    result = TopicTreePresenter.new(nil, collapsed: false).tree_classes
    assert_equal "collapse in", result
  end

  test ".tree_classes when collapsed is true" do
    result = TopicTreePresenter.new(nil, collapsed: true).tree_classes
    assert_equal "collapse", result
  end

  test "other method calls are delegated to the taxon" do
    result = TopicTreePresenter.new(:taxon).to_s
    assert_equal "taxon", result
  end
end
