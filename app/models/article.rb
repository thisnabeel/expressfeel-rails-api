class Article < ActiveRecord::Base
    before_save :save_slug
    belongs_to :user

    def save_slug
        self.slug = self.title.parameterize
    end
end
