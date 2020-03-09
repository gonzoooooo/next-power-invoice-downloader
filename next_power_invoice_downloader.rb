# frozen_string_literal: true

require "selenium-webdriver"

module NextPowerInvoiceDownloader
  class Downloader
    ROOT_URL = "https://np-smartmansion.ipps.co.jp/?q=node/86"

    def initialize(id, pass, chrome_path)
      @id = id
      @pass = pass
      @chrome_path = chrome_path
    end

    def run
      driver = SeleniumWebDriverCreator.new(@chrome_path).driver
      wait = Selenium::WebDriver::Wait.new(timeout: 10)

      driver.navigate.to(ROOT_URL)

      driver.find_element(:name, "user_id").send_keys(@id)
      driver.find_element(:name, "pass").send_keys(@pass)
      driver.find_element(:id, "edit-submit").click

      menu_link_xpath = '//a[@href="/details"]'
      wait.until { driver.find_element(:xpath, menu_link_xpath).displayed? }
      driver.find_element(:xpath, menu_link_xpath).click

      iframe_id = "iframe"
      wait.until { driver.find_element(:id, iframe_id).displayed? }
      iframe = driver.find_element(:id, iframe_id)
      driver.switch_to.frame(iframe)

      invoice_link_xpath = '//table[@id="Tbl_SeikyuTable"]/tbody/tr[2]/td/a'
      wait.until { driver.find_element(:xpath, invoice_link_xpath).displayed? }
      driver.find_element(:xpath, invoice_link_xpath).click

      sleep 5

      driver.quit
    end
  end

  class SeleniumWebDriverCreator
    def initialize(chrome_path)
      @chrome_path = chrome_path
    end

    def driver
      capabilities = ChromeDriverCapabilitiesCreator.new(@chrome_path).capabilities
      driver = Selenium::WebDriver.for(:chrome, desired_capabilities: capabilities, options: options(plugins: selenium_plugins))
      driver.manage.timeouts.implicit_wait = 30
      driver
    end

    private

    def options(plugins:)
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_preference(:plugins, plugins)
      options
    end

    def selenium_plugins
      { "always_open_pdf_externally" => true }
    end
  end

  class ChromeDriverCapabilitiesCreator
    def initialize(chrome_path)
      @chrome_path = chrome_path
    end

    def capabilities
      chrome_options = { binary_path: @chrome_path, args: args, prefs: prefs }
      Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => chrome_options)
    end

    private

    def args
      ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.116 Safari/537.36"
      ["--disable-gpu", "--user_agent=#{ua}", "window-size=1280x800"]
    end

    def prefs
      { "download" => { "default_directory" => Dir.getwd,
                        "directory_upgrade" => true,
                        "prompt_for_download" => false } }
    end
  end
end
