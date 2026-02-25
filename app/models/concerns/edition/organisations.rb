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
    has_many :edition_organisations, foreign_key: :edition_id, dependent: :destroy, autosave: true, validate: false
    has_many :organisations, -> { includes(:translations) }, through: :edition_organisations, validate: false

    validate :at_least_one_lead_organisation, if: :organisation_association_enabled?
    validate :no_duplication_of_organisations, if: :organisation_association_enabled?

    add_trait Trait
  end

  def sorted_organisations
    organisations.alphabetical
  end

  def lead_edition_organisations
    edition_organisations.select(&:lead?).sort { |a, b| a.lead_ordering <=> b.lead_ordering }
  end

  def supporting_edition_organisations
    edition_organisations.reject(&:lead?)
  end

  def lead_organisations
    lead_edition_organisations.map(&:organisation)
  end

  def supporting_organisations
    supporting_edition_organisations.map(&:organisation)
  end

  def lead_organisation_ids
    lead_organisations.pluck(:id)
  end

  def supporting_organisation_ids
    supporting_organisations.pluck(:id)
  end

  def lead_organisations=(new_lead_organisations)
    self.lead_organisation_ids = new_lead_organisations.map(&:id)
  end

  def supporting_organisations=(new_supporting_organisations)
    self.supporting_organisation_ids = new_supporting_organisations.map(&:id)
  end

  def lead_organisation_ids=(new_lead_organisation_ids)
    assign_organisation_ids(new_lead_organisation_ids, true)
  end

  def supporting_organisation_ids=(new_supporting_organisation_ids)
    assign_organisation_ids(new_supporting_organisation_ids, false)
  end

  def can_have_supporting_organisations?
    true
  end

  def organisation_association_enabled?
    true
  end

private

  def at_least_one_lead_organisation
    unless edition_organisations.detect(&:lead?)
      errors.add(:lead_organisations, "at least one required")
    end
  end

  def no_duplication_of_organisations
    all_organisation_ids = edition_organisations.reject(&:marked_for_destruction?).map(&:organisation_id)

    if all_organisation_ids.uniq.size != all_organisation_ids.size
      errors.add(:organisations, "must be unique")
    end
  end

  def assign_organisation_ids(new_organisation_ids, is_lead)
    # IDs from edition form come through as strings, so map to integers so they match DB values
    new_organisation_int_ids = new_organisation_ids.map(&:to_i)
    new_edition_organisations = []
    updated_edition_organisations = []
    existing_edition_organisations = edition_organisations.select { |eo| eo.lead == is_lead }

    new_organisation_int_ids.each_with_index do |organisation_id, index|
      existing_edition_organisation = existing_edition_organisations.find { |eo| eo.organisation_id == organisation_id }

      # If a matching edition already exists, update it once. If no matching edition exists, or a duplicate appears in the new IDs, then create
      # a new edition organisation. Updating the edition organisation again for a duplicate would
      # effectively silently drop user input.
      if existing_edition_organisation && updated_edition_organisations.exclude?(existing_edition_organisation)
        existing_edition_organisation.lead_ordering = index + 1 if is_lead

        new_edition_organisations << existing_edition_organisation
        updated_edition_organisations << existing_edition_organisation
      else
        attributes = {
          organisation_id:,
          lead: is_lead,
          lead_ordering: is_lead ? (index + 1) : nil,
        }
        new_edition_organisations << edition_organisations.build(attributes)
      end
    end

    # Add the other half of the existing edition organisations (lead if supporting, or vice versa)
    new_edition_organisations += edition_organisations.reject { |eo| eo.lead == is_lead }

    # Replace the existing edition organisations with the new list in memory using the Active Record Collection Proxy
    # replace method (https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-replace),
    # which effectively deletes any old edition organisations that were not present in the input.
    # We rely on the autosave attribute on the edition_organisations association to ensure these
    # changes are saved when the edition is saved.
    edition_organisations.replace(new_edition_organisations)
  end
end
