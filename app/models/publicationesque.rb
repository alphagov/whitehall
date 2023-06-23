# Publicationesque is a common base class for things that look like
# publications:
#
# - Calls For Evidence
# - Consultations
# - Publication
# - Statistical Data Sets
#
# @abstract
class Publicationesque < Edition
  include Edition::HasDocumentCollections
  include Edition::Organisations
  include Edition::TaggableOrganisations

  include ::Attachable

  def self.sti_names
    ([self] + descendants).map(&:sti_name)
  end

  def self.published_with_eager_loading(ids)
    published.with_translations.includes([:document, { organisations: :translations }]).where(id: ids)
  end

  def presenter
    PublicationesquePresenter
  end

protected

  def search_format_types
    super + [Publicationesque.search_format_type]
  end

  def hash_with_blank_values?(hash)
    hash.values.reduce(true) do |result, value|
      result && (value.is_a?(Hash) ? hash_with_blank_values?(value) : value.blank?)
    end
  end

  def all_blank_or_empty_hashes(attributes)
    hash_with_blank_values?(attributes)
  end
end
