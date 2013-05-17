class WorldwidePriorityPresenter < Struct.new(:model, :context)
  include EditionPresenterHelper

  worldwide_priority_methods = WorldwidePriority.instance_methods - Object.instance_methods
  delegate *worldwide_priority_methods, to: :model

end
