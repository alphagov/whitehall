class Admin::RoleAppointmentsController < Admin::BaseController
  before_action :load_role_appointment, only: %i[edit update destroy confirm_destroy]
  before_action :build_role_appointment, only: %i[create]
  before_action :enforce_permissions!, only: %i[create edit update destroy]

  def new
    role = Role.find(params[:role_id])
    @role_appointment = role.role_appointments.build(started_at: Time.zone.today)
    @current_appointment = params[:make_current]
  end

  def create
    if @role_appointment.save
      redirect_to edit_admin_role_path(@role_appointment.role), notice: "Appointment created"
    else
      @current_appointment = params[:role_appointment][:make_current]
      render :new
    end
  end

  def edit; end

  def update
    if @role_appointment.update(role_appointment_params)
      redirect_to edit_admin_role_path(@role_appointment.role), notice: "Appointment has been updated"
    else
      render :edit
    end
  end

  def confirm_destroy; end

  def destroy
    if @role_appointment.destroyable?
      @role_appointment.destroy!
      redirect_to edit_admin_role_path(@role_appointment.role), notice: "Appointment has been deleted"
    else
      flash.now[:alert] = "Appointment can not be deleted"
      render :edit
    end
  end

private

  def enforce_permissions!
    enforce_permission!(:administer, @role_appointment)
  end

  def load_role_appointment
    @role_appointment = RoleAppointment.find(params[:id])
  end

  def build_role_appointment
    role = Role.find(params[:role_id])
    @role_appointment = role.role_appointments.build(role_appointment_params)
  end

  def role_appointment_params
    params.require(:role_appointment).permit(
      :person_id, :started_at, :ended_at, :make_current
    )
  end
end
