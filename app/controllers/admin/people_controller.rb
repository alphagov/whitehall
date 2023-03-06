class Admin::PeopleController < Admin::BaseController
  before_action :load_person, only: %i[show edit update destroy reorder_role_appointments update_order_role_appointments]
  before_action :enforce_permissions!, only: %i[edit update destroy reorder_role_appointments update_order_role_appointments]
  layout :get_layout

  def index
    @people = Person.order(:surname, :forename).includes(:translations)
    render :legacy_index
  end

  def new
    @person = Person.new
  end

  def create
    @person = Person.new(person_params)
    if @person.save
      redirect_to [:admin, @person], notice: %("#{@person.name}" created.)
    else
      render action: "new"
    end
  end

  def show; end

  def edit; end

  def update
    if @person.update(person_params)
      redirect_to [:admin, @person], notice: %("#{@person.name}" saved.)
    else
      render action: "edit"
    end
  end

  def destroy
    if @person.destroy
      redirect_to admin_people_path, notice: %("#{@person.name}" destroyed.)
    else
      redirect_to admin_people_path, alert: "Cannot destroy a person with appointments"
    end
  end

  def reorder_role_appointments
    @role_appointments = RoleAppointment.current.where(person_id: @person.id).order(:order)
  end

  def update_order_role_appointments
    current_role_appointment_orders = @person.current_role_appointments.map(&:order)

    params[:ordering].each do |appointment_row|
      id, order = appointment_row
      role_appointment = @person.role_appointments.find(id)
      role_appointment.update!(order: current_role_appointment_orders[order.to_i - 1])
    end

    flash[:notice] = "Role appointments reordered successfully"
    redirect_to admin_person_path(@person)
  end

private

  def get_layout
    if action_name.in?(%w[reorder_role_appointments update_order_role_appointments])
      "design_system"
    else
      "admin"
    end
  end

  def load_person
    @person = Person.friendly.find(params[:id])
  end

  def person_params
    params.require(:person).permit(
      :title,
      :forename,
      :surname,
      :letters,
      :image,
      :biography,
      :privy_counsellor,
    )
  end

  def enforce_permissions!
    if action_name.in?(%w[reorder_role_appointments update_order_role_appointments])
      enforce_permission!(:perform_administrative_tasks, @person)
    else
      enforce_permission!(:edit, @person)
    end
  end
end
