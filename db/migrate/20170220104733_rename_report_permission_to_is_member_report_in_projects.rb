class RenameReportPermissionToIsMemberReportInProjects < ActiveRecord::Migration[5.0]
    def change
        rename_column :projects, :report_permission, :is_member_report
        change_column :projects, :is_member_report, 'boolean USING CAST(is_member_report AS boolean)'
    end
end
