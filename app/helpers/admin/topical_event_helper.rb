module Admin::TopicalEventHelper

  def topical_event_tabs(topical_event)
    {
      "Details" => url_for([:admin, topical_event]),
      "Read more" => url_for([:about, :admin, topical_event]),
      "Features" => url_for([:admin, topical_event, :classification_featurings])
    }
  end
end
