module UserSkillsCompare
  module Hooks
    class UserProfileHook < Redmine::Hook::ViewListener
      def view_account_left_bottom(context = {})
        user = context[:user]
        return '' unless user # Kullanıcı yoksa boş döndür

        # SQL sorgusu
        sql_query = <<-SQL
          SELECT 
            at.name AS tag_name, 
            COUNT(DISTINCT te.issue_id) AS issue_count
          FROM 
            additional_tags at
          JOIN 
            additional_taggings at2 ON at2.tag_id = at.id
          JOIN (
            SELECT 
                issue_id
            FROM 
                time_entries
            WHERE 
                user_id = #{ActiveRecord::Base.sanitize_sql(user.id)}
            GROUP BY 
                issue_id
            HAVING 
                SUM(hours) > 1
          ) AS te ON te.issue_id = at2.taggable_id
          JOIN 
            issues i ON i.id = te.issue_id
          WHERE 
            at2.taggable_type = 'Issue'
            AND i.status_id = (SELECT id FROM issue_statuses WHERE name = 'Done')
            AND i.assigned_to_id = #{ActiveRecord::Base.sanitize_sql(user.id)}
          GROUP BY 
            at.name;
        SQL

        # Sorguyu çalıştır ve sonuçları al
        results = ActiveRecord::Base.connection.execute(sql_query)

        # Sonuçları formatla
        skills = results.map do |row|
          {
            tag_name: row[0],  # İlk sütun: tag_name
            task_count: row[1] # İkinci sütun: issue_count
          }
        end.sort_by { |skill| -skill[:task_count] }

        # Partial'ı render et
        context[:controller].send(:render_to_string, {
          partial: 'users/skills_sidebar',
          locals: { skills: skills,user: user }
        })
      end
    end
  end
end
