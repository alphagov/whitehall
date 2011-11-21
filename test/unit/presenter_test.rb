require "test_helper"

class PresenterTest < ActiveSupport::TestCase
  test "#each should yield a collection of things" do
    things = [1,2,3]
    presenter_class = make_presenter
    presenter = presenter_class.new(things)
    result = []
    presenter.each { |x| result << x }
    assert_equal [1,2,3], result
  end

  test "#each should yield objects that respond to custom methods" do
    things = [1,2,3]
    presenter_class = make_presenter do
      present_object_with do
        def custom_method
          self + 1
        end
      end
    end
    presenter = presenter_class.new(things)
    result = []
    presenter.each do |x|
      assert x.respond_to?(:custom_method)
      result << [x, x.custom_method]
    end
    assert_equal [[1,2], [2,3], [3,4]], result
  end

  private

  def make_presenter(&block)
    Class.new(Whitehall::Presenters::Collection, &block)
  end
end