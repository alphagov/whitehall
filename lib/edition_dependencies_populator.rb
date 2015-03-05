class EditionDependenciesPopulator

  def initialize(edition)
    @edition = edition
  end

  def populate!
    @edition.contact_dependencies = Govspeak::ContactsExtractor.new(@edition.body).contacts
  end

end
