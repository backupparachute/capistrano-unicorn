require "capistrano/unicorn/version"

module Capistrano
  module Unicorn
    # Your code goes here...

    config = Capistrano::Configuration.instance

    if config

    config.load do
      # stuff here...

      _cset(:unicorn_config)  { "#{current_path}/config/unicorn.rb" }
      _cset(:unicorn_binary)  { "bundle exec unicorn_rails -c #{unicorn_config} -E #{rails_env} -D" }
      _cset(:unicorn_pid)     { "#{current_path}/tmp/pids/unicorn.pid" }
      _cset(:unicorn_old_pid) { "#{current_path}/tmp/pids/unicorn.pid.oldbin" }

      namespace :unicorn do
        desc "start unicorn"
        task :start, :roles => :app, :except => { :no_release => true } do
          puts "<><><><><><><><><><><><><> "
          puts "STARING UNICORN: #{unicorn_binary}..."
          run "cd #{current_path} && #{unicorn_binary}"
        end
        desc "stop unicorn"
        task :stop, :roles => :app, :except => { :no_release => true } do
          if pid_running?(unicorn_pid)
            run "kill `cat #{unicorn_pid}`"
          end
        end
        desc "graceful stop unicorn"
        task :graceful_stop, :roles => :app, :except => { :no_release => true } do
          if pid_running?(unicorn_pid)
            run "kill -s QUIT `cat #{unicorn_pid}`"
          end
        end
        desc "graceful stop OLD unicorn"
        task :graceful_stop_old, :roles => :app, :except => { :no_release => true } do
          if pid_running?(unicorn_old_pid)
            run "kill -s QUIT `cat #{unicorn_old_pid}`"
          end
        end
        desc "reload unicorn"
        task :reload, :roles => :app, :except => { :no_release => true } do
          if pid_running?(unicorn_pid)
            puts "UNICORN RUNNING, reloading"
            run "kill -s USR2 `cat #{unicorn_pid}`"
            unicorn.graceful_stop_old
          elsif remote_file_exists?(unicorn_pid)
            puts "REMOVING old UNICORN PID"
            run "rm #{unicorn_pid}"
            unicorn.start
          else
            unicorn.start
          end
        end
      end


      def remote_file_exists?(full_path)
        begin
          'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
        rescue
          puts "remote file DOES NOT exist..."
          return false
        end
      end

      def pid_running?(pid_file)
        begin
          retval = capture("ps -ef | grep `cat #{pid_file}` | grep -v grep").strip
          puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
          puts "PID RUNNING: #{retval}"
          puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
          return retval
        rescue
          puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
          puts "PID DOWN..."
          puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
          return false
        end
      end

    end


  end

  end
end
