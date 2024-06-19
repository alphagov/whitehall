require_relative "./generic_edition"

class SearchableEdition < GenericEdition
  include Edition::Searchable
end
