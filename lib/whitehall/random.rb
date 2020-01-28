module Whitehall::Random
  def self.base32(length = 8)
    number = SecureRandom.random_number(32**length)
    number.to_s(32).rjust(length, "0")
  end
end
