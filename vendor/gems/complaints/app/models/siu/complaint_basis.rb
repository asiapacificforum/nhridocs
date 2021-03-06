class Siu::ComplaintBasis < ComplaintBasis
  has_many :complaint_special_investigations_unit_complaint_bases
  include NamedList
  # included as a reference, and as source for complaint_basis_factory.rb
  # actual names are user-configured via admin
  DefaultNames = ["Unreasonable delay", "Abuse of process", "Not properly investigated"]
  validates :name, :uniqueness => true

  def self.i18n_key
    :special_investigations_unit
  end
end
