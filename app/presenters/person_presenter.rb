class PersonPresenter < Whitehall::Decorators::Decorator

  delegate_instance_methods_of Person

  def available_in_multiple_languages?
    translated_locales.length > 1
  end

  def translated_locales
    initial_locales = model.translated_locales
    roles = model.current_role_appointments.map(&:role)
    roles.reduce(initial_locales) do |locales, role|
      locales & role.translated_locales
    end
  end

  def current_role_appointments
    model.current_role_appointments.map {|ra| RoleAppointmentPresenter.new(ra, context) }
  end

  def previous_role_appointments
    model.previous_role_appointments.map { |ra| RoleAppointmentPresenter.new(ra, context) }
  end

  def current_ministerial_roles
    model.current_ministerial_roles.map { |role| RolePresenter.new(role, context) }
  end

  def has_policy_responsibilities?
    model.current_ministerial_roles.any? { |role| role.published_policies.any? }
  end

  def announcements
    announcements =
      model.published_speeches.with_translations(I18n.locale).limit(10).map { |s| SpeechPresenter.new(s, context) } +
      model.published_news_articles.with_translations(I18n.locale).limit(10).map { |na| NewsArticlePresenter.new(na, context) }
    announcements.sort_by { |a| a.public_timestamp.to_datetime }.reverse[0..9]
  end

  def speeches
    model.speeches.latest_published_edition.order("delivered_on desc").limit(10).map { |s| SpeechPresenter.new(s, context) }
  end

  def biography
    context.govspeak_to_html model.biography
  end

  def link
    name = ""
    name << "<span class='person-title'>The Rt Hon</span> " if privy_counsellor?
    name << "<strong>#{name_without_privy_counsellor_prefix}</strong>"
    context.link_to name.html_safe, path
  end

  def path
    context.person_path model
  end

  def image
    img = image_url(:s216) || 'blank-person.png'
    context.image_tag img, alt: name
  end
end
