class Admin::GovernmentsController < Admin::BaseController
  before_action :enforce_permissions!, except: :index
  layout :get_layout

  def index
    @governments = Government.order(start_date: :desc)

    render_design_system("index", "legacy_index", next_release: true)
  end

  def new
    @government = Government.new(start_date: Time.zone.today)
    render_design_system("new", "legacy_new", next_release: true)
  end

  def edit
    @government = Government.find(params[:id])

    render_design_system("edit", "legacy_edit", next_release: true)
  end

  def create
    @government = Government.new(
      government_params.merge(content_id: SecureRandom.uuid),
    )

    if @government.save
      redirect_to admin_governments_path, notice: "Created government information"
    else
      render_design_system("new", "legacy_new", next_release: true)
    end
  end

  def update
    @government = Government.find(params[:id])

    if @government.update(government_params)
      redirect_to admin_governments_path, notice: "Updated government information"
    else
      render_design_system("edit", "legacy_edit", next_release: true)
    end
  end

  def prepare_to_close
    @government = Government.find(params[:id])

    render_design_system("prepare_to_close", "legacy_prepare_to_close", next_release: true)
  end

  def close
    government = Government.find(params[:id])

    government.update!(end_date: Time.zone.today) unless government.end_date

    current_active_ministerial_appointments.each do |appointment|
      appointment.ended_at = government.end_date
      appointment.save!(validate: false)
    end

    redirect_to edit_admin_government_path(government), notice: "Government closed"
  end

private

  def government_params
    params.require(:government).permit(:name, :start_date, :end_date)
  end

  def enforce_permissions!
    enforce_permission!(:manage, Government)
  end

  def current_active_ministerial_appointments
    RoleAppointment.current.for_ministerial_roles
  end
  helper_method :current_active_ministerial_appointments

  def get_layout
    design_system_actions = []
    design_system_actions += %w[index edit new create update prepare_to_close] if preview_design_system?(next_release: true)

    if design_system_actions.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end
end
