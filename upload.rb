require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'dotenv/load'
require_relative './db_init'

Capybara.default_driver = :poltergeist

class Sc2ReplayStatsUploader
  include Capybara::DSL
  BLIZZARD_ACCOUNT_FOLDER = ENV['BLIZZARD_ACCOUNT_FOLDER']
  ACCOUNTS = ENV['ACCOUNTS'].split(',')
  GAME_TYPES = ENV['GAME_TYPES'].split(',')

  def initialize
    @new_replays = []
    @batch_size = 20
  end

  def run
    find_new_replays
    if @new_replays.count.zero?
      puts "Nothing to upload"
      return
    end
    upload_replays
  end

  private

  def find_new_replays
    puts "Finding new replays ..."
    ACCOUNTS.each do |account|
      GAME_TYPES.each do |game_type|
        files = Dir.glob("#{BLIZZARD_ACCOUNT_FOLDER}/#{account}/Replays/#{game_type}/*.SC2Replay").sort_by {|f| File.mtime(f) }.reverse
        files.each do |file|
          file_name = File.basename(file)
          next if !Replay.find_by(file_name: file_name, account: account, game_type: game_type).nil?

          @new_replays << file
          Replay.create(file_name: file_name, account: account, game_type: game_type, recorded_at: Time.now)
        end
      end
    end

    puts "#{@new_replays.count} new replay(s) found ..."
  end

  def upload_replays
    puts "Logging in ..."
    visit 'https://sc2replaystats.com/Account/signin'

    within('form.white-row') do
      fill_in 'email', with: ENV['USERNAME']
      fill_in 'password', with: ENV['PASSWORD']
      click_button 'Sign In'
    end

    puts "Go to Upload Replays page ..."
    click_link 'Upload Replays'

    total_batches = (@new_replays.count + @batch_size - 1) / @batch_size

    @new_replays.each_slice(@batch_size).with_index do | files_batch, index |
      puts "Uploading batch #{index + 1}/#{total_batches} (#{(@batch_size * index) + 1} - #{[(@batch_size * (index + 1)), @new_replays.count].min})..."

      attach_file('file_upload', files_batch, visible: false)
      page.find('#uploadifive-file_upload').click

      loop
        sleep(2)
        until page.find_all('.uploadifive-queue-item:not(.complete)').count == 0
      end
    end

    page.driver.quit
    puts "Done ... "
  end
end


Sc2ReplayStatsUploader.new.run
