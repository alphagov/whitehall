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
      SpeechPresenter.decorate(person.published_speeches.limit(10)).to_a + 
      NewsArticlePresenter.decorate(person.published_news_articles.limit(10)).to_a
    announcements.sort_by { |a| a.display_date.to_datetime }.reverse[0..9]
  end

  def speeches
    SpeechPresenter.decorate(person.speeches.latest_published_edition.order("delivered_on desc").limit(10))
  end

  def biography
    h.govspeak_to_html person.biography
  end

  def link
    h.link_to name, path
  end

  def path
    h.person_path person
  end

  def image
    img = image_url || 'blank-person.png'
    h.image_tag img, alt: name
  end
end
