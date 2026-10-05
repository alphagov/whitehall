# frozen_string_literal: true

class Admin::Editions::ChangeNoteComponent < ViewComponent::Base
  include ApplicationHelper

  attr_reader :change_note

  def initialize(change_note:)
    @change_note = change_note
  end

private

  def actor
    change_note.actor ? linked_author(change_note.actor, class: "govuk-link") : "User (removed)"
  end

  def time
    absolute_time(change_note.created_at)
  end
end
