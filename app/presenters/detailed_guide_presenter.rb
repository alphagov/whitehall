class DetailedGuidePresenter < Whitehall::Decorators::Decorator
 include EditionPresenterHelper

 delegate_instance_methods_of DetailedGuide

end
