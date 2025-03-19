module ContentBlockManager
  module ContentBlock::Document::SoftDeletable
    extend ActiveSupport::Concern

    def soft_delete
      update_column :deleted_at, Time.zone.now
    end

    def soft_deleted?
      deleted_at.present?
    end
  end
end
