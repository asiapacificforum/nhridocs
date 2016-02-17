class InternalDocument < ActiveRecord::Base
  ConfigPrefix = 'corporate_services.internal_documents'

  belongs_to :document_group, :counter_cache => :archive_doc_count
  delegate :created_at, :to => :document_group, :prefix => true
  belongs_to :user
  alias_method :uploaded_by, :user

  attachment :file

  default_scope ->{ order(:revision_major, :revision_minor) }

  before_save do |doc|
    if doc.title.blank?
      doc.title = doc.original_filename.split('.')[0]
    end

    # it's an InternalDocument that has been edited to an AccreditationRequiredDoc
    # or an AccreditationRequiredDoc being created
    if AccreditationDocumentGroup.pluck(:title).include?(doc.title)
      AccreditationRequiredDocCallbacks.new.before_save(doc)
    else
      doc.document_group_id = DocumentGroup.create.id if doc.document_group_id.blank?
    end

    if doc.revision_major.nil?
      doc.revision = document_group.next_minor_revision
    end
  end

  after_destroy do |doc|
    # if it's the last document in the group, delete the group too
    if doc.document_group.reload.empty?
      doc.document_group.destroy unless doc.document_group.is_a?(AccreditationDocumentGroup)
    end
  end

  after_save do |doc|
    if doc.document_group_id_changed? && doc.document_group_id_was.present?
      if (empty_group = DocumentGroup.find(doc.document_group_id_was)).internal_documents.count.zero?
        empty_group.destroy
      end
    end
  end

  def as_json(options = {})
    super(:except => [:created_at, :updated_at],
          :methods => [:revision,
                       :uploaded_by,
                       :url,
                       :formatted_modification_date,
                       :formatted_creation_date,
                       :formatted_filesize,
                       :type,
                       :archive_files] )
  end

  def url
    if persisted?
      Rails.application.routes.url_helpers.corporate_services_internal_document_path(I18n.locale, self)
    end
  end

  def formatted_modification_date
    lastModifiedDate.to_s
  end

  def formatted_creation_date
    created_at.to_s
  end

  def formatted_filesize
    ActiveSupport::NumberHelper.number_to_human_size(filesize)
  end

  def <=>(other)
    [revision_major, revision_minor] <=> [other.revision_major, other.revision_minor]
  end

  def self.maximum_filesize
    SiteConfig[ConfigPrefix+'.filesize']*1000000
  end

  def self.permitted_filetypes
    SiteConfig[ConfigPrefix+'.filetypes'].to_json
  end

  # called from the initializer: config/intializers/internal_document.rb
  # hmmmm... don't see it there, maybe it's obsolete... TODO check this
  def self.upload_document_attributes=(attrs)
    attrs.each do |k,v|
      cattr_accessor k
      send("#{k}=",v)
    end
  end

  def document_group_primary
    document_group && document_group.primary
  end

  def document_group_primary?
    document_group_primary == self
  end

  def revision
    revs = [revision_major, revision_minor]
    revs.join('.') unless revs.all?(&:blank?)
  end

  def revision=(val)
    self.revision_major, self.revision_minor = val.split('.').map(&:to_i) if val
  end

  def primary?
    document_group_primary == self
  end

  def archive_files
    if primary?
      document_group.internal_documents.reject{|doc| doc == self}
    else
      []
    end
  end

  def archive_files=(files)
    files.each do |file|
      file[:document_group_id] = document_group_id
      self.class.create(file)
    end
  end

  def has_revision?
    revision_major.is_a?(Integer)
  end

  def has_archive_files?
    archive_files.count > 0
  end

  def next_minor_revision
    [revision_major, revision_minor.succ].join('.')
  end

end
