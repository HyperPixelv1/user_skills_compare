require "redmine"

require "/usr/src/redmine/plugins/user_skills_compare/lib/user_skills_compare/hooks/user_profile_hook.rb"

Rails.configuration.to_prepare do
  User.include(UserSkillsCompare::Patches::UserSkillsProfilePatch)
end

Redmine::Plugin.register :user_skills_compare do
  name "User Skills Compare Plugin"
  author "HyperPixelv1"
  description ""
  version "0.0.1"
  author_url "https://github.com/HyperPixelv1"

end

