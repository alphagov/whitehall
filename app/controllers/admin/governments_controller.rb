class Admin::GovernmentsController < Admin::BaseController
  before_action :enforce_permissions!, except: :index

  def index
    @governments = Government.order(start_date: :desc)
  end

  def new
    @government = Government.new(start_date: Date.today)
  end

  def edit
    @government = Government.find(params[:id])
  end

  def create
    @government = Government.new(government_params)

    if @government.save
      redirect_to admin_governments_path, notice: 'Created government information'
    else
      render action: 'new'
    end
  end

  def update
    @government = Government.find(params[:id])

    if @government.update_attributes(government_params)
      redirect_to admin_governments_path, notice: 'Updated government information'
    else
      render action: 'edit'
    end
  end

  def prepare_to_close
    @government = Government.find(params[:id])
  end

  def close
    government = Government.find(params[:id])

    government.update_attribute(:end_date, Date.today) unless government.end_date

    current_active_ministerial_appointments.each do |appointment|
      appointment.update_attribute(:ended_at, government.end_date)
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
end
