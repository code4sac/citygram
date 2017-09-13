require 'open-uri'
require 'openssl'

namespace :publishers do
  desc "Prompt publishers to update themselves"
  task update: :app do
    Publisher.active.select(:id, :endpoint).paged_each do |publisher|
      Citygram::Workers::PublisherPoll.perform_async(publisher.id, publisher.endpoint)
    end
  end
  desc "Download publishers from Citygram"
  task download: :app do
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
    pub_file = open("https://www.citygram.org/publishers.json").read
    publishers = JSON.parse(pub_file)
    Citygram::Models::Publisher.set_allowed_columns(
      :title, :endpoint, :active, :visible,
      :city, :state, :icon, :description, :tags,
      :event_display_endpoint, :events_are_polygons
    )
    publishers.each do |pub|
      pub.delete("id")
      pub.delete("updated_at")
      pub.delete("created_at")
      new_pub = Citygram::Models::Publisher.new(pub)
      if new_pub.valid?
        puts "Saving #{new_pub.description}: #{new_pub.city} #{new_pub.state}"
        new_pub.save
      else
        puts "Skipping #{new_pub.description}: #{new_pub.city} #{new_pub.state}"
      end
    end
  end
end
