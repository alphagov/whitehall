class RolesPresenter < Whitehall::Decorators::CollectionDecorator

  def initialize(object, context)
    super(object, RolePresenter, context)
  end

  def remove_unfilled_roles!
    @decorated_collection = nil
    @object = object.to_a.reject { |role| role.current_person.nil? }
  end

  def with_unique_people
    people = unique_people.dup
    @with_unique_people ||= decorated_collection.select  { |role| people.delete(role.model.current_person) }
  end

  def unique_people
    @unique_people ||= object.map { |role| role.current_person }.compact.uniq
  end

  def roles_for(person)
    decorated_collection.select { |role| role.current_person == person }
  end
end
