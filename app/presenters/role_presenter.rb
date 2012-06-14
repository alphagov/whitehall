class RolePresenter < Draper::Base
  delegate :image, :name, :link, to: :current_person, prefix: :current_person

  def current_person
    if model.current_person
      PersonPresenter.decorate(model.current_person)
    else
      UnassignedPersonPresenter.new nil
    end
  end

  def url
    if ministerial?
      h.ministerial_role_url model
    end
  end

  def link
    if url
      h.link_to name, url
    else
      name
    end
  end

  class UnassignedPersonPresenter < PersonPresenter
    def name
      "No one is assigned to this role"
    end

    def link
      name
    end
  end
end