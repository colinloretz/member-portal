# frozen_string_literal: true

require 'slack-notifier'

# ActiveRecord posts
class Post < ApplicationRecord
  belongs_to :member
  belongs_to :category
  has_many :comments, dependent: :destroy
  after_create :create_slug, :send_to_slack

  validates :title, :content, :category_id, presence: true
  mount_uploader :image, PostImageUploader

  def to_param
    slug
  end

  def create_slug
    self.slug = [title.parameterize, id].join('-')
    save
  end

  def send_to_slack
    if Rails.application.secrets[:slack_active]
      slack_attachment = {
        fallback: 'A new conversation was started in the Member Portal',
        color: '#36a64f',
        pretext: 'A new conversation was started in the Member Portal',
        author_name: member.fullname,
        author_link: 'author url',
        author_icon: 'author icon',
        title: title,
        title_link: 'https://memberportal.renocollective.com/conversations/123',
        text: content.truncate(120, ' '),
        image_url: image_url.to_s,
        footer: 'Member Portal',
        footer_icon: 'https://platform.slack-edge.com/img/default_application_icon.png',
        ts: created_at.to_i
      }

      notifier = Slack::Notifier.new Rails.application.secrets[:slack_webhook_url]
      notifier.ping attachments: [slack_attachment]
    end
  end
end
