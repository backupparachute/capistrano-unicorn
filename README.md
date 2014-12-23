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

Add unicorn config and task hooks:

```ruby
# Lazy eval so the current_path is set properly
set(:unicorn_config)  { "#{current_path}/config/unicorn.rb" }
set(:unicorn_pid)     { "#{current_path}/tmp/pids/unicorn.pid" }
set(:unicorn_old_pid) { "#{current_path}/tmp/pids/unicorn.pid.oldbin" }

# Add Unicorn hooks
after "deploy:stop", "unicorn:stop"
after "deploy:stop", "unicorn:start"
after "deploy:restart", "unicorn:reload"
```
