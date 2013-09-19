require 'test_helper'

class Whitehall::Uploader::Finders::SluggedModelFinderTest < ActiveSupport::TestCase
  def setup
    @model_class = stub("Model Class", name: "Model Class")
    @model_instance_1 = stub("instance 1", slug: "slug-1")
    @model_class.stubs(:find_by_slug).returns(nil)
    @model_class.stubs(:find_by_slug).with(@model_instance_1.slug).returns(@model_instance_1)
    @log = stub_everything
    @line_number = 1
    @finder = Whitehall::Uploader::Finders::SluggedModelFinder.new(@model_class, @log, @line_number)
  end

  test "returns the topics by slug" do
    assert_equal [@model_instance_1], @finder.find(["slug-1"])
  end

  test "ignores nil slugs" do
    assert_equal [], @finder.find([nil])
  end

  test "ignores blank slugs" do
    assert_equal [], @finder.find(['', ''])
  end

  test "returns an empty array if a topic can't be found for the given slug" do
    assert_equal [], @finder.find(['made-up-policy-slug'])
  end

  test "logs an error if a topic can't be found for the given slug" do
    @log.expects(:error).with(%q{Unable to find Model Class with slug 'made-up-slug'}, @line_number)
    @finder.find(['made-up-slug'])
  end

  test "returns an empty array if the topic for the given slug that cannot be found" do
    assert_equal [], @finder.find(['made-up-policy-slug'])
  end

  test "ignores duplicate slugs" do
    assert_equal [@model_instance_1], @finder.find([@model_instance_1.slug, @model_instance_1.slug])
  end
end
