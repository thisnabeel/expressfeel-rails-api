class FactoryMaterial < ActiveRecord::Base
    belongs_to :factory
    belongs_to :materialable, polymorphic: true, optional: true
    has_many :factory_material_details
    has_many :material_tags

    def dynamics
        factory = self.factory
        ds = factory.factory_dynamics

        table = {}
        ds.each do |d|
            table[d.title] = d.build(self.id)
        end

        return table
    end

    def dynamic(title, category, params = {})
        puts "TRYING TO DYNA: material: #{self.materialable_type}:#{self.materialable_id} -> #{title} using #{params}" 

        dyna = self.factory.factory_dynamics.find_by(title: title)
        puts 
        return "{err #{self.factory.materials_title}:#{title}}" if !dyna.present?
        return dyna.build(self.id, params)[category.to_sym]
    end
end
