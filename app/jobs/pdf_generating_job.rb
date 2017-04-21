class PdfGeneratingJob < ApplicationJob
  queue_as :default

  def perform(member, begin_date, end_date)
    export = ExportController.new
    export.export_pdf(member, begin_date, end_date)
  end
end
