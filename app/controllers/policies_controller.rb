class PoliciesController < ApplicationController
  def index
    @policies = Policy.all
  end
end