class RolePresenter < Draper::Base
  delegate :image, :name, :link, to: :current_person, prefix: :current_person

  def current_person
    if model.current_person
      PersonPresenter.decorate(model.current_person)
    else
      UnassignedPersonPresenter.new nil
    end
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
      name
    end
  end

  def name_with_definite_article
    "The " + name
  end

  def policies
    PolicyPresenter.decorate(model.published_policies.order("published_at desc").limit(10))
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

    def image_url
      "blank-person.png"
    end
  end
end
