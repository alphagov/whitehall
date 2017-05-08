class PastForeignSecretariesController < PublicFacingController
  layout 'frontend'

  def show
    if valid_names.include?(params[:id])
      render template: "past_foreign_secretaries/#{params[:id].underscore}"
    else
      render plain: "Not found", status: :not_found
    end
  end

private
  def valid_names
    %w(
      edward-wood
      austen-chamberlain
      george-curzon
      edward-grey
      henry-petty-fitzmaurice
      robert-cecil
      george-gower
      george-gordon
      charles-fox
      william-grenville
    )
  end
end
