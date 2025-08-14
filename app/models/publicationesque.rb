# Publicationesque is a common base class for things that look like
# publications:
#
# - Calls For Evidence
# - Consultations
# - Publication
# - Statistical Data Sets
class Publicationesque < Edition
  include Edition::HasDocumentCollections
  include Edition::Organisations
  include Edition::TaggableOrganisations

  include ::Attachable

protected

  def hash_with_blank_values?(hash)
    hash.values.reduce(true) do |result, value|
      result && (value.is_a?(Hash) ? hash_with_blank_values?(value) : value.blank?)
    end
  end

  def all_blank_or_empty_hashes(attributes)
    hash_with_blank_values?(attributes)
  end
end
