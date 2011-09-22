class PoliciesController < ApplicationController
  def index
    @policies = Policy.published
  end
end