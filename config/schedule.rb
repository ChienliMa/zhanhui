job_type :ruby, "cd :path/lib/ && /usr/bin/ruby :task.rb" 
job_type :rake, "cd :path && /usr/bin/rake :task" 

every 1.week do
  rake 'operation:crawl_expo_info', :output=>{:error=>':path/log/schedule.log'}
end

every 1.week do
  rake 'operation:update_center_city_codes', :output=>{:error=>':path/log/schedule.log'}
end

every

