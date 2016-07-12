class WithdrawnNoticeDetailsSerializer < ActiveModel::Serializer
  attributes :explanation, :withdrawn_at

  def explanation
    if object.unpublishing.try(:explanation).present?
      Whitehall::GovspeakRenderer.new.govspeak_to_html(object.unpublishing.explanation)
    end
  end

  def withdrawn_at
    object.updated_at
  end
end
