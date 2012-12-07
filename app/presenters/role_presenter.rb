class RolePresenter < Draper::Base
  delegate :image, :name, :link, to: :current_person, prefix: :current_person

  def current_person
    if model.current_person
      PersonPresenter.decorate(model.current_person)
    else
      UnassignedPersonPresenter.new nil
    end
  end

  def announcements
    return [] unless ministerial?
    announcements =
      AnnouncementPresenter.decorate(model.published_speeches.limit(10)).to_a +
      AnnouncementPresenter.decorate(model.published_news_articles.limit(10)).to_a
    announcements.sort_by { |a| a.display_date.to_datetime }.reverse[0..9]
  end
  
  def path
    if ministerial?
      h.ministerial_role_path model
    end
  end

  def link
    if path
      h.link_to name, path
    else
      ERB::Util.html_escape name
    end
  end

  def name_with_definite_article
    "The " + name
  end

  def published_policies
    PolicyPresenter.decorate(model.published_policies(limit: 10))
  end

  def previous_appointments
    RoleAppointmentPresenter.decorate model.previous_appointments
  end
  
  def responsibilities
    h.govspeak_to_html model.responsibilities
  end

  class UnassignedPersonPresenter < PersonPresenter
    def name
      "No one is assigned to this role"
    end

    def link
      name
    end

    def image_url(size)
      "blank-person.png"
    end

    def privy_counsellor?
      false
    end
  end
end
