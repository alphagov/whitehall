class EmailSignupsController < PublicFacingController
  def new
    feed_url = email_signup_params['feed']

    if feed_url.match?(%r{/government/organisations/(.*)\.atom$})
      redirect_to email_alert_frontend_signup(feed_url)
    else
      @email_signup = EmailSignup.new(email_signup_params)
    end
  end

  def create
    @email_signup = EmailSignup.new(email_signup_params)

    if @email_signup.save
      redirect_to @email_signup.signup_url
    else
      render action: 'new'
    end
  end

private

  def email_signup_params
    params.require(:email_signup).permit(:feed)
  end

  def email_alert_frontend_signup(feed_url)
    base_path = URI.parse(feed_url).path.chomp('.atom')
    "/email-signup?link=#{base_path}"
  end
end
