class OutreachEvent < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include FileConstraints
  ConfigPrefix = 'outreach_event'

  belongs_to :impact_rating
  delegate :text, :rank, :rank_text, :to => :impact_rating, :prefix => true, :allow_nil => true
  has_many :reminders, :as => :remindable, :dependent => :destroy
  has_many :notes, :as => :notable, :dependent => :destroy
  has_many :outreach_event_areas
  has_many :areas, :through => :outreach_event_areas
  has_many :outreach_event_subareas
  has_many :subareas, :through => :outreach_event_subareas
  has_many :outreach_event_documents, :dependent => :destroy
  accepts_nested_attributes_for :outreach_event_documents
  belongs_to :audience_type
  has_many :outreach_event_performance_indicators, :dependent => :delete_all
  has_many :performance_indicators, :through => :outreach_event_performance_indicators
  accepts_nested_attributes_for :outreach_event_performance_indicators
  alias_method :performance_indicator_associations_attributes=, :outreach_event_performance_indicators_attributes=

  delegate :rank, :to => :impact_rating, :prefix => true, :allow_nil => true

  def as_json(options={})
    super({:except => [:updated_at,
                       :created_at,
                       :event_date ],
           :methods=> [:date,
                       :outreach_event_areas,
                       :outreach_event_documents,
                       :area_ids,
                       :subarea_ids,
                       :performance_indicator_associations,
                       :reminders,
                       :notes,
                       :create_reminder_url,
                       :create_note_url,
                       :impact_rating_rank_text,
                       :url ]})
  end

  def performance_indicator_associations
    outreach_event_performance_indicators
  end

  def create_url
    outreach_media_outreach_events_path(:en)
  end

  def url
    outreach_media_outreach_event_path(:en,id) if persisted?
  end

  def create_note_url
    outreach_media_outreach_event_notes_path(:en,id) if persisted?
  end

  def create_reminder_url
    outreach_media_outreach_event_reminders_path(:en,id) if persisted?
  end

  # date is stored in as UTC
  # client delivers the value in the local (client) time zone
  # and converts the database value to the local (client) time zone
  def date
    event_date.to_datetime.to_s if event_date # not sure why it's retrieved as an instance of Time, it should be DateTime, so convert it as a workaround
  end

  def date=(date)
    write_attribute(:event_date, DateTime.parse(date).utc)
  end

  def notable_url(notable_id)
    outreach_media_outreach_event_note_path('en',id,notable_id)
  end

  def remindable_url(remindable_id)
    outreach_media_outreach_event_reminder_path('en',id,remindable_id)
  end

end
