class Machine < ActiveRecord::Base
    belongs_to :language
    has_many :reactions

    serialize :allowed_inputs, coder: JSON

    def self.make
        Machine.all.destroy_all
        Factory.where.not(reactions_title: nil).each do |factory|
            puts factory.reactions_title
            m = Machine.find_or_create_by(language_id: factory.language_id, title: factory.reactions_title)
            factory.reactions.update_all(machine_id: m.id)
        end
    end

end