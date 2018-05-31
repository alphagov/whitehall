module Edition::TaggableOrganisations
  extend ActiveSupport::Concern

  WORLD_TAGGABLE_DOCUMENT_TYPES = %w(Publication DetailedGuide DocumentCollection).freeze

  WORLD_TAGGABLE_PUBLICATION_TYPES = [
    PublicationType::Guidance,
    PublicationType::Form,
  ].freeze

  def can_be_tagged_to_taxonomy?
    topic_taxonomy_taggable?
  end

  def can_be_tagged_to_worldwide_taxonomy?
    world_taggable?
  end

private

  def topic_taxonomy_taggable?
    organisations_in_topic_tagging_beta?
  end

  def world_taggable?
    return unless edition_in_world_taggable_document_types?
    return if self.class == Publication && !publication_is_world_taggable_publication_type?
    organisations_in_world_tagging?
  end

  def organisations_content_ids
    @_org_ids ||= organisations.map(&:content_id)
  end

  def edition_in_world_taggable_document_types?
    WORLD_TAGGABLE_DOCUMENT_TYPES.include?(self.class.name)
  end

  def publication_is_world_taggable_publication_type?
    WORLD_TAGGABLE_PUBLICATION_TYPES.include?(self.publication_type)
  end

  def organisations_in_world_tagging?
    (organisations_content_ids & worldwide_taggable_organisation_ids).present?
  end

  def organisations_in_topic_tagging_beta?
    (organisations_content_ids & topic_taggable_organisation_ids).present?
  end

  def worldwide_taggable_organisation_ids
    Whitehall.worldwide_tagging_organisations.to_a
  end

  def topic_taggable_organisation_ids
    Whitehall.organisations_in_tagging_beta.to_a
  end
end
