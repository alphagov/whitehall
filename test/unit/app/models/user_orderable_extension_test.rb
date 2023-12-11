require "test_helper"

class UserOrderableExtensionTest < ActiveSupport::TestCase
  class StubActiveRecordAssociation
    include UserOrderableExtension

    def transaction
      yield
    end

    def find; end
  end

  class StubModel
    include ActiveModel::Model

    attr_accessor :id, :ordering, :other_ordering_column

    def update_column; end

    def update!; end
  end

  setup do
    @association = StubActiveRecordAssociation.new
    @stub_model1 = StubModel.new(id: 1)
    @stub_model2 = StubModel.new(id: 2)

    @association.stubs(:find).with(@stub_model1.id).returns(@stub_model1)
    @association.stubs(:find).with(@stub_model2.id).returns(@stub_model2)
  end

  test "#reorder_without_callbacks! reorders the ordering of the collection using #update_column based on the params passed in" do
    @stub_model2.expects(:update_column).with(:ordering, "1").once
    @stub_model1.expects(:update_column).with(:ordering, "2").once

    @association.reorder_without_callbacks!(
      {
        @stub_model2.id => "1",
        @stub_model1.id => "2",
      },
    )
  end

  test "#reorder_without_callbacks! handles a different attribute being passed in as an optional argument" do
    @stub_model2.expects(:update_column).with(:lead_ordering, "1").once
    @stub_model1.expects(:update_column).with(:lead_ordering, "2").once

    @association.reorder_without_callbacks!(
      {
        @stub_model2.id => "1",
        @stub_model1.id => "2",
      },
      :lead_ordering,
    )
  end

  test "#reorder! reorders the collection using #update! based on the params passed in" do
    @stub_model2.expects(:update!).with(ordering: "1").once
    @stub_model1.expects(:update!).with(ordering: "2").once

    @association.reorder!(
      {
        @stub_model2.id => "1",
        @stub_model1.id => "2",
      },
    )
  end

  test "#reorder! handles a different attribute being passed in as an optional argument" do
    @stub_model2.expects(:update!).with(lead_ordering: "1").once
    @stub_model1.expects(:update!).with(lead_ordering: "2").once

    @association.reorder!(
      {
        @stub_model2.id => "1",
        @stub_model1.id => "2",
      },
      :lead_ordering,
    )
  end
end
