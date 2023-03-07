class Admin::PeopleController < Admin::BaseController
  before_action :load_person, only: %i[show edit update destroy reorder_role_appointments update_order_role_appointments confirm_destroy]
  before_action :enforce_permissions!, only: %i[edit update destroy reorder_role_appointments update_order_role_appointments confirm_destroy]
  layout :get_layout

  def index
    @people = Person.order(:surname, :forename).includes(:translations)
    render_design_system(:index, :legacy_index, next_release: false)
  end

  def new
    @person = Person.new
    render_design_system(:new, :legacy_new, next_release: false)
  end

  def create
    @person = Person.new(person_params)
    if @person.save
      redirect_to [:admin, @person], notice: %("#{@person.name}" created.)
    else
      render_design_system(:new, :legacy_new, next_release: false)
    end
  end

  def show
    render_design_system(:show, :legacy_show, next_release: false)
  end

  def edit
    render_design_system(:edit, :legacy_edit, next_release: false)
  end

  def update
    if @person.update(person_params)
      redirect_to [:admin, @person], notice: %("#{@person.name}" saved.)
    else
      render_design_system(:edit, :legacy_edit, next_release: false)
    end
  end

  def confirm_destroy
    redirect_to [:admin, @person], alert: "Cannot destroy a person with appointments" unless @person.destroyable?
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
    design_system_actions = %w[reorder_role_appointments update_order_role_appointments]
    design_system_actions += %w[index show confirm_destroy new create edit update] if preview_design_system?(next_release: false)

    if action_name.in?(design_system_actions)
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
