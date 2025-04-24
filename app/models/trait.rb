class Trait < ActiveRecord::Base
	belongs_to :universal
	has_many :traits

	has_many :language_traits
	has_many :languages, through: :language_traits

	belongs_to :trait

	after_create :update_code
    
	after_commit :flush_cache
	
	def self.make_articles(limit = 0)
		articles = []
		active = false
		while articles.count < limit
			active = !active
			t = Trait.all.sample
			pair = t.language_traits.where(active: active).where.not(body: [nil, "", "<p><br></p>"]).shuffle.combination(2).first
			next if !pair.present?
			articles.push({
				first: pair[0],
				second: pair[1],
				trait: pair[0].trait,
				active: active
			})
		end
		return articles.shuffle.first(limit)
	end


    def self.all_cached
        return Rails.cache.fetch('traits') {
			# Trait.all.order("position ASC").to_json
			Trait.all.order("position ASC").map{ |trait| trait.attributes.merge(
				{
					"active" => trait.language_traits
											.where.not(body: nil)
											.where.not(body: "<p></br></p>").present? ? true : false,
				}
			)}.to_json
        }
    end


	def update_code
	    if self.code.present?
	        return self.code
	    else
	        new_code = Trait.generate_code
	        self.update(code: new_code)
	        return new_code
	    end
	end


	def self.generate_code
	    code = rand(36**8).to_s(36)
	    while Trait.find_by_code(code).present? == true
	      code = rand(36**8).to_s(36)
	    end
	    return code
	end

	def languages
		self.language_traits.sort_by{|a| [a.language.title, a.language.title]}
	end

	def self.refresh_cache
		Rails.cache.delete('traits')
		return Trait.all_cached
	end

	def self.control_panel
		hash = {}
		hash["completed"] = []
		hash["incompleted"] = []
		Trait.all.each do |trait|
			Language.all.each do |language|
				lt = LanguageTrait.find_by(language_id: language.id, trait_id: trait.id)
				if lt.present? && (lt.body != nil) && (lt.body != "<p><br></p>")
					hash["completed"].push({
						language: language,
						trait: trait
					})
				else
					hash["incompleted"].push({
						language: language,
						trait: trait
					})
				end
			end
		end
		return hash
	end

	private
        
    def flush_cache
        Rails.cache.delete('traits')
    end
end
