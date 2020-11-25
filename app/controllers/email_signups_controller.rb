class EmailSignupsController < PublicFacingController
  def new
    if non_finder_url
      redirect_to email_alert_frontend_signup
    elsif feed_url.match?(%r{/government/(publications|announcements|statistics)\.atom})
      redirect_to feed_url.sub(".atom", "")
    elsif feed_url.match?(%r{/world/.*\.atom$})
      @email_signup = WorldLocationEmailSignup.new(feed_url)
      head :not_found unless @email_signup.valid?
    else
      redirect_to "/"
    end
  end

  def create
    @email_signup = WorldLocationEmailSignup.new(feed_url)

    if @email_signup.valid?
      redirect_to @email_signup.signup_url
    else
      head :not_found
    end
  end

private

  def non_finder_url
    feed_url.match?(%r{/government/(organisations|ministers|people|topical-events)/.*\.atom$})
  end

  def feed_url
    params.require(:email_signup).require(:feed)
  end

  def email_alert_frontend_signup
    base_path = URI.parse(feed_url).path.chomp(".atom")
    "/email-signup?link=#{base_path}"
  end
end
