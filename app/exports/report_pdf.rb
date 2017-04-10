class ReportPdf < Prawn::Document
  def initialize(project)
    super(top_margin: 70)
    @project = project
    text(@project.name.to_s)
    render_file("tmp/report_pdfs/#{@project.name}.pdf")
  end
end
