$path = File.expand_path(File.dirname(__FILE__))

def render_file(path)
  file = IO.read(path)
end

def api_only_install
  api_only_modifications
  devise_auth?
end

def api_with_admin_install
  remove_turbolinks
  devise_auth?
  cucumber_capybara?
end

def integrated_app_install
  integrated_app_gemfile
  remove_turbolinks
  devise?
  cucumber_capybara?
end

def api_only_modifications
  api_remove_files
  gsub_file "app/controllers/application_controller.rb", /Base/, "API"
  gsub_file "app/controllers/application_controller.rb", /protect/, "# protect"
end

def api_remove_files
  remove_dir "app/helpers"
  remove_dir "app/views"
  remove_dir "app/assets/javascripts"
  remove_dir "app/assets/stylesheets"
end

def api_gemfile
  file "Gemfile", render_file("#{$path}/files/Gemfile_api_only")
end

def integrated_app_gemfile
  file "Gemfile", render_file("#{$path}/files/Gemfile")
end

def remove_turbolinks
  gsub_file 'app/assets/javascripts/application.js', /\/\/= require turbolinks/, ''
  gsub_file 'app/views/layouts/application.html.erb', /, 'data-turbolinks-track' => true/, ""
end

def add_gem_configs
  bundle
  rspec_config
  read_configs
  factory_girl_config
  database_cleaner_config
  shoulda_matchers_config
  code_climate_config
  tape_config
end

def bundle
  run 'bundle'
end

def rspec_config
  generate 'rspec:install'
end

def read_configs
  gsub_file 'spec/rails_helper.rb', /# Dir/, "Dir"
end

def factory_girl_config
  file 'spec/support/factory_girl.rb', render_file("#{$path}/files/factory_girl.rb")
end

def database_cleaner_config
  file 'spec/support/database_cleaner.rb', render_file("#{$path}/files/database_cleaner.rb")
end

def shoulda_matchers_config
  file 'spec/support/shoulda_matchers.rb', render_file("#{$path}/files/shoulda_matchers.rb")
end

def code_climate_config
  inside 'spec' do
    inject_into_file 'spec_helper.rb', after: "# users commonly want.\n" do <<-RUBY
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
    RUBY
    end
  end
end

def tape_config
  run 'tape installer install'
end

def generate_readme
  remove_file 'README.rdoc'
  file 'README.md', render_file("#{$path}/files/README.md")
  gsub_file 'README.md', /app_name/, app_name.upcase
end

def database_set_up
  remove_file "config/database.yml"
  file 'config/database.yml', render_file("#{$path}/files/database.yml")
  gsub_file 'config/database.yml', /app_name/, app_name
end

def travis_set_up
  run "cp config/database.yml config/database.example.yml"
  run "cp config/secrets.yml config/secrets.example.yml"
  file '.travis.yml', render_file("#{$path}/files/.travis.yml")
  gsub_file '.travis.yml', /app_name/, app_name
  file '.rubocop.yml', render_file("#{$path}/files/.rubocop.yml")
end

def git_ignore_append
  append_file '.gitignore' do <<-EOF

  # Ignore all secrets and database config files
  config/initializers/secret_token.rb
  config/secrets.yml
  config/database.yml
  EOF
  end
end

def smashing_docs?
  if yes?("Add smashing_docs for API documentation? (y/n)")
    @smashing_docs = true
    inject_into_file 'Gemfile', after: "group :development, :test do\n" do <<-RUBY
  # Use smashing_docs for API documentation
  gem 'smashing_docs'
    RUBY
    end
  end
end

def devise_auth?
  if yes?("Add devise_token_auth? (y/n)")
    @devise_auth = true
    inject_into_file 'Gemfile', after: "gem 'taperole'\n" do <<-RUBY
gem 'devise_token_auth'
    RUBY
    end
  end
end

def devise?
  if yes?("Add devise? (y/n)")
    @devise = true
    inject_into_file 'Gemfile', after: "gem 'taperole'\n" do <<-RUBY
gem 'devise'
    RUBY
    end
  end
end

def cucumber_capybara?
  if yes?("Add Cucumber and Capybara? (y/n)")
    @cucumber_capybara = true
    inject_into_file 'Gemfile', after: "group :development, :test do\n" do <<-RUBY
  # Use cucumber-rails for automated feature tests
  gem 'cucumber-rails', require: false
  # Use capybara-rails to simulate how a user interacts with the app
  gem 'capybara'
    RUBY
    end
  end
end

def install_optional_gems
  bundle if @smashing_docs || @devise || @devise_auth || @active_admin || @cucumber_capybara
  generate 'docs:install' if @smashing_docs
  generate 'devise:install' if @devise
  generate 'active_admin:install' if @active_admin
  generate 'cucumber:install' if @cucumber_capybara
end

# -----------------------------
# CREATE TEMPLATE
# -----------------------------
remove_file "Gemfile"
# -----------------------------
# API ONLY APP?
# -----------------------------
if yes?("Is this an API app? (y/n)")
  api_gemfile
  if yes?("Does this API app have an admin interface? (y/n)")
    api_with_admin_install
  else
    api_only_install
  end
else
  integrated_app_install
end
smashing_docs?
# -----------------------------
# DATABASE
# -----------------------------
database_set_up
travis_set_up
git_ignore_append
# -----------------------------
# GEM ADDITIONS (OPTIONAL)
# -----------------------------
add_gem_configs
install_optional_gems
# -----------------------------
# SETUP
# -----------------------------
remove_dir "test"
generate_readme
run 'rake db:create'
git :init
# -----------------------------
# COMPLETE
# -----------------------------
puts "\nSmashing-Template successfully created!"
