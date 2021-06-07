class EmailSignupInformationPresenter
  def initialize(dependencies = {})
    @organisation = dependencies.fetch(:organisation)
    @email_signup_pages = dependencies.fetch(:email_signup_pages)
  end

  attr_reader :email_signup_pages

  def title
    "#{organisation.acronym} #{I18n.t('organisation.email.alerts')}"
  end

  def summary
    "#{I18n.t('organisation.email.summary')} #{@organisation.acronym} (#{@organisation.name})."
  end

private

  attr_reader :organisation
end
