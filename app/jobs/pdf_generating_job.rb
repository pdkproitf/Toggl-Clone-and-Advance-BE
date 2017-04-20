class PdfGeneratingJob < ApplicationJob
  queue_as :default

  def perform(member, begin_date, end_date)
    puts 'aaaaaaaaaaaaaaaaaaaaaa'
    export = ExportController.new
    puts export
    export.export_pdf(member, begin_date, end_date)
  end
end
