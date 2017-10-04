event = TopicalEvent.find_by!(slug: "commonwealth-summit-2018")
Whitehall::SearchIndex.delete(event)

event.update_attributes!(slug: "commonwealth-heads-of-government-meeting-2018")
PublishingApiWorker.new.perform("TopicalEvent", event.id, "republish")
