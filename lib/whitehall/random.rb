module Whitehall::Random
  def base32(length = 8)
    number = SecureRandom.random_number(32 ** length)
    number.to_s(32).rjust(length, '0')
  end

  module_function :base32
end