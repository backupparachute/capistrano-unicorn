# Capistrano::Unicorn

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-unicorn', :git => 'git://github.com/backupparachute/capistrano-unicorn.git'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-unicorn

## Usage

load it into your deployment script `config/deploy.rb`:

```ruby
require 'capistrano/unicorn'
```

Add unicorn task hooks:

```ruby
# Add Unicorn hooks
after "deploy:stop", "unicorn:stop"
after "deploy:stop", "unicorn:start"
after "deploy:restart", "unicorn:reload"
```

Properties are set by default, but you can override them.  
Make sure to lazy load the properties so they work with multistage.

```ruby
set(:unicorn_config)  { "#{current_path}/config/unicorn.rb" }
set(:unicorn_binary)  { "bundle exec unicorn_rails -c #{unicorn_config} -E #{rails_env} -D" }
set(:unicorn_pid)     { "#{current_path}/tmp/pids/unicorn.pid" }
set(:unicorn_old_pid) { "#{current_path}/tmp/pids/unicorn.pid.oldbin" }
```
