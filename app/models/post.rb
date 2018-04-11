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
    if ENV["SLACK_WEBHOOK_URL"]
      slack_attachment = {
        fallback: "Required plain-text summary of the attachment.",
        color: "#36a64f",
        pretext: "A new conversation was started in the Member Portal",
        author_name: "Author Name",
        author_link: "author url",
        author_icon: "author icon",
        title: "Hello World",
        title_link: "https://memberportal.renocollective.com/conversations/123",
        text: "Excerpt of the post here",
        image_url: "http://my-website.com/path/to/image.jpg",
        thumb_url: "http://example.com/path/to/thumb.png",
        footer: "Member Portal",
        footer_icon: "https://platform.slack-edge.com/img/default_application_icon.png",
        ts: 123456789
      }

      notifier = Slack::Notifier.new ENV["SLACK_WEBHOOK_URL"]
      notifier.ping attachments: [slack_attachment]
    end
  end
end
