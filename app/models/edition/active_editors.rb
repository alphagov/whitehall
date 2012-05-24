module Edition::ActiveEditors
  extend ActiveSupport::Concern

  included do
    has_many :recent_edition_openings, foreign_key: :edition_id, dependent: :destroy
  end

  def active_document_openings
    recent_edition_openings.active
  end

  def open_for_editing_as(editor)
    begin
      recent_edition_openings.create(editor: editor)
    rescue ActiveRecord::RecordNotUnique
      recent_edition_openings.where(editor_id: editor).each do |r| 
        r.update_attributes!(created_at: Time.zone.now)
      end
    end
  end
end