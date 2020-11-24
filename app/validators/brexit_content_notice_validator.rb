class BrexitContentNoticeValidator < ActiveModel::Validator
  def validate(record)
    if record.show_brexit_no_deal_content_notice && record.show_brexit_current_state_content_notice
      record.errors[:transition_content_notice] << message
    end
  end

  def message
    "cannot have both show_brexit_no_deal_content_notice and show_brexit_current_state_content_notice"
  end
end
