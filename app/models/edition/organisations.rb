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
    has_many :edition_organisations, foreign_key: :edition_id, dependent: :destroy, autosave: true
    has_many :organisations, include: :translations, through: :edition_organisations

    before_save :mark_for_destruction_all_edition_organisations_for_destruction
    after_save :clear_edition_organisations_touched_or_destroyed_by_lead_or_supporting_organisations_setters

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

  def lead_edition_organisations
    edition_organisations.where(lead: true).order('edition_organisations.lead_ordering')
  end

  def supporting_edition_organisations
    edition_organisations.where(lead: false)
  end

  def lead_organisations
    organisations.where(edition_organisations: { lead: true }).reorder('edition_organisations.lead_ordering')
  end

  def lead_organisations=(new_lead_organisations)
    self.lead_organisation_ids = new_lead_organisations.map(&:id)
  end

  def lead_organisation_ids=(new_lead_organisation_ids)
    __mange_edition_organisations(new_lead_organisation_ids, for_lead: true)
  end

  def supporting_organisations
    organisations.where(edition_organisations: { lead: false })
  end

  def supporting_organisations=(new_supporting_organisations)
    self.supporting_organisation_ids = new_supporting_organisations.map(&:id)
  end

  def supporting_organisation_ids=(new_supporting_organisation_ids)
    __mange_edition_organisations(new_supporting_organisation_ids, for_lead: false)
  end

  def association_with_organisation(organisation)
    edition_organisations.where(organisation_id: organisation.id).first
  end

  def can_be_related_to_organisations?
    true
  end

  def skip_organisation_validation?
    false
  end

  private

  def at_least_one_lead_organisation
    unless skip_organisation_validation?
      unless edition_organisations.detect { |eo| eo.lead? }
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
    all_organisations = edition_organisations
      .reject { |eo| eo.marked_for_destruction? || __edition_organisations_for_destruction_on_save.include?(eo) }
      .map {|eo| eo.organisation_id }

    if all_organisations.uniq.size != all_organisations.size
      errors.add(:organisations, 'must be unique')
    end
  end

  def __mange_edition_organisations(new_organisation_ids, args = {})
    # try to avoid common AR pitfalls by reusing objects instead of
    # destroying & creating new.
    args = {for_lead: true}.merge(args)
    for_lead = args[:for_lead]
    existing_edition_organisations = edition_organisations.to_a.dup

    new_organisation_ids.each.with_index do |new_organisation_id, idx|
      # find an existing instance
      existing = existing_edition_organisations
        .reject { |eo| __edition_organisations_touched_by_lead_or_supporting_organisations_setters.include?(eo) }
        .detect { |eo| eo.organisation_id.to_s == new_organisation_id.to_s }

      if existing
        # and remove it from the things to look at now...
        existing_edition_organisations.delete(existing)
        # ...or globally
        # if it's already been touched we assume lead_orgs or
        # supporting_orgs has already touched it so someone is trying to set
        # a duplicate, we should allow this so they get an error
        __edition_organisations_touched_by_lead_or_supporting_organisations_setters << existing
        if for_lead
          existing.lead = true
          existing.lead_ordering = idx + 1
        else
          existing.lead = false
          existing.lead_ordering = nil
        end
        __edition_organisations_for_destruction_on_save.delete(existing)
      else
        eo = edition_organisations.build(lead: for_lead,
                                         organisation_id: new_organisation_id,
                                         edition: self)
        eo.lead_ordering = idx + 1 if for_lead
        __edition_organisations_touched_by_lead_or_supporting_organisations_setters << eo
      end
    end
    # look at the remaining ones and destroy them if they are
    # lead == for_lead 'cos they weren't consumed above
    existing_edition_organisations.each do |eo|
      if eo.lead == for_lead
        __edition_organisations_for_destruction_on_save << eo
      end
    end
  end

  def __edition_organisations_touched_by_lead_or_supporting_organisations_setters
    @edition_organisations_touched_by_lead_or_supporting_organisations_setters ||= []
  end

  def __edition_organisations_for_destruction_on_save
    @edition_organisations_for_destruction_on_save ||= []
  end

  def mark_for_destruction_all_edition_organisations_for_destruction
    __edition_organisations_for_destruction_on_save.each { |eo| eo.mark_for_destruction }
  end

  def clear_edition_organisations_touched_or_destroyed_by_lead_or_supporting_organisations_setters
    __edition_organisations_for_destruction_on_save.clear
    __edition_organisations_touched_by_lead_or_supporting_organisations_setters.clear
  end
end
