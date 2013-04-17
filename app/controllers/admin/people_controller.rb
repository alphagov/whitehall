class Admin::PeopleController < Admin::BaseController
  before_filter :load_person, only: [:show, :edit, :update, :destroy]
  def index
    @people = Person.order(:surname, :forename)
  end

  def new
    @person = Person.new
  end

  def create
    @person = Person.new(params[:person])
    if @person.save
      redirect_to [:admin, @person], notice: %{"#{@person.name}" created.}
    else
      render action: "new"
    end
  end

  def show
  end

  def edit
  end

  def update
    if @person.update_attributes(params[:person])
      redirect_to [:admin, @person], notice: %{"#{@person.name}" saved.}
    else
      render action: "edit"
    end
  end

  def destroy
    if @person.destroy
      redirect_to admin_people_path, notice: %{"#{@person.name}" destroyed.}
    else
      redirect_to admin_people_path, alert: "Cannot destroy a person with appointments"
    end
  end

  private

  def load_person
    @person = Person.find(params[:id])
  end
end
