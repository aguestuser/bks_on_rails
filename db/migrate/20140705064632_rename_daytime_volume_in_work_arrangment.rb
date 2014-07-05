class RenameDaytimeVolumeInWorkArrangment < ActiveRecord::Migration
  def change
    rename_column :work_arrangements, :day_time_volume, :daytime_volume
  end
end
