# See https://github.com/rails/rails/pull/3438

module FixBecomesToIncludeErrors
  def becomes(*args)
    instance = super(*args)
    instance.instance_variable_set("@errors", errors)
    instance
  end
end

ActiveRecord::Base.send(:include, FixBecomesToIncludeErrors)