class RoleAppointmentPresenter < Whitehall::Decorators::Decorator

  delegate_instance_methods_of RoleAppointment

  def role_link
    role.link
  end

  def person_link
    person.link
  end

  def role
    @role ||= RolePresenter.new(model.role, context)
  end

  def person
    @person ||= PersonPresenter.decorate(model.person)
  end

  def date_range
    date_range = []
    date_range << started_at.strftime("%Y") if started_at
    date_range << " to "
    date_range << ended_at.strftime("%Y") if ended_at
    date_range.join("").html_safe
  end
end
