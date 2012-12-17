module Edition::Organisations
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      @edition.edition_organisations.each do |association|
        edition.edition_organisations.build(association.attributes.except("id"))
      end
    end
  end

  included do
    has_many :edition_organisations, foreign_key: :edition_id, dependent: :destroy
    has_many :organisations, through: :edition_organisations

    has_many :lead_edition_organisations, foreign_key: :edition_id,
                                          class_name: 'EditionOrganisation',
                                          conditions: {lead: true},
                                          order: 'edition_organisations.lead_ordering'

    has_many :supporting_edition_organisations, foreign_key: :edition_id,
                                                class_name: 'EditionOrganisation',
                                                conditions: {lead: false}

    def lead_organisations
      organisations.where(edition_organisations: { lead: true }).reorder('edition_organisations.lead_ordering')
    end

    def supporting_organisations
      organisations.where(edition_organisations: { lead: false })
    end
    accepts_nested_attributes_for :edition_organisations, reject_if: -> attributes { attributes['organisation_id'].blank? }, allow_destroy: true

    before_validation :make_all_edition_organisations_mine
    after_save :reset_edition_organisations
    validate :at_least_one_lead_organisation

    add_trait Trait
  end

  module ClassMethods
    def in_organisation(organisation)
      organisations = [*organisation]
      slugs = organisations.map(&:slug)
      where('exists (
               select * from edition_organisations eo_orgcheck
                 join organisations orgcheck on eo_orgcheck.organisation_id=orgcheck.id
               where
                 eo_orgcheck.edition_id=editions.id
               and orgcheck.slug in (?))', slugs)
    end
  end

  def association_with_organisation(organisation)
    edition_organisations.where(organisation_id: organisation.id).first
  end

  def skip_organisation_validation?
    false
  end

private
  def at_least_one_lead_organisation
    unless skip_organisation_validation?
      unless lead_edition_organisations.any? || edition_organisations.detect {|eo| eo.lead? }
        errors[:lead_organisations] = "at least one required"
      end
    end
  end

  def make_all_edition_organisations_mine
    edition_organisations.each { |eo| eo.edition = self unless eo.edition == self }
    lead_edition_organisations.each { |eo| eo.edition = self unless eo.edition == self }
    supporting_edition_organisations.each { |eo| eo.edition = self unless eo.edition == self }
  end

  def reset_edition_organisations
    # we have 3 ways into the underlying data structure for EditionOrganisations
    # safest to reset all the assocations after saving so they all pick up
    # any changes made via the other endpoints.
    self.association(:edition_organisations).reset
    self.association(:organisations).reset
    self.association(:lead_edition_organisations).reset
    self.association(:supporting_edition_organisations).reset
  end
end
