class FatalityNoticePresenter < Whitehall::Decorators::Decorator
  include EditionPresenterHelper

  delegate_instance_methods_of FatalityNotice

end
