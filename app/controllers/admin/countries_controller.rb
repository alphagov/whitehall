class Admin::CountriesController < Admin::BaseController
  def index
    @countries = Country.all
  end

  def edit
    @country = Country.find(params[:id])
  end

  def update
    @country = Country.find(params[:id])
    if @country.update_attributes(params[:country])
      redirect_to admin_countries_path, notice: "Country updated successfully"
    else
      render action: :edit
    end
  end
end