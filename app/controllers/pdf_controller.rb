class PdfController < ApplicationController
  require 'zip'
  include PdfHelper
  def show
    folder = 'tmp/report_pdfs'
    zipfile_name = 'reports.zip'
    zipfile_path = "tmp/#{zipfile_name}"

    FileUtils.rm_r zipfile_path if File.file?(zipfile_path)
    FileUtils.rm_r folder if File.directory?(folder)
    Dir.mkdir folder

    # @projects = Project.all.order(:name)
    # @projects.each do |project|
    #   ReportPdf.new(ProjectSerializer.new(project))
    # end

    start_date = '2017-03-27'.to_date
    end_date = start_date + 6
    report = ReportHelper::Report.new(Member.find(1), start_date, end_date)
    projects = report.report_by_project

    projects.each do |project|
      ReportPdf.new(project)
    end

    zip_folder(folder, zipfile_path)
    send_file zipfile_path, type: 'application/zip',
                            disposition: 'attachment',
                            filename: zipfile_name.to_s
  end
end
