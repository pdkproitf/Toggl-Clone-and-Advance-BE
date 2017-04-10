class ReportPdf < Prawn::Document
  def initialize(project)
    super(top_margin: 70)
    @project = project
    text "Report project \##{@project.name}"
  end
end
