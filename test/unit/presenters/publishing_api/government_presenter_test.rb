require "test_helper"

class PublishingApi::GovernmentPresenterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe PublishingApi::GovernmentPresenter do
    setup do
      @government = create(:government)
      @presenter = PublishingApi::GovernmentPresenter.new(@government)
    end

    test "the presenter has the content_id" do
      assert_equal @government.content_id, @presenter.content_id
    end

    test "the details has started_on" do
      assert_equal(
        @government.start_date.rfc3339,
        @presenter.content.dig(:details, :started_on),
      )
    end

    context "given a previous government" do
      setup do
        @government = create(:previous_government, slug: "foo")
        @presenter = PublishingApi::GovernmentPresenter.new(@government)
      end

      test "the details has ended_on" do
        assert_equal(
          @government.end_date.rfc3339,
          @presenter.content.dig(:details, :ended_on),
        )
      end

      test "current is false" do
        assert_not @presenter.content.dig(:details, :current)
      end
    end

    context "given a current government" do
      setup do
        @government = create(:current_government)
        @presenter = PublishingApi::GovernmentPresenter.new(@government)
      end

      test "the details has a null ended_on" do
        assert_nil @presenter.content.dig(:details, :ended_on)
      end

      test "current is true" do
        assert @presenter.content.dig(:details, :current)
      end
    end
  end
end
