# frozen_string_literal: true

class Admin::Editions::FactCheckingTabComponent < ViewComponent::Base
  include ApplicationHelper

  attr_reader :edition, :send_request_section

  def initialize(edition:, send_request_section: false)
    @edition = edition
    @send_request_section = send_request_section
  end

private

  def completed_fact_check_requests
    @completed_fact_check_requests ||= edition.all_completed_fact_check_requests.includes(:edition)
  end

  def pending_fact_check_requests
    @pending_fact_check_requests ||= edition.fact_check_requests.pending
  end
end
