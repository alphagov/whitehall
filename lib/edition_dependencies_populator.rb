class EditionDependenciesPopulator

  def initialize(dependant)
    @dependant = dependant
  end

  def populate!
    populate Govspeak::ContactsExtractor.new(@dependant.body).contacts
  end

private

  def populate(dependables)
    existing_dependables = @dependant.dependencies.includes(:dependable).map(&:dependable)
    dependencies_attributes = (dependables - existing_dependables).inject([]) do |attributes, dependable|
      attributes << { dependant: @dependant, dependable: dependable }
    end
    EditionDependency.create!(dependencies_attributes) if dependencies_attributes.present?
  end
end
