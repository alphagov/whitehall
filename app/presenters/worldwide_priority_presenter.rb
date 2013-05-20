class WorldwidePriorityPresenter < Whitehall::Decorators::Decorator
  include EditionPresenterHelper

  delegate_instance_methods_of WorldwidePriority

end
