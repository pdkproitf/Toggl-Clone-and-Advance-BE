class ReportPdf < Prawn::Document
  def initialize(project)
    super(top_margin: 70)
    @project = project.as_json
    # puts @project.to_json
    draw(@project)
    render_file("tmp/report_pdfs/#{@project[:name]}.pdf")
  end

  def draw(project)
    text(project[:name])
    puts '**********'
    categories = project[:categories].as_json
    # return
    categories.each do |category|
      # create a bounding box for the list-item label
      # float it so that the cursor doesn't move down
      float do
        bounding_box [15, cursor], width: 10 do
          text '•'
        end
      end

      # create a bounding box for the list-item content
      bounding_box [25, cursor], width: 600 do
        text category[:name]
        text category[:tracked_time].to_s
      end

      # provide a space between list-items
      move_down(5)
    end
  end
end
