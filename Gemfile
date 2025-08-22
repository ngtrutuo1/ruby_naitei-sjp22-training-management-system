source "https://rubygems.org"
git_source(:github) {|repo| "https://github.com/#{repo}.git"}

ruby "3.2.2"

gem "active_storage_validations", "0.9.8"

gem "bullet"

gem "i18n-js", "~> 4.2"

gem "omniauth"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "paranoia"
gem "rails", "~> 7.0.5"
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use mysql as the database for Active Record
gem "mysql2", "~> 0.5"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i(mingw mswin x64_mingw jruby)

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false
gem "bootstrap-sass", "3.4.1"

# Use Sass to process CSS
gem "sassc-rails"

gem "bcrypt", "~> 3.1.7"
gem "pagy"

# Figaro for environment variables management
gem "acts_as_list"
gem "figaro"
gem "mini_magick"
gem "whenever", require: false

gem "image_processing", "1.12.2"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html
  gem "debug", platforms: %i(mri mingw x64_mingw)
  gem "factory_bot_rails" # FactoryBot
  gem "rubocop", "~> 1.26", require: false
  gem "rubocop-checkstyle_formatter", require: false
  gem "rubocop-rails", "~> 2.14.0", require: false
  gem "shoulda-matchers", "~> 5.0"
  gem "simplecov"
  gem "simplecov-rcov"
end

group :development do
  gem "annotate"
  gem "faker", "2.21.0"
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "rspec-rails", "~> 5.0.0"
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end

# support i18n
gem "rails-i18n", "~> 7.0"

gem "config"
