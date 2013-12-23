# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Whitehall::Application.config.secret_token = 't6b8dc0c531aed727b5eafebc06a0e3a9b8280c462060fd26cded3d99474d5f58650f232a8b68dba2e75046ebc53c7f6351acabc6b2839a22add4ad6a2e531b68'

# TODO: Need to set this here and (and in deploy scripts) to transition from serialized cookies to encrypted ones.
Whitehall::Application.config.secret_key_base = '26113150c800c5a18b13196fd2c28e83095dbde9300f04a4acdde54859d738c50565ffee893c13169afa41d11c1bf0569052d85780db081e0b87aac4a307354f'
