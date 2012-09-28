class Blog < ActiveRecord::Base
  acts_as_taggable
  attr_accessible :name, :description, :tag_list

  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :id, type: 'integer'
    indexes :name, type: 'string', analyzer: 'snowball', boost: 10
    indexes :description, type: 'string', analyzer: 'snowball'
    indexes :created_at, type: 'date'
    indexes :tag_list, type: 'string', analyzer: 'keyword'
  end

  def self.search(params)
    tire.search(load: true, page: params[:page], per_page: 2) do
      query do
        boolean do
          must { range :created_at, lte: Time.zone.now }
          must { string params[:query] } if params[:query].present?
          must { term :tag_list, params[:the_tag] } if params[:the_tag].present?
        end
      end
      sort { by :created_at, 'desc' } if params[:query].blank?
      facet 'tags' do
        terms :tag_list
      end
    end
  end

  def to_indexed_json
    to_json(methods: :tag_list)
  end
end
