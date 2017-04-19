class ExportController < ApplicationController
  def download
    @projects = Project.all
    @projects.each do |project|
      html = render_to_string(layout: 'export_layout.html.erb', template: 'export/export.html.erb', locals: { project: project })
      save_path = Rails.root.join('pdfs', project[:name] + '.pdf')
      save_pdf(html, save_path)
    end
  end

  def save_pdf(html, save_path)
    pdf = WickedPdf.new.pdf_from_string(html)
    File.open(save_path, 'wb') do |file|
      file << pdf
    end
  end
end
