require "test_helper"

class UserOrderableClassTest < ActiveSupport::TestCase
  class StubModel
    include ActiveModel::Model
    include UserOrderableClass

    attr_accessor :id, :ordering

    def self.transaction
      yield
    end

    def self.find; end

    def update_column; end

    def update!; end
  end

  setup do
    @model1 = StubModel.new(id: 1, ordering: 1)
    @model2 = StubModel.new(id: 2, ordering: 2)

    StubModel.stubs(:find).with(@model1.id).returns(@model1)
    StubModel.stubs(:find).with(@model2.id).returns(@model2)
  end

  test "#reorder_without_callbacks! reorders the ordering of the collection using #update_column based on the params and column name passed in" do
    @model2.expects(:update_column).with(:ordering, "1").once
    @model1.expects(:update_column).with(:ordering, "2").once

    StubModel.reorder_without_callbacks!(
      {
        @model2.id => "1",
        @model1.id => "2",
      },
      :ordering,
    )
  end

  test "#reorder! reorders the collection using #update! based on the params passed in" do
    @model2.expects(:update!).with(ordering: "1").once
    @model1.expects(:update!).with(ordering: "2").once

    StubModel.reorder!(
      {
        @model2.id => "1",
        @model1.id => "2",
      },
      :ordering,
    )
  end
end
