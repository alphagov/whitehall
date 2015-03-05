class EditionDependenciesPopulator

  def initialize(dependant)
    @dependant = dependant
  end

  def populate!
    @dependant.contact_dependencies = Govspeak::ContactsExtractor.new(@dependant.body).contacts
  end

end
