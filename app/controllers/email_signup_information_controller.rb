class EmailSignupInformationController < PublicFacingController
  def show
    if email_signup_pages.nil?
      render_not_found
    end

    @email_signup_information = EmailSignupInformationPresenter.new(
      organisation: organisation,
      email_signup_pages: email_signup_pages,
    )
  end

private

  def organisation
    Organisation.friendly.find(organisation_slug)
  end

  def organisation_slug
    params[:organisation_slug]
  end

  def email_signup_pages
    EmailSignupPagesFinder.find(organisation)
  end
end
