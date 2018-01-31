class ScheduledPublishingChecker
  MISSING_EDITION = 'missing_edition'.freeze
  MISSING_REDIRECT = 'missing_redirect'.freeze
  SUCCESSFULLY_PUBLISHED = 'successfully_published'.freeze

  # scheduled tasks can only run at 0, 15, 30 and 45 minutes past the hour.
  # This job should be run scheduled to run 30seconds later so that documents
  # have a chance to be published first. In addition this job should run every
  # minutes to check if the document has now appeared - this is inline with the
  # healthcheck frequency
  def check
    start_date = MissedScheduledPublishing.maximum(:scheduled_publication) || 1.week.ago

    since_last_run = Edition.includes(:document).where("scheduled_publication > ? and scheduled_publication < ?", start_date, Time.zone.now)

    since_last_run.each do |edition|
      url = Whitehall.url_maker.public_document_url(edition)
      announcement_url = edition.respond_to?(:statistics_announcement) && edition.statistics_announcement.public_path

      status = check_url(url, announcement_url)

      MissedScheduledPublishing.create(
        url: url,
        announcement_url: announcement_url,
        scheduled_publication: edition.scheduled_publication,
        status: status,
        found_at_first_attempt: status == SUCCESSFULLY_PUBLISHED,
      )
    end

    MissedScheduledPublishing.where.not(status: SUCCESSFULLY_PUBLISHED).each do |missing|
      missing.update(status: SUCCESSFULLY_PUBLISHED) if check_url(missing.url, missing.announcement_url) == SUCCESSFULLY_PUBLISHED
    end

    nil
  end

  def check_url(url, announcement_url)
    # for the edition

    # check the page is present on the site
    if appears_on_site?(url)
      Rails.logger.info "Found scheduled publication for: #{url}"

      # if an announcement was made check that it has been correctly redirected.
      if !announcement_url || redirected?(announcement_url, url)
        SUCCESSFULLY_PUBLISHED
      else
        Rails.logger.info "Missing redirect to scheduled publication for: #{url}"
        MISSING_REDIRECT
      end
    else
      Rails.logger.info "Missing scheduled publication for: #{url}"
      MISSING_EDITION
    end
  end

  def connection
    @connection ||= Faraday.new(headers: { accept_encoding: 'none' }) do |faraday|
      faraday.adapter Faraday.default_adapter
      faraday.basic_auth(user, password) if ENV.has_key?("BASIC_AUTH_CREDENTIALS")
    end
  end

  def appears_on_site?(url)
    # TODO: Add functionality to determine correct version/redirect
    (200..399).cover?(connection.get(URI.parse(url)).status)
  end

  def redirected?(old_url, new_url)
    response = connection.get(URI.parse(old_url))

    (300..399).cover?(response.status) && # redirect
      [new_url, URI.parse(new_url).path].include?(response[:location])
  end
end
