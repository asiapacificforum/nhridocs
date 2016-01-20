require 'ostruct'
class ImpactRating < ActiveRecord::Base
  has_many :outreach_events
  # default values included here as a reference
  # used in a rake task to prepopulate the database table
  DefaultValues = [ OpenStruct.new(:rank => 1),
                    OpenStruct.new(:rank => 2),
                    OpenStruct.new(:rank => 3),
                    OpenStruct.new(:rank => 4),
                    OpenStruct.new(:rank => 5) ]

  include OutreachMediaMetric

  def as_json(options = {})
    super(:methods => [:rank_text], :except => [:rank, :created_at, :updated_at])
  end
end
