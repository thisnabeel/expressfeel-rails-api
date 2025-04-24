class AddConfigToFactoryDynamics < ActiveRecord::Migration[7.1]
  def change
    add_column :factory_dynamics, :config, :jsonb
  end
end
