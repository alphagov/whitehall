require 'public_document_routes_helper'

class GenericEdition < Edition
  class << self
    attr_accessor :translatable
  end
  def translatable?
    self.class.translatable
  end
end

module PublicDocumentRoutesHelper
  def generic_edition_path(options = {})
    "/government/generic-editions/#{options[:id].to_param}"
  end

  def generic_edition_url(options = {})
    options[:host] + generic_edition_path(options)
  end
end
