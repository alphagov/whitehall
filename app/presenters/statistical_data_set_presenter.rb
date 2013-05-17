class StatisticalDataSetPresenter < Struct.new(:model, :context)
  include EditionPresenterHelper

  statistical_data_set_methods = StatisticalDataSet.instance_methods - Object.instance_methods
  delegate *statistical_data_set_methods, to: :model
end
