class EditionDependency < ApplicationRecord
  belongs_to :edition
  belongs_to :dependable, polymorphic: true

  # before_destroy :foo

  # EditionDependency seems to get destroyed by the `if @worldwide_office.destroy` in the controller
  # before we get a chance to intercept it :( 
  # def foo
  #   puts Thread.current.backtrace.join("\n")
  # end
end
