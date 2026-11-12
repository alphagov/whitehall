class Admin::WhatsNewController < Admin::BaseController
  def index
    @last_updated = I18n.t("admin.whats_new.recent_changes.updates").map { |update| Date.parse(update[:date]) }.max
  end
end
