
class UserSkillsCompareController < ApplicationController
    def show
      @user = User.find(params[:id])  # Kullanıcıyı ID'sine göre buluyoruz
  
      # Kullanıcının yeteneklerini alıyoruz
      @skills = @user.skills  # Burada @user.skills metodunu çağırıyoruz
    end
  
    def index
      @user = User.find(params[:id])
  
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
                          user_id = #{ActiveRecord::Base.sanitize_sql(@user.id)}
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
                      AND i.assigned_to_id = #{ActiveRecord::Base.sanitize_sql(@user.id)}
                  GROUP BY 
                      at.name;
      SQL
  
      # Sorguyu çalıştır ve sonuçları al
      results = ActiveRecord::Base.connection.execute(sql_query)
  
      @skills = results.map do |row|
        {
          tag_name: row[0],  # İlk sütun: tag_name
          task_count: row[1] # İkinci sütun: issue_count
        }
      end
      
    end
  end
  
=begin
SELECT at.name AS tag_name, COUNT(te.issue_id) AS issue_count
FROM additional_tags at
JOIN additional_taggings at2 ON at2.tag_id = at.id
JOIN (
    SELECT issue_id
    FROM time_entries
    WHERE user_id = #{ActiveRecord::Base.sanitize_sql(@user.id)}
    GROUP BY issue_id
    HAVING SUM(hours) > 1
) AS te ON te.issue_id = at2.taggable_id
WHERE at2.taggable_type = 'Issue'
GROUP BY at.name
=end