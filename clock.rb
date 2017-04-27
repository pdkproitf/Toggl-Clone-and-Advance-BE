require 'clockwork'
require 'clockwork/database_events'
require_relative './config/boot'
require_relative './config/environment'

module Clockwork
  # # required to enable database syncing support
  # Clockwork.manager = DatabaseEvents::Manager.new
  #
  # sync_database_events model: ::Scheduler, every: 1.minute do |scheduler|
  #   scheduler.clock_job.name.constantize.perform_later(scheduler.clock_job_arguments)
  # end

  handler do |job|
    puts "Running #{job}"
  end

  # every(30.seconds, 'Report sending') { SendReportJob.perform_later }
  every(1.day, 'Report sending', at: '12:39') { SendReportJob.perform_later }
  every(1.day, 'Update dayoff', at: '00:00') { EmployDayoffJob.perform_later }
  #
  # # every(1.day, 'midnight.job', :at => '00:00')
end
