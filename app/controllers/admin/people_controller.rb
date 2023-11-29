class Admin::PeopleController < Admin::BaseController
  before_action :build_person, only: %i[new]
  before_action :load_person, only: %i[show edit update destroy reorder_role_appointments update_order_role_appointments confirm_destroy]
  before_action :enforce_permissions!, only: %i[edit update destroy reorder_role_appointments update_order_role_appointments confirm_destroy]
  before_action :build_dependencies, only: %i[new edit]
  before_action :clean_person_params, only: %i[create update]

  def index
    @people = Person.order(:surname, :forename).includes(:translations)
  end

  def new; end

  def create
    @person = Person.new(person_params)
    if @person.save
      redirect_to [:admin, @person], notice: %("#{@person.name}" created.)
    else
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @person.update(person_params)
      PresentPageToPublishingApiWorker.perform_async("PublishingApi::HistoricalAccountsIndexPresenter") if @person.current_or_previous_prime_minister?
      redirect_to [:admin, @person], notice: %("#{@person.name}" saved.)
    else
      render :edit
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

  def load_person
    @person = Person.friendly.find(params[:id])
  end

  def person_params
    @person_params ||= params.require(:person).permit(
      :title,
      :forename,
      :surname,
      :letters,
      :biography,
      :privy_counsellor,
      image_attributes: %i[file file_cache id],
    )
  end

  def enforce_permissions!
    if action_name.in?(%w[reorder_role_appointments update_order_role_appointments])
      enforce_permission!(:perform_administrative_tasks, @person)
    else
      enforce_permission!(:edit, @person)
    end
  end

  def build_person
    @person = Person.new
  end

  def build_dependencies
    @person.build_image if @person.image.blank?
  end

  def clean_person_params
    if person_params.dig(:image_attributes, :file_cache).present? && person_params.dig(:image_attributes, :file).present?
      person_params[:image_attributes].delete(:file_cache)
    end
  end
end
