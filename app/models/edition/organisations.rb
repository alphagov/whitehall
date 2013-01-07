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
    validate :no_duplication_of_organisations

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

  def no_duplication_of_organisations
    # NOTE: we have a uniquness index on the table to prevent this, but it's
    # a good idea to trap it somewhere earlier where we can show a nice error
    # validates_uniqueness_of on the EditionOrganisation wouldn't really
    # give us a nice error (edition_organisations is invalid), so lets try
    # something on the edition itself.
    new_eos = []
    existing_eos = []
    __get_edition_organisations_for_validation(edition_organisations, new_eos, existing_eos)
    __get_edition_organisations_for_validation(lead_edition_organisations, new_eos, existing_eos)
    __get_edition_organisations_for_validation(supporting_edition_organisations, new_eos, existing_eos)

    # adding the same org twice
    if new_eos.map { |(eo_id, org_id)| org_id }.uniq.size != new_eos.size
      errors.add(:organisations, 'must be unique')
    # adding an org that we've already got
    elsif (new_eos.map { |(eo_id, org_id)| org_id } & existing_eos.map { |(eo_id, org_id)| org_id }).any?
      errors.add(:organisations, 'must be unique')
    else
      # existing org somehow added on more than one eo
      existing_dupes = existing_eos.map do |(eo_id, org_id)|
        existing_eos.any? { |(o_eo_id, o_org_id)| (eo_id != o_eo_id) && (org_id == o_org_id) }
      end
      errors.add(:organisations, 'must be unique') if existing_dupes.any?
    end
  end
  def __get_edition_organisations_for_validation(edition_organisation_association, new_eos, existing_eos)
    all_eos = edition_organisation_association.
      reject { |eo| eo.destroyed? }.
      # for orgs that are to be created when we do this, grab the object id
      map { |eo| [eo.id, eo.organisation_id || eo.object_id] }.
      group_by { |(eo_id, org_id)| eo_id.nil? }
    new_eos.push(*all_eos[true]) if all_eos[true].present?
    existing_eos.push(*all_eos[false]) if all_eos[false].present?
    nil
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
