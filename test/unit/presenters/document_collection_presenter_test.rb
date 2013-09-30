require 'test/unit'
require 'active_support'
require './app/presenters/document_collection_presenter'
require 'ostruct'

class DocumentCollectionPresenterTest < ActiveSupport::TestCase
  class DummyGroupPresenter
  end

  setup do
    @groups = [:group_1, :group_2, :group_3]
    document_collection = OpenStruct.new(
      title:   :the_title,
      summary: :the_summary,
      body:    :the_body,
      groups: @groups
    )
    @subject = DocumentCollectionPresenter.new(document_collection, :the_view_context, groups_presented_by: DummyGroupPresenter)
  end

  test "it should expose title" do
    assert_equal :the_title, @subject.title
  end

  test "it should expose summary" do
    assert_equal :the_summary, @subject.summary
  end

  test "it should expose body" do
    assert_equal :the_body, @subject.body
  end

  test "groups should return visible groups wrapped in a presenter" do
    @groups.stubs(:visible).returns([:group_1, :group_2])

    DummyGroupPresenter.expects(:new).with(:group_1, :the_view_context).returns(:presented_group_1)
    DummyGroupPresenter.expects(:new).with(:group_2, :the_view_context).returns(:presented_group_2)

    assert_equal [:presented_group_1, :presented_group_2], @subject.groups
  end
end
