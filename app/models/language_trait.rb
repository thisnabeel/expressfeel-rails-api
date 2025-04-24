class LanguageTrait < ActiveRecord::Base
  belongs_to :language
  belongs_to :trait

  has_many :games, as: :gameable

  def crawl
  	crawler = self.crawler
  	lang_id = self.language_id
  	phrases = Phrase.where(language_id: lang_id)
  	.where('title ILIKE ? OR title ILIKE ?', "%#{crawler}%", "%#{crawler}%")
  	return phrases
  end

  def self.popular
	return LanguageTrait.where
		.not(body: [nil, "<p><br></p>"])
  end

end
