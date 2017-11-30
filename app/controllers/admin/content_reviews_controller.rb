class Admin::ContentReviewsController < Admin::BaseController
  def update
    @review_by_date = Date.parse(params[:review_by].values.join("-"))

    response = RestClient.patch("http://127.0.0.1:3206/content/reviews", review_by: @review_by_date, content_id: params[:content_id])

    data = JSON.parse(response.body)

    @review_by_date = Date.parse(data['review_by'])

    edition = Edition.find(params[:id])
    @edition = LocalisedModel.new(edition, edition.primary_locale)

    respond_to do |format|
      format.js { render template: "admin/update" }
    end
  end
end
