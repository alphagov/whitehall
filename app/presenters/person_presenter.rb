class PersonPresenter < Draper::Base
  decorates :person

  def current_role_appointments
    RoleAppointmentPresenter.decorate person.current_role_appointments
  end

  def previous_role_appointments
    RoleAppointmentPresenter.decorate person.previous_role_appointments
  end

  def current_ministerial_roles
    RolePresenter.decorate person.current_ministerial_roles
  end

  def has_policy_responsibilities?
    person.current_ministerial_roles.any? { |role| role.published_policies.any? }
  end

  def announcements
    announcements =
      AnnouncementPresenter.decorate(person.published_speeches.limit(10)).to_a +
      AnnouncementPresenter.decorate(person.published_news_articles.limit(10)).to_a
    announcements.sort_by { |a| a.display_date.to_datetime }.reverse[0..9]
  end

  def speeches
    SpeechPresenter.decorate(person.speeches.latest_published_edition.order("delivered_on desc").limit(10))
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
