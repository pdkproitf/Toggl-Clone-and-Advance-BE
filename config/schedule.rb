# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# Using the runner command loads an extra rails instance
# If you want to avoid this you can use the sidekiq-client-cli gem which is a commmand line sidekiq client
# Define a new job_type
job_type :sidekiq, 'cd :path && RAILS_ENV=:environment bundle exec sidekiq-client :task :output'

# Add the worker to the queue directly
every 1.minutes do
  command "echo 'hello' >> /home/code-engine-studio/output.txt"
  sidekiq 'push WeeklyWorker'
end
