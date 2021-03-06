class Update < ActiveRecord::Base
  extend CatarseAutoHtml

  belongs_to :user
  belongs_to :project
  has_many :notifications, dependent: :destroy
  validates_presence_of :user_id, :project_id, :comment, :comment_html

  catarse_auto_html_for field: :comment, video_width: 560, video_height: 340

  def email_comment_html
    auto_html(comment) do
      html_escape :map => {
        '&' => '&amp;',
        '>' => '&gt;',
        '<' => '&lt;',
        '"' => '"'
      }
      image
      redcloth :target => :_blank
      link :target => :_blank
    end
  end

  def notify_backers
    project.subscribed_users.each do |user|
      Rails.logger.info "[User #{user.id}] - Creating notification for #{user.name}"
      Notification.create_notification_once :updates, user,
        {update_id: self.id, user_id: user.id},
        project_name: project.name,
        project_owner: project.user.display_name,
        project_owner_email: project.user.email,
        update_title: title,
        update: self,
        from: project.user.email,
        update_comment: email_comment_html
    end
  end

end
