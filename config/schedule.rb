job_type :ruby, "cd :path/lib/ && /usr/bin/ruby :task.rb" 
job_type :rake, "cd :path && /usr/bin/rake :task" 

every 10.minute do
  rake 'operation:crawl_expo_info', :output=>{:error=>':path/log/schedule.log'}
end

every 10.minute do
  rake 'operation:crawl_expo-center_info', :output=>{:error=>':path/log/schedule.log'}
end

