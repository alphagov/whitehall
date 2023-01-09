class RolePresenter < Whitehall::Decorators::Decorator
  # NOTE: we use MinisterialRole because it's the subclass that adds
  # methods, if other Role subclasses do this we'll need to add their
  # methods to this array too
  delegate_instance_methods_of MinisterialRole
  delegate :image, :name, :link, to: :current_person, prefix: :current_person

  def current_person
    if model.current_person
      PersonPresenter.new(model.current_person, context)
    else
      UnassignedPersonPresenter.new(nil, context)
    end
  end

  def has_appointment?
    current_person.present?
  end

  def path
    if ministerial?
      model.public_path
    end
  end

  def link
    if path
      context.link_to(name, path, class: "govuk-link")
    else
      ERB::Util.html_escape name
    end
  end

  class UnassignedPersonPresenter < PersonPresenter
    def name
      I18n.t("roles.unassigned")
    end

    def link
      name
    end

    def present?
      false
    end

    def privy_counsellor?
      false
    end
  end
end
