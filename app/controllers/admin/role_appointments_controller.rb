class Admin::RoleAppointmentsController < Admin::BaseController
  before_filter :load_role_appointment, only: [:edit, :update, :destroy]

  def new
    role = Role.find(params[:role_id])
    @role_appointment = role.role_appointments.build
  end

  def create
    role = Role.find(params[:role_id])
    @role_appointment = role.role_appointments.build(params[:role_appointment])
    if @role_appointment.save
      redirect_to edit_admin_role_path(role), notice: "Appointment created"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @role_appointment.update_attributes(params[:role_appointment])
      redirect_to edit_admin_role_path(@role_appointment.role), notice: "Appointment has been updated"
    else
      render :edit
    end
  end

  def destroy
    if @role_appointment.destroyable?
      @role_appointment.destroy
      redirect_to edit_admin_role_path(@role_appointment.role), notice: "Appointment has been deleted"
    else
     flash.now[:alert] = "Appointment can not be deleted"
     render :edit
    end
  end

private
  def load_role_appointment
    @role_appointment = RoleAppointment.find(params[:id])
  end
end
