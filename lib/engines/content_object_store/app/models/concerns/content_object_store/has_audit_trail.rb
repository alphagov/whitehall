module ContentObjectStore
  module HasAuditTrail
    extend ActiveSupport::Concern

    included do
      has_many :versions, -> { order(created_at: :desc, id: :asc) }, as: :item

      after_create :record_create
    end

  private

    def record_create
      user = Current.user
      versions.create!(event: "created", user:)
    end
  end
end
