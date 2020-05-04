class RoleAppointmentPresenter < Whitehall::Decorators::Decorator
  delegate_instance_methods_of RoleAppointment

  delegate :link, to: :role, prefix: true

  delegate :link, to: :person, prefix: true

  def role
    @role ||= RolePresenter.new(model.role, context)
  end

  def person
    @person ||= PersonPresenter.new(model.person, context)
  end

  def date_range
    date_range = []
    date_range << started_at.strftime("%Y") if started_at
    date_range << " to "
    date_range << ended_at.strftime("%Y") if ended_at
    date_range.join("").html_safe
  end
end
