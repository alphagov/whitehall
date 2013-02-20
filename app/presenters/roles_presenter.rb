class RolesPresenter
  include Enumerable

  attr_reader :source

  array_methods = Array.instance_methods - Object.instance_methods
  delegate *array_methods, to: :decorated_collection

  def initialize(source)
    @source = source
  end

  def decorated_collection
    @decorated_collection ||= source.to_a.collect {|role| RolePresenter.new(role) }
  end

  def with_unique_people
    @with_unique_people ||= decorated_collection.select  { |role| unique_people.delete(role.model.current_person) }
  end

  def unique_people
    @unique_people ||= source.collect { |role| role.current_person }.compact.uniq
  end

  def roles_for(person)
    decorated_collection.select {|role| role.current_person == person}
  end

  def each(&block)
    decorated_collection.each do |presenter|
      yield presenter
    end
  end
end
