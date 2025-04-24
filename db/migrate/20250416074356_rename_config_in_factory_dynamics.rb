class RenameConfigInFactoryDynamics < ActiveRecord::Migration[7.1]
  def change
    rename_column :factory_dynamics, :config, :flow_config
  end
end