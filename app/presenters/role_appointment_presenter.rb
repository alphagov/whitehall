class RoleAppointmentPresenter < Draper::Base
  delegate :link, to: :role

  def role
    @role ||= RolePresenter.decorate(model.role)
  end
end