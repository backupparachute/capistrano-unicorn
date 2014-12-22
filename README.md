# Capistrano Unicorn

Capistrano plugin that integrates Unicorn tasks into capistrano deployment script.

### Setup

Add the library to your `Gemfile`:

```ruby
gem 'capistrano-unicorn', :require => false
```

And load it into your deployment script `config/deploy.rb`:

```ruby
require 'capistrano-unicorn'
```

Add unicorn restart task hook:

```ruby
# Lazy eval so the current_path is set properly
set(:unicorn_config)  { "#{current_path}/config/unicorn.rb" }
set(:unicorn_pid)     { "#{current_path}/tmp/pids/unicorn.pid" }
set(:unicorn_old_pid) { "#{current_path}/tmp/pids/unicorn.pid.oldbin" }

# Add Unicorn restart hook
after "deploy:stop", "unicorn:stop"
after "deploy:stop", "unicorn:start"
after "deploy:restart", "unicorn:reload"
```

### Acknowledgements
loosely related to and inspired by https://github.com/sosedoff/capistrano-unicorn
