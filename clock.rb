require 'clockwork'
require 'clockwork/database_events'
require_relative './config/boot'
require_relative './config/environment'

module Clockwork
  # required to enable database syncing support
  Clockwork.manager = DatabaseEvents::Manager.new

  sync_database_events model: ::Scheduler, every: 1.minute do |scheduler|
    scheduler.clock_work.name.constantize.perform_later(event.job_arguments)
  end
end
