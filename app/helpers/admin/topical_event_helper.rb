module Admin::TopicalEventHelper
  def topical_event_tabs(topical_event)
    {
      "Details" => url_for([:admin, topical_event]),
      "About page" => url_for([:admin, topical_event, :topical_event_about_pages]),
      "Features" => url_for([:admin, topical_event, :topical_event_featurings]),
    }
  end

  def topical_event_nav_items(topical_event, current_path)
    [
      {
        label: "Details",
        href: [:admin, topical_event],
        current: current_path == url_for([:admin, topical_event]),
      },
      {
        label: "About page",
        href: [:admin, topical_event, :topical_event_about_pages],
        current: current_path == url_for([:admin, topical_event, :topical_event_about_pages]),
      },
      {
        label: "Features",
        href: [:admin, topical_event, :topical_event_featurings],
        current: current_path == url_for([:admin, topical_event, :topical_event_featurings]),
      },
    ]
  end

  def duration_row_value(topical_event)
    if topical_event.start_date.present? && topical_event.end_date.present?
      "#{topical_event.start_date} to #{topical_event.end_date}"
    else
      ""
    end
  end
end
