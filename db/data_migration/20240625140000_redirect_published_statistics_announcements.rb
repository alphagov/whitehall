# Touching the statistics announcement triggers the after_touch callback, which sets up a redirect from the announcement
# to the data set if the data set has been published
StatisticsAnnouncement.published.find_each(&:touch)
