class PeopleController < PublicFacingController
  def show
    @person = PersonPresenter.decorate(Person.find(params[:id]))
  end

  def index
    @people = PersonPresenter.decorate(Person.all)
  end
end