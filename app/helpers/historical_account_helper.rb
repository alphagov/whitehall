module HistoricalAccountHelper
  def historical_fact(title, text)
    return if text.blank?
    content_tag(:h3, title) + content_tag(:p, text)
  end

  def historical_account_path(historical_account, role=nil)
    return unless historical_account
    role ||= historical_account.role
    url_for({ controller: '/historic_appointments', action: :show, role: role.historic_param, person_id: historical_account.person })
  end
end
