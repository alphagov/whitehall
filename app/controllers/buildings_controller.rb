class BuildingsController < PublicFacingController
  layout 'frontend'

  def show
    if valid_names.include?(params[:id])
      render template: "buildings/#{params[:id].underscore}"
    else
      render text: "Not found", status: :not_found
    end
  end

private
  def valid_names
    %w{
      king-charles-street
      lancaster-house
      10-downing-street
    }
  end
end
