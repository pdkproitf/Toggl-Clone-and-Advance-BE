class RenameBillableToIsBillable < ActiveRecord::Migration[5.0]
    def change
        rename_column :project_categories, :billable, :is_billable
    end
end
