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
          resp = pid_running?(unicorn_pid)
            # run "kill `cat #{unicorn_pid}`"
            
            find_servers_for_task(current_task).each do |current_server|
            
              # begin
              
                retval = scrub_exit_value(current_server.host, resp)
            
                puts " EVAL unicorn PID status for host: #{current_server.host} = #{retval}"
            
                if retval == 0
                  puts "#{current_server.host} :: UNICORN RUNNING, stopping..."
                  run "kill `cat #{unicorn_pid}`", :hosts => current_server.host
                end
            
            # rescue
            #     puts "#{current_server.host} :: ERROR processing UNICORN reload...."
            # end
            
            
            end # end of find servers
            
        end
        desc "graceful stop unicorn"
        task :graceful_stop, :roles => :app, :except => { :no_release => true } do
          # if remote_file_exists(unicorn_pid) && pid_running?(unicorn_pid)
          #   run "kill -s QUIT `cat #{unicorn_pid}`"
          # end
          
          resp = pid_running?(unicorn_pid)
          
          find_servers_for_task(current_task).each do |current_server|
          
            # begin
            
              retval = scrub_exit_value(current_server.host, resp)
          
              puts " EVAL unicorn PID status for host: #{current_server.host} = #{retval}"
          
              if retval == 0
                puts "#{current_server.host} :: UNICORN RUNNING, graceful stop..."
                run "kill -s QUIT `cat #{unicorn_pid}`", :hosts => current_server.host
              end
          
          # rescue
  #             puts "#{current_server.host} :: ERROR processing UNICORN reload...."
  #         end
          
          end # end of find servers
          
        end
        desc "graceful stop OLD unicorn"
        task :graceful_stop_old, :roles => :app, :except => { :no_release => true } do
          # if remote_file_exists(unicorn_old_pid) && pid_running?(unicorn_old_pid)
            # run "kill -s QUIT `cat #{unicorn_old_pid}`"
          # end
          
          resp = pid_running?(unicorn_old_pid)
          find_servers_for_task(current_task).each do |current_server|
          
            # begin
            
              retval = scrub_exit_value(current_server.host, resp)
          
              puts " EVAL unicorn PID status for host: #{current_server.host} = #{retval}"
          
              if retval == 0
                puts "#{current_server.host} :: UNICORN RUNNING, graceful stop OLD..."
                run "kill -s QUIT `cat #{unicorn_old_pid}`", :hosts => current_server.host
              end
          
          # rescue
   #            puts "#{current_server.host} :: ERROR processing UNICORN reload...."
   #        end
          
          end # end of find servers
        end
        desc "reload unicorn"
        task :reload, :roles => :app, :except => { :no_release => true } do
          
          resp = pid_running?(unicorn_pid)
          
          find_servers_for_task(current_task).each do |current_server|
            
            # begin
              
              retval = scrub_exit_value(current_server.host, resp[current_server.host])
            
              puts " EVAL unicorn PID status for host: #{current_server.host} = #{retval}"
            
              if retval == 0
                puts "#{current_server.host} :: UNICORN RUNNING, reloading"
                run "kill -s USR2 `cat #{unicorn_pid}`", :hosts => current_server.host
                puts "#{current_server.host} :: UNICORN RUNNING, killing old unicorn"
                run "kill -s QUIT `cat #{unicorn_old_pid}`", :hosts => current_server.host
              elsif retval == 2
                puts "#{current_server.host} :: NOT RUNNING, but file exists..."
                puts "#{current_server.host} :: REMOVING old UNICORN PID"
                run "rm #{unicorn_pid}", :hosts => current_server.host
                run "cd #{current_path} && #{unicorn_binary}", :hosts => current_server.host
              else
                puts "#{current_server.host} :: STARTING UNICORN...."
                run "cd #{current_path} && #{unicorn_binary}", :hosts => current_server.host
              end
            
          # rescue
          #     puts "#{current_server.host} :: ERROR processing UNICORN reload...."
          # end
            
            
          end # end of find servers
                  
        end #end of reload task
        
        def scrub_exit_value(host, val)
          retval = val || []
          
          puts " raw responses for host: #{host} = #{retval}"
          
          retval = retval.last unless retval.blank?
          retval = retval.strip unless retval.blank?
          retval = retval.to_i if !retval.blank? && retval.match(/\d+/)
          
          return retval || ""
        end #end of find_exit_value

      # def remote_file_exists?(full_path)
        # begin
        #   #'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
        #   # v = run("if [ -e #{full_path} ]; then echo true; else echo false; fi")
        #
        #   #results = {}
        #   retval = ""
        #   run "if [ -e #{full_path} ]; then echo 'true'; else echo 'false'; fi" do |channel, stream, data|
        #     return false if stream == :err
        #
        #     retval << data
        #     # if stream == :out
        #       #results[channel[:host]] = [] unless results.key?(channel[:host])
        #       # results[channel[:host]] << data if stream == :out
        #       # puts "remote file reponse: #{data}" if stream == :out
        #       # return 'true' == data.strip if stream == :out
        #     # end
        #   end
        #   puts "does file exist? #{retval}"
        #   return 'true' == retval.to_s
        # rescue
        #   puts "remote file DOES NOT exist..."
        #   return false
        # end
        
      # end # end of remote file exits

      def pid_running?(pid_file)
        begin
          results = {}
          #retval = capture("ps -ef | grep `cat #{pid_file}` | grep -v grep").strip
          puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
          # run("ps -ef | grep `cat #{pid_file}` | grep -v grep")
          # run("pgrep -P `cat #{pid_file}` && echo 0 || echo 1")
          run "if [ -e #{pid_file} ]; then pgrep -P `cat #{pid_file}` && echo 0 || echo 2; else echo 1; fi" do |channel, stream, data|

            results[channel[:host]] = [] unless results.key?(channel[:host])
            results[channel[:host]] << data if stream == :out
            results[channel[:host]] = data if stream == :err
            next if stream == :err
          
          
            # run "ps -ef | grep `cat #{pid_file}` | grep -v grep" do |channel, stream, data|
        #       puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
            puts "#{channel[:host]} --> #{data}"
        #       puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        #       return data.strip if stream == :out
          end
          puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
          return results
        rescue
          puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
          puts "PID DOWN..."
          puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
          return false
        end # end begin / rescue
      end # end of pid_running



    end # end of namespace

  end #end of config if
end
end
  
end
