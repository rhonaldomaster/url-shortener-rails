class Url < ApplicationRecord
  belongs_to :user, optional: true # Una URL puede no tener un usuario asociado al principio
  has_many :clicks

  validates :original_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
  validates :short_code, presence: true,
                       uniqueness: true,
                       format: { with: /\A[a-zA-Z0-9_-]+\z/, message: "only allows letters, numbers, hyphens and underscores" },
                       allow_blank: true
  validate :prevent_circular_urls
  validate :expiration_must_be_in_future, on: :create

  before_validation :generate_short_code, on: :create

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  private

  def generate_short_code
    self.short_code ||= SecureRandom.alphanumeric(6)
  end

  def prevent_circular_urls
    return if original_url.blank?

    app_host = Rails.application.config.x.app_host
    if original_url.include?(app_host)
      errors.add(:original_url, "can't be a circular reference to your own site")
    end
  end

  def expiration_must_be_in_future
    return if expires_at.blank?

    if expires_at < Time.current
      errors.add(:expires_at, "must be in the future")
    end
  end
end
