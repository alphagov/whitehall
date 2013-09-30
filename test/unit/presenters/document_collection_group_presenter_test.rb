require 'test/unit'
require 'active_support'
require './app/presenters/document_collection_group_presenter'
require 'ostruct'

class DocumentCollectionGroupPresenterTest < ActiveSupport::TestCase
  class DummyEditionCollectionPresenter
  end

  setup do
    group = OpenStruct.new({
      id:                 :the_id,
      heading:            :the_heading,
      body:               :the_body,
      published_editions: :a_collection_of_editions
    })
    @subject = DocumentCollectionGroupPresenter.new(group, :the_view_context, edition_collection_presented_by: DummyEditionCollectionPresenter)
  end

  test "it should expose id" do
    assert_equal :the_id, @subject.id
  end

  test "it should expose heading" do
    assert_equal :the_heading, @subject.heading
  end

  test "it should expose body" do
    assert_equal :the_body, @subject.body
  end

  test "editions should return the group's published_editions wrapped in a presenter" do
    DummyEditionCollectionPresenter.expects(:new).with(:a_collection_of_editions, :the_view_context).returns(:a_presented_collection_of_editions)

    assert_equal :a_presented_collection_of_editions, @subject.editions
  end
end
