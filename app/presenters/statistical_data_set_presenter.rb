class StatisticalDataSetPresenter < Whitehall::Decorators::Decorator
  include EditionPresenterHelper

  delegate_instance_methods_of StatisticalDataSet
end
