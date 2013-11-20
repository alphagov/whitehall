# @abstract
class Publicationesque < Edition
  include Edition::RelatedPolicies
  include Edition::HasDocumentCollections
  include Edition::Organisations
  include Edition::Topics
  include Edition::WorldwidePriorities
  include ::Attachable

  def self.sti_names
    ([self] + descendants).map { |model| model.sti_name }
  end

  def self.published_with_eager_loading(ids)
    self.published.with_translations.includes([:document, organisations: :translations]).where(id: ids)
  end

  def presenter
    PublicationesquePresenter
  end

  def has_official_document?
    has_command_paper? || has_act_paper?
  end

  def has_command_paper?
    attachments.any?(&:is_command_paper?)
  end

  def has_act_paper?
    attachments.any?(&:is_act_paper?)
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

require_relative 'publication'
require_relative 'consultation'
