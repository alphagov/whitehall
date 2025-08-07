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
    has_many :organisations, -> { includes(:translations) }, through: :edition_organisations

    before_validation :mark_for_destruction_all_edition_organisations_for_destruction
    after_save :clear_edition_organisations_touched_or_destroyed_by_lead_or_supporting_organisations_setters

    validate :at_least_one_lead_organisation
    validate :no_duplication_of_organisations

    add_trait Trait
  end

  def lead_edition_organisations
    edition_organisations.where(lead: true).order("edition_organisations.lead_ordering")
  end

  def supporting_edition_organisations
    edition_organisations.where(lead: false)
  end

  def lead_organisations
    organisations.where(edition_organisations: { lead: true }).reorder("edition_organisations.lead_ordering")
  end

  def lead_organisation_ids
    lead_organisations.pluck(:id)
  end

  def sorted_organisations
    organisations.alphabetical
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
    edition_organisations.find_by(organisation_id: organisation.id)
  end

  def importance_ordered_organisations
    organisations.reorder("edition_organisations.lead DESC, edition_organisations.lead_ordering")
  end

  def can_be_related_to_organisations?
    true
  end

  def can_have_supporting_organisations?
    true
  end

  def skip_organisation_validation?
    false
  end

  def search_index
    super.merge("organisations" => organisations.map(&:slug))
  end

  def limits_access_via_organisations?
    true
  end

  # Rails automatically defines methods called
  # `validate_associated_records_for_<association>` for any association that is
  # autosaved or validated. These methods run validations on each associated
  # EditionOrganisation and Organisation, which causes an otherwise-valid edition
  # to become invalid if any linked organisation is invalid (for example, because
  # of an overlong custom_jobs_url). We don’t want an invalid organisation to
  # block publication of an edition, so we override these methods to no-op.
  #
  # Presence and uniqueness of associated organisations are already enforced
  # by our own custom validators, so skipping these auto-generated validations
  # has no negative side-effects.
  def validate_associated_records_for_edition_organisations
    # no-op: prevent associated EditionOrganisation validations from running
  end

  def validate_associated_records_for_organisations
    # no-op: prevent associated Organisation validations from running
  end

private

  def at_least_one_lead_organisation
    if !skip_organisation_validation? && !edition_organisations.detect(&:lead?)
      errors.add(:lead_organisations, "at least one required")
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
      .map(&:organisation_id)

    if all_organisations.uniq.size != all_organisations.size
      errors.add(:organisations, "must be unique")
    end
  end

  def __mange_edition_organisations(new_organisation_ids, args = {})
    # try to avoid common AR pitfalls by reusing objects instead of
    # destroying & creating new.
    args = { for_lead: true }.merge(args)
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
        eo = edition_organisations.build(
          lead: for_lead,
          organisation_id: new_organisation_id,
          edition: self,
        )
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

  # rubocop:disable Naming/MemoizedInstanceVariableName
  #
  # This seems to result in false positives here, even if the variable
  # names are changed to start with __.

  def __edition_organisations_touched_by_lead_or_supporting_organisations_setters
    @edition_organisations_touched_by_lead_or_supporting_organisations_setters ||= []
  end

  def __edition_organisations_for_destruction_on_save
    @edition_organisations_for_destruction_on_save ||= []
  end

  # rubocop:enable Naming/MemoizedInstanceVariableName

  def mark_for_destruction_all_edition_organisations_for_destruction
    __edition_organisations_for_destruction_on_save.each(&:mark_for_destruction)
  end

  def clear_edition_organisations_touched_or_destroyed_by_lead_or_supporting_organisations_setters
    __edition_organisations_for_destruction_on_save.clear
    __edition_organisations_touched_by_lead_or_supporting_organisations_setters.clear
  end
end
