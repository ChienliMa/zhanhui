# -*- coding:utf-8 -*-
require 'active_record'
require 'yaml'
require './lib/zhanhui'

namespace :operation do

  config = YAML::load( File.open('remote.yaml') )
  ActiveRecord::Base.establish_connection( config )

  class Exhibition < ActiveRecord::Base 
  end
  class CityCode < ActiveRecord::Base
  end
  class BaseGeneralExpoCenter < ActiveRecord::Base
  end

  desc "Crawl Expo Info"
  task :crawl_expo_info do
    # get expo list
    exhibitions = Zhanhui.get_expos()

    # fetch each info of each expo
    thread_num = 5
    works = exhibitions

    workers = (0..thread_num).map do 
      # start a new thread
      Thread.new do
        begin 
          while work = works.pop()
            raise "Works finished" if work == nil
            # sleep for 1 second
            sleep( 1.second )
            begin
              p "update details of:" + work[:name].force_encoding('utf-8')
              info = Zhanhui.get_expo_info(work) 
              Exhibition.new( info ).save
            rescue => e
              puts "error loading page:" + work[:page]
            end
          end
        rescue ThreadError
        end
      end 
    end # works.map
    # hold main thread 
    workers.map(&:join); 
  end


  desc "Crawl Expo Center Info"
  task :crawl_expo_center_info do
    # get expo center id list
    center_ids = Zhanhui.get_expo_center_ids()
    
    # fetch info of each expo center
    thread_num = 8
    works = ids

    workers = (0..thread_num).map do 
      # start a new thread
      Thread.new do
        begin 
          while work = works.pop()
            raise "Works finished" if work == nil
            # sleep for 1 second
            sleep( 1.second )
            begin
              p "update details of:" + work[:name].force_encoding('utf-8')
              info = Zhanhui.get_expo_center_info(work) 
              BaseGeneralExpoCenter.new( info ).save
            rescue => e
              puts "error loading page:" + work[:page]
            end
          end
        rescue ThreadError
        end
      end 
    end # works.map
    # hold main thread 
    workers.map(&:join); 
  end

end