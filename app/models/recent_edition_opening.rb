class RecentEditionOpening < ApplicationRecord
  belongs_to :edition
  belongs_to :editor, class_name: "User"

  def self.activity_threshold
    2.hours.ago
  end

  def self.except_editor(excluded_editor)
    excluded_editor_id = excluded_editor.respond_to?(:id) ? excluded_editor.id : excluded_editor
    where(arel_table[:editor_id].not_eq(excluded_editor_id))
  end

  def self.active
    where("created_at >= ?", activity_threshold)
  end

  def self.expunge!
    where("created_at < ?", activity_threshold).delete_all
  end
end
