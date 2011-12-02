class SiteController < ApplicationController
  def sha
    render text: `git rev-parse HEAD`
  end
end