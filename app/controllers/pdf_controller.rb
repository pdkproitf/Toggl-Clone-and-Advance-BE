class PdfController < ApplicationController
  require 'zip'
  include PdfHelper
  def show
    @projects = Project.all.order(:name)
    @projects.each do |project|
      # respond_to do |format|
      #   format.html
      #   format.pdf do
      #     pdf = ReportPdf.new(project)
      #     send_data pdf.render, filename: "#{project.name}.pdf",
      #                           type: 'application/pdf',
      #                           disposition: 'inline'
      #   end
      # end

      pdf = Prawn::Document.new
      pdf.text(project.name.to_s)
      pdf.render_file("tmp/report_pdfs/#{project.name}.pdf")
    end
    folder = 'tmp/report_pdfs/'
    zipfile_name = 'tmp/reports.zip'
    # input_filenames = Dir.entries('tmp/report_pdfs/').select { |f| !File.directory? f }
    # Zip.continue_on_exists_proc = true
    # Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
    #   input_filenames.each do |filename|
    #     zipfile.add(filename, folder + '/' + filename)
    #   end
    #   zipfile.get_output_stream('myFile') { |os| os.write 'myFile contains just this' }
    # end
    zip_folder(folder, zipfile_name)
    send_file zipfile_name, type: 'application/zip',
                            disposition: 'attachment',
                            filename: 'reports.zip'
  end
end
