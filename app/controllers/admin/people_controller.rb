class Admin::PeopleController < Admin::BaseController
  def index
    @people = Person.order(:surname, :forename)
  end

  def new
    @person = new_person
  end

  def create
    @person = Person.new(params[:person])
    if @person.save
      redirect_to post_create_path_for(@person), notice: %{"#{@person.name}" created.}
    else
      render action: "new"
    end
  end

  def edit
    @person = Person.find(params[:id])
  end

  def update
    @person = Person.find(params[:id])
    if @person.update_attributes(params[:person])
      redirect_to admin_people_path, notice: %{"#{@person.name}" saved.}
    else
      render action: "edit"
    end
  end

  def destroy
    @person = Person.find(params[:id])
    if @person.destroy
      redirect_to admin_people_path, notice: %{"#{@person.name}" destroyed.}
    else
      redirect_to admin_people_path, alert: "Cannot destroy a person with appointments"
    end
  end

  private

  def new_person
    if params[:worldwide_office_id] && worldwide_office = WorldwideOffice.find(params[:worldwide_office_id])
      Person.new(worldwide_office_appointment: WorldwideOfficeAppointment.new(worldwide_office: worldwide_office))
    else
      Person.new
    end
  end

  def post_create_path_for(person)
    person.worldwide_office ? people_admin_worldwide_office_url(person.worldwide_office) : admin_people_url
  end
end
