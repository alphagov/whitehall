require "thor"

module Confirm
  def self.ask(message)
    Thor::Shell::Basic.new.yes?(message)
  end
end
