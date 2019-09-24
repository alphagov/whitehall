class EmailSignupsController < PublicFacingController
  def new
    if non_finder_url
      redirect_to email_alert_frontend_signup
    elsif feed_url.match?(%r{/government/(publications|announcements|statistics)\.atom})
      redirect_to feed_url.sub(".atom", "")
    else
      redirect_to "/"
    end
  end

private

  def non_finder_url
    feed_url.match?(%r{/government/(organisations|ministers|people|topical-events)/.*\.atom$}) ||
      feed_url.match?(%r{/world/.*\.atom$})
  end

  def feed_url
    params.require(:email_signup).require(:feed)
  end

  def email_alert_frontend_signup
    base_path = URI.parse(feed_url).path.chomp(".atom")
    "/email-signup?link=#{base_path}"
  end
end
