module PublishingApiPresenters
  module WithdrawingHelper

  private

    def withdrawn_notice
      {
        explanation: unpublishing_explanation,
        withdrawn_at: item.updated_at
      }
    end

    def unpublishing_explanation
      if item.unpublishing.try(:explanation).present?
        Whitehall::GovspeakRenderer.new.govspeak_to_html(item.unpublishing.explanation)
      end
    end
  end
end
