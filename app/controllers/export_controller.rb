class ExportController < ApplicationController
  require 'zip'
  include ZipHelper

  def export_pdf(member, begin_date, end_date)
    folder = 'tmp/report_pdfs'
    zipfile_name = 'reports.zip'
    zipfile_path = "tmp/#{zipfile_name}"

    FileUtils.rm_r zipfile_path if File.file?(zipfile_path)
    FileUtils.rm_r folder if File.directory?(folder)
    Dir.mkdir folder

    report = ReportHelper::Report.new(member, begin_date, end_date)
    @projects = report.report_by_project.as_json

    @projects.each do |project|
      html = render_to_string(layout: 'export_layout.html.erb', template: 'export/export.html.erb', locals: { project: project })
      save_path = "#{folder}/#{project[:name]}.pdf"
      save_pdf(html, save_path)
    end
    zip_folder(folder, zipfile_path)
    zipfile_path
  end

  def save_pdf(html, save_path)
    pdf = WickedPdf.new.pdf_from_string(html)
    File.open(save_path, 'wb') do |file|
      file << pdf
    end
  end
end
