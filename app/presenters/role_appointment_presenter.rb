class RoleAppointmentPresenter < Draper::Base
  def role_link
    role.link
  end

  def person_link
    person.link
  end

  def role
    @role ||= RolePresenter.decorate(model.role)
  end

  def person
    @person ||= PersonPresenter.decorate(model.person)
  end

  def date_range
    date_range = []
    date_range << started_at.strftime("%Y") if started_at
    date_range << " &ndash; "
    date_range << ended_at.strftime("%Y") if ended_at
    date_range.join("").html_safe
  end
end