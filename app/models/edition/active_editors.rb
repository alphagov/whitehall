module Edition::ActiveEditors
  extend ActiveSupport::Concern

  included do
    has_many :recent_edition_openings, foreign_key: :edition_id, dependent: :destroy
  end

  def active_edition_openings
    recent_edition_openings.active
  end

  def open_for_editing_as(editor)
    recent_edition_openings.create!(editor:)
  rescue ActiveRecord::RecordNotUnique
    recent_edition_openings.where(editor_id: editor).find_each do |r|
      r.update!(created_at: Time.zone.now)
    end
  end
end
