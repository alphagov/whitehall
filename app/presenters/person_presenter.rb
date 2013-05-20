class PersonPresenter < Draper::Base
  decorates :person

  def available_in_multiple_languages?
    translated_locales.length > 1
  end

  def translated_locales
    initial_locales = person.translated_locales
    roles = person.current_role_appointments.map(&:role)
    roles.reduce(initial_locales) do |locales, role|
      locales & role.translated_locales
    end
  end

  def current_role_appointments
    person.current_role_appointments.map {|ra| RoleAppointmentPresenter.new(ra, h) }
  end

  def previous_role_appointments
    person.previous_role_appointments.map { |ra| RoleAppointmentPresenter.new(ra, h) }
  end

  def current_ministerial_roles
    person.current_ministerial_roles.map { |role| RolePresenter.new(role, h) }
  end

  def has_policy_responsibilities?
    person.current_ministerial_roles.any? { |role| role.published_policies.any? }
  end

  def announcements
    announcements =
      person.published_speeches.limit(10).map { |s| SpeechPresenter.new(s, h) } +
      person.published_news_articles.limit(10).map { |na| NewsArticlePresenter.new(na, h) }
    announcements.sort_by { |a| a.public_timestamp.to_datetime }.reverse[0..9]
  end

  def speeches
    person.speeches.latest_published_edition.order("delivered_on desc").limit(10).map { |s| SpeechPresenter.new(s, h) }
  end

  def biography
    h.govspeak_to_html person.biography
  end

  def link
    name = ""
    name << "<span class='person-title'>The Rt Hon</span> " if privy_counsellor?
    name << "<strong>#{name_without_privy_counsellor_prefix}</strong>"
    h.link_to name.html_safe, path
  end

  def path
    h.person_path person
  end

  def image
    img = image_url(:s216) || 'blank-person.png'
    h.image_tag img, alt: name
  end
end
