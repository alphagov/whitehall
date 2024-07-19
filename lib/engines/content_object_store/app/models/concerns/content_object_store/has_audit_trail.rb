module ContentObjectStore
  module HasAuditTrail
    extend ActiveSupport::Concern

    included do
      has_many :content_block_versions, -> { order(created_at: :asc, id: :asc) }, as: :item

      after_create :record_create
    end

  private

    def record_create
      user = Current.user
      content_block_versions.create!(event: "created", user:)
    end
  end
end
