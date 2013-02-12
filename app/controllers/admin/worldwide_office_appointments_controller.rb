class Admin::WorldwideOfficeAppointmentsController < Admin::BaseController
  before_filter :find_worldwide_office
  before_filter :find_worldwide_office_appointment, only: [:edit, :destroy, :update]

  def new
    @worldwide_office_appointment = @worldwide_office.worldwide_office_appointments.new
  end

  def create
    @worldwide_office_appointment = @worldwide_office.worldwide_office_appointments.new(params[:worldwide_office_appointment])
    if @worldwide_office_appointment.save
      redirect_to [:appointments, :admin, @worldwide_office], notice: "Appointment created"
   else
      render :new
    end
  end

  def destroy
    @worldwide_office_appointment.destroy
    redirect_to [:appointments, :admin, @worldwide_office], notice: "Appointment deleted"
  end

  def edit
  end

  def update
    if @worldwide_office_appointment.update_attributes(params[:worldwide_office_appointment])
      redirect_to [:appointments, :admin, @worldwide_office], notice: "Appointment updated"
    else
      render :edit
    end
  end

  private

  def find_worldwide_office
    @worldwide_office = WorldwideOffice.find(params[:worldwide_office_id])
  end

  def find_worldwide_office_appointment
    @worldwide_office_appointment = @worldwide_office.worldwide_office_appointments.find(params[:id])
  end
end
