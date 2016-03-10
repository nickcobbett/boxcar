# Guide to Creating a New Rails App

This app contains a Rails template with all the default settings for best practices at Smashing Boxes.

## Directions
Run using
* rails new APP_NAME -m smashing-template.rb

## Details

* Gemfile:
  For all environments:
  - All Rails default gems
  - Postgresql rather than sqlite3
  - Unicorn
  - Taperole

  For test and development:
  - rspec-rails
  - factory_girl_rails
  - database_cleaner
  - pry-byebug
  - awesome_print
  - rubocop
  - shoulda-matchers
  - codeclimate-test-reporter

  For development only:
  - web-console
  - spring

The following are removed:
* Turbolinks, from:
  - Gemfile
  - /application.js
  - /application.html.erb
* Test folder
* README.rdoc

The following are created:
* README.md, containing the app name
* All files generated by 'rspec:install'
* All files generated by 'tape installer install'
* A database.yml file with postgreslq config
* A rubocop.yml file with Ruby linting regulations

The following files are added to .gitnore:
* config/initializers/secret_token.rb
* config/secrets.yml
* config/database.yml

The following Travis files are created:
* .example files for both database and secrets
* .travis.yml file with all commands, including running rubocop as a local linter

The following configs are inserted:
Within 'rails_helper.rb'
* FactoryGirl gem
* DatabaseCleaner gem
* ShouldaMatchers gem
Within 'spec_helper.rb'
* CodeClimate gem

The following additional are optional:
* SmashingDocs
  - If you respond with 'yes':
    - The gem will be added into your Gemfile
    - All files and configs generated by 'docs:install' will be added
* Devise
  - If you respond with 'yes':
    - The gem will be added into your Gemfile
    - All files and configs generated by 'devise:install' will be added
* ActiveAdmin
- If you respond with 'yes':
  - The gem will be added into your Gemfile
  - If you do not yet have devise, that too will be added into your Gemfile
  - All files and configs generated by 'activeadmin:install' will be added
* Cucumber & Capybara
- If you respond with 'yes':
  - The gems will be added into your Gemfile
  - All files and configs generated by 'cucumber:install' will be added

# Finally, the git repository is initialized with the command 'git init'