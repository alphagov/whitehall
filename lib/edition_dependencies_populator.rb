class EditionDependenciesPopulator

  def initialize(edition)
    @edition = edition
  end

  def populate!
    @edition.depended_upon_contacts = Govspeak::ContactsExtractor.new(@edition.body).contacts
    @edition.depended_upon_editions = Govspeak::DependableEditionsExtractor.new(@edition.body).editions
  end

end
