class AddDefaultForTaskName < ActiveRecord::Migration[5.0]
    def change
        change_column_default :tasks, :name, ''
    end
end
