require "rake"
require "./next_power_invoice_downloader"

task :download do
  id = ENV["NEXTPOWER_SITE_ID"]
  pass = ENV["NEXTPOWER_SITE_PASS"]
  chrome_path = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

  NextPowerInvoiceDownloader::Downloader.new(id, pass, chrome_path).run
end

task :default => :download
