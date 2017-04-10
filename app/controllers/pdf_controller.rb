class PdfController < ApplicationController
  def show
    @projects = Project.all
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
      pdf.text(project.name.to_s + project.client.name.to_s)
      pdf.render_file("tmp/report_pdfs/#{project.name}.pdf")
    end
  end
end
