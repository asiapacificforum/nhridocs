class Note < ActiveRecord::Base
  include ActionDispatch::Routing::PolymorphicRoutes
  include Rails.application.routes.url_helpers

  belongs_to :author, :class_name => "User", :foreign_key => :author_id
  belongs_to :editor, :class_name => "User", :foreign_key => :editor_id
  belongs_to :notable, :polymorphic => true

  default_scope ->{ order(:created_at => :desc) }

  def as_json(options = {})
    super(:methods => [:date, :author_name, :editor_name, :updated_on, :url])
  end

  def url
    #if defined? notable.namespace
      #puts "notable: #{notable.class.name} namespace #{notable.namespace} url: #{ polymorphic_path([notable.namespace,notable,self], :locale => :en)}"
      #polymorphic_path([notable.namespace,notable,self], :locale => :en)
    #elsif notable.respond_to?(:polymorphic_path) && (path = notable.polymorphic_path) # this scheme is used with indicators, due to more complex route nesting
      #puts "notable #{notable.class.name} path: #{path} url : #{polymorphic_path([path.prefix, self], path.keys.merge!({:locale => :en}))}"
      #polymorphic_path([path.prefix, self], path.keys.merge!({:locale => :en}))
    #else
      #puts "notable #{notable.class.name} #{polymorphic_path([notable.self], :locale => :en)}"
      #polymorphic_path([notable,self], :locale => :en)
    #end
    notable.notable_url(id)
  end

  def updated_on
    created_at.localtime.to_date.to_s(:short)
  end

  def date
    created_at.localtime.to_date.to_s(:short)
  end

  def author_name
    author.first_last_name
  end

  def editor_name
    editor.first_last_name
  end
end
