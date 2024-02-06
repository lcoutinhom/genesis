# frozen_string_literal: true

authentication = yes?('User authentication?')

gem 'devise' if authentication

service = yes?('User service layer?')
if service
  gem 'service_actor'
  gem 'service_actor-rails'
  gem 'service_actor-promptable'
end

authorization = yes?('User authorization')
gem 'pundit' if authorization

audit = yes?('needs audition?')
if audit
  gem 'paper_trail'
  gem 'paper_trail-globalid'
end

lograge = yes?('going to use lorage')
if lograge
  gem 'lograge'

  initializer 'lograge.rb', <<-RUBY
    Rails.application.configure do
      config.lograge.enabled = true if Rails.env.production?
      # config.lograge.base_controller_class = 'ActionController::API'#{' '}
    end
  RUBY
end

gem 'paranoia' if yes?('going to use soft delete?')

gem 'after_commit_everywhere' if yes?('want to user after commit anywhere?')

gem 'active_period' if yes?('Do you want to handle easily?')

gem 'activerecord_where_assoc' if yes?('Do you want to handle exists SQL operations?')

strong_migrations = yes?('Do you wan to use strong migrations?')
gem 'strong_migrations' if strong_migrations

gem 'activerecord-safer_migrations' if yes?('Do you want to deal better migration timeouts?')
rspec = yes?('Do you want to deal with specs?')
gem_group :development, :test do
  gem 'rspec-rails' if rspec

  gem 'factory_bot_rails' if yes?('Do you want to deal with factories?')

  gem 'faker' if yes?('Do you want to create database records using faker')
end

gem_group :development do
  if yes?('Do you want to see better errors')
    gem 'better_errors'
    gem 'binding_of_caller'
  end

  gem 'database_consistency', require: false if yes?('Do you want to check the database consistency')
end

gem_group :test do
  shoulda_matchers = yes?('Do you want to use better spec matchers?')
  gem 'shoulda-matchers' if shoulda_matchers

  simplecov = yes?('Do you want to check the coverage')
  gem 'simplecov', require: false if simplecov
end

after_bundle do
  if rspec
    generate('rspec:install')

    file '.rspec', <<-CODE
      require 'spec_helper'
    CODE
  end

  if authentication
    generate('devise:install')
    devise_model = ask('Which device model do you want to install the devise?')

    environment 'config.action_mailer.default_url_options = {host: "localhost", port: 3000}', env: 'development'

    generate(:devise, devise_model) if devise_model.present?
  end

  generate('pundit:install') if authorization

  if audit
    with_changes = ask('Do you want paper trail create trail with changes?')
    with_changes.present? ? '--with-changes' : ''

    with_uuid = ask('Do you want paper trails with uuid?')
    with_uuid.present? ? '--uuid' : ''

    # TODO: check if possible set the database settings before it
    # generate("paper_trail:install", "#{with_changes} #{with_uuid}")
  end

  generate('strong_migrations:install') if strong_migrations
end
