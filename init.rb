require "redmine"

=begin
Rails.application.config.to_prepare do
  Rails.logger.info "UserSkillsPlugin: Patch User modeline yükleniyor..."
  User.include UserSkillsPlugin::UserPatch
  Rails.logger.info "UserSkillsPlugin: User modeline patch yüklendi!"
end
=end
Redmine::Plugin.register :user_skills_compare do
  name "User Skills Compare Plugin"
  author "HyperPixelv1"
  description ""
  version "0.0.1"
  author_url "https://github.com/HyperPixelv1"

end