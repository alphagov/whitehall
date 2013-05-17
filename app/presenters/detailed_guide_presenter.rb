class DetailedGuidePresenter < Struct.new(:model, :context)
 include EditionPresenterHelper

 detailed_guide_methods = DetailedGuide.instance_methods - Object.instance_methods
 delegate *detailed_guide_methods, to: :model

end
