module StandardEdition::Taxon
  extend ActiveSupport::Concern

  def requires_taxon?
    type_instance.settings["taxon_required"]
  end
end
