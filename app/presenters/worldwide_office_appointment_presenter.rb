class WorldwideOfficeAppointmentPresenter < Draper::Base

  def path
  end

  def link
    model.job_title
  end

  def current_person
    PersonPresenter.decorate(model.person)
  end
end
