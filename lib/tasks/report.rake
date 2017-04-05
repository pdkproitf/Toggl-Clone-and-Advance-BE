# lib/tasks/report.rake
namespace :report do
  desc 'TODO'
  task mailweek: :environment do
    WeeklyWorker.perform_async WeeklyWorker::MAIL_MONTH
  end
end
