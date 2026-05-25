## STACK 
Rails version: Rails 8.1.3 sample todo app
Database: SQLite3
Frontend packages: ERB html templates, Jbuilder JSON views, Propshaft for assets, Hotwire/Turbo
Testframework: Rails MiniTest, Selenium for integration tests, Capybara for system tests
Background jobs/infra: Soild Queue, puma web server

## COMMANDS
bundle install 
bin/dev
bin/rails test
bin/rails test:system
bundle exec rubocop
bin/brakeman
bin/setup

## CONVENTIONS
Follow the standard rails convensions so as to avoid uneeded configuration. Use RESTful routes and resource views. Write shared partials wherever multiple pieces of the UI are the same across pages. Keep business logic out of views. 


## DONT'S
no new gems without approval
no inline javascript or css
no skip_before_action:verify_authenticity_token
run migrations whenever the schema is outdated
don't edit the db schema by hand, instead edit the migration files. 


