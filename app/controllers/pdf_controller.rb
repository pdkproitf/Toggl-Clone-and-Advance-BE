class PdfController < ApplicationController
  require 'zip'
  include PdfHelper
  def show
    @projects = Project.all.order(:name)
    @projects.each do |project|
      pdf = ReportPdf.new(project)
    end
    folder = 'tmp/report_pdfs/'
    zipfile_name = 'reports.zip'
    zipfile_path = "tmp/#{zipfile_name}"
    zip_folder(folder, zipfile_name)
    send_file zipfile_path, type: 'application/zip',
                            disposition: 'attachment',
                            filename: zipfile_name.to_s
  end
end
