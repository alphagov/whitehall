module ContentBlockManager
  module ContentBlock::Edition::HasAuditTrail
    extend ActiveSupport::Concern

    def self.acting_as(actor)
      original_actor = Current.user
      Current.user = actor
      yield
    ensure
      Current.user = original_actor
    end

    included do
      has_many :versions, -> { order(created_at: :desc, id: :desc) }, as: :item

      after_create :record_create
      after_update :record_update
    end

  private

    def record_create
      user = Current.user
      versions.create!(event: "created", user:)
    end

    def record_update
      unless draft?
        user = Current.user
        state = try(:state)
        versions.create!(event: "updated", user:, state:, changed_fields:)
      end
    end

    def changed_fields
      if document.editions.count <= 1
        nil
      else
        @previous_edition = document.editions[-2]
        diff = []
        diff.append(diff_for_lead_organisation)
        changed_attributes = diff_active_record
        if changed_attributes
          diff.append(diffs_for_user_generated_attributes(changed_attributes))
        end
        diff.compact.flatten!
      end
    end

    def diff_active_record
      user_generated_fields = %w[title instructions_to_publishers details]
      all_attributes = (@previous_edition.attributes.to_a - attributes.to_a).map(&:first)
      all_attributes & user_generated_fields
    end

    def diffs_for_user_generated_attributes(changed_attributes)
      changes = []
      changed_attributes.each do |attribute|
        if attribute == "details"
          changes.append(diffs_for_edition_details)
        else
          changes.append(ContentBlockManager::ContentBlock::Version::ChangedField.new(
                           field_name: attribute,
                           previous: @previous_edition[attribute],
                           new: self[attribute],
                         ))
        end
      end
      changes
    end

    def diffs_for_edition_details
      details_diff = []
      @previous_edition.details.each do |key, value|
        next unless value != details[key]

        details_diff.append(
          ContentBlockManager::ContentBlock::Version::ChangedField.new(
            field_name: key,
            previous: value,
            new: details[key],
          ),
        )
      end
      details_diff
    end

    def diff_for_lead_organisation
      previous_org = Organisation.find(@previous_edition.edition_organisation.organisation_id)
      new_org = lead_organisation
      return if new_org == previous_org

      ContentBlockManager::ContentBlock::Version::ChangedField.new(
        field_name: "lead_organisation",
        previous: previous_org.name,
        new: new_org.name,
      )
    end
  end
end
