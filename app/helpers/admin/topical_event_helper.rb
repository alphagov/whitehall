module Admin::TopicalEventHelper

  def topical_event_tabs(topical_event)
    {
      "Details" => url_for([:admin, topical_event]),
      "Read more" => url_for([:admin, topical_event, :about_pages]),
      "Features" => url_for([:admin, topical_event, :classification_featurings])
    }
  end
end
