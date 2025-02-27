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
      include ContentBlock::Edition::Diffable

      has_many :versions, -> { order(created_at: :desc, id: :desc) }, as: :item

      after_create :record_create
      after_update :record_update
    end

    attr_accessor :updated_embedded_object_type, :updated_embedded_object_name

  private

    def record_create
      user = Current.user
      versions.create!(event: "created", user:)
    end

    def record_update
      unless draft?
        user = Current.user
        state = try(:state)
        versions.create!(
          event: "updated",
          user:, state:,
          field_diffs: generate_diff,
          updated_embedded_object_type:,
          updated_embedded_object_name:
        )
      end
    end
  end
end
