class AddSendReportAtToCompany < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :send_report_schedule, :string
  end
end
