module Admin::TopicalEventsHelper
  def topical_event_contents_breakdown(topical_event)
    capture do
      concat tag.span(pluralize(topical_event.published_detailed_guides.count, "published detailed guide"))
    end
  end
end
