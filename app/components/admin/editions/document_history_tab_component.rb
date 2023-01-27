# frozen_string_literal: true

class Admin::Editions::DocumentHistoryTabComponent < ViewComponent::Base
  attr_reader :edition, :document_history, :editing

  def initialize(edition:, document_history:, editing: nil)
    @edition = edition
    @document_history = document_history
    @editing = editing
  end

private

  def entries_on_newer_editions
    @entries_on_newer_editions ||= document_history.entries_on_newer_editions(edition)
  end

  def entries_on_current_edition
    @entries_on_current_edition ||= document_history.entries_on_current_edition(edition)
  end

  def entries_on_previous_editions
    @entries_on_previous_editions ||= document_history.entries_on_previous_editions(edition)
  end

  def render_entry(entry)
    if entry.is_a?(EditorialRemark)
      render(Admin::Editions::EditorialRemarkComponent.new(editorial_remark: entry))
    else
      render(Admin::Editions::AuditTrailEntryComponent.new(entry:, edition:))
    end
  end
end
