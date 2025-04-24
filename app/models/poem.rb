class Poem < ActiveRecord::Base

	belongs_to :language

	def words
	    require 'nokogiri'
	    require 'open-uri'
	    require 'words_counted'

		# uri = 'http://stackoverflow.com/questions/2505104/html-to-plain-text-with-ruby'
		# doc = Nokogiri::HTML(open(uri))
		# doc.css('script, link').each { |node| node.remove }
		# puts doc.css('body').text.squeeze(" \n")

	    @text = Nokogiri::HTML(self.body).xpath('//text()').map(&:text).join(' ')


	    # tokeniser = WordsCounted::Tokeniser.new(@text)
	    # @words = tokeniser
	    # .tokenise(
	    # 	pattern: /[a-zA-ZA-zÀ-ú\-\'\œ\’]+/
	    # )
	    # .uniq

	    # return @words.sort_by(&:length).reverse

	    return @text.scan(/[a-zA-ZA-zÀ-ú\-\'\œ\’]+/).map(&:downcase).uniq.sort_by(&:length).reverse
	end

end
