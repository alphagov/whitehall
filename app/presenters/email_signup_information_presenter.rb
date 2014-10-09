class EmailSignupInformationPresenter

  def initialize(dependencies = {})
    @organisation = dependencies.fetch(:organisation)
    @email_signup_pages = dependencies.fetch(:email_signup_pages)
  end

  attr_reader :email_signup_pages

  def title
    "Sign up to email alerts for the #{organisation.name}"
  end

private
  attr_reader :organisation
end
