class Admin::RoleAppointmentsController < Admin::BaseController
  before_action :load_role_appointment, only: %i[edit update destroy confirm_destroy]
  layout :get_layout

  def new
    role = Role.find(params[:role_id])
    @role_appointment = role.role_appointments.build(started_at: Time.zone.today)
    @current_appointment = params[:make_current]

    render_design_system("new", "legacy_new")
  end

  def create
    role = Role.find(params[:role_id])
    @role_appointment = role.role_appointments.build(role_appointment_params)
    if @role_appointment.save
      redirect_to edit_admin_role_path(role), notice: "Appointment created"
    else
      @current_appointment = params[:role_appointment][:make_current]
      render_design_system("new", "legacy_new")
    end
  end

  def edit
    render_design_system("edit", "legacy_edit")
  end

  def update
    if @role_appointment.update(role_appointment_params)
      redirect_to edit_admin_role_path(@role_appointment.role), notice: "Appointment has been updated"
    else
      render_design_system("edit", "legacy_edit")
    end
  end

  def confirm_destroy; end

  def destroy
    if @role_appointment.destroyable?
      @role_appointment.destroy!
      redirect_to edit_admin_role_path(@role_appointment.role), notice: "Appointment has been deleted"
    else
      flash.now[:alert] = "Appointment can not be deleted"
      render_design_system("edit", "legacy_edit")
    end
  end

private

  def load_role_appointment
    @role_appointment = RoleAppointment.find(params[:id])
  end

  def role_appointment_params
    params.require(:role_appointment).permit(
      :person_id, :started_at, :ended_at, :make_current
    )
  end

  def get_layout
    if preview_design_system?(next_release: true)
      "design_system"
    else
      "admin"
    end
  end
end
