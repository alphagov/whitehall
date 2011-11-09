class SupportingDocumentsController < ApplicationController
  before_filter :find_policy
  before_filter :find_supporting_document

  def show
  end

  private

  def find_policy
    unless @policy = Policy.published_as(params[:policy_id])
      render text: "Not found", status: :not_found
    end
  end

  def find_supporting_document
    @supporting_document = @policy.supporting_documents.find(params[:id])
  end
end