class Admin::PeopleController < Admin::BaseController
  def index
    @people = Person.order(:surname, :forename)
  end

  def new
    @person = Person.new
  end

  def create
    @person = Person.new(params[:person])
    if @person.save
      redirect_to admin_people_path, notice: %{"#{@person.name}" created.}
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
end