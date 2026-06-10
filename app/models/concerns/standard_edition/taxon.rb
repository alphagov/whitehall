module StandardEdition::Taxon
  extend ActiveSupport::Concern

  def requires_taxon?
    return unless supports_taxon?

    type_instance.settings["taxon"]["required"]
  end

  def supports_taxon?
    type_instance.settings["taxon"]["enabled"]
  end
end
