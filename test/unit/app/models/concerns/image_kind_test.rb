require "test_helper"

class ImageKindTest < ActiveSupport::TestCase
  setup do
    @test_instance = (
      Class.new do
        include ActiveModel::Model
        include ActiveModel::Attributes
        include ActiveModel::AttributeAssignment

        include ImageKind

        attr_reader :assigned_attributes

        def assign_attributes(attributes)
          @assigned_attributes = attributes
        end
      end
    ).new
  end

  test "adds an image_kind method with a default" do
    assert_equal "default", @test_instance.image_kind
  end

  test "reorders attributes so image_kind comes first" do
    @test_instance.assign_attributes(file: "some file", image_kind: "some image kind")
    assert_equal({ image_kind: "some image kind", file: "some file" }, @test_instance.assigned_attributes)
  end

  test "loads image_kind_config" do
    assert_instance_of Whitehall::ImageKind, @test_instance.image_kind_config
  end
end
