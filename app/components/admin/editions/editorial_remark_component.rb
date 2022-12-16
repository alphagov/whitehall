# frozen_string_literal: true

class Admin::Editions::EditorialRemarkComponent < ViewComponent::Base
  include ApplicationHelper

  attr_reader :editorial_remark

  def initialize(editorial_remark:)
    @editorial_remark = editorial_remark
  end

private

  def actor
    editorial_remark.author ? linked_author(editorial_remark.author, class: "govuk-link") : "User (removed)"
  end

  def time
    absolute_time(editorial_remark.created_at)
  end
end
