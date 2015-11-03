require 'support/capybara_app_helper'

RSpec.describe "Facebook Integration" do
  before do
    setup_app(action: :facebook) do |tracker|
      tracker.handler :facebook, { custom_audience: 'my-audience' }
    end
    visit '/'
  end

  subject { page }

  it "embeds the script tag with tracking event from the controller action" do
    expect(page).to have_content('fbq("init", "my-audience");')
    expect(page.body).to include('https://www.facebook.com/tr?id=my-audience&amp;ev=PageView')
    expect(page).to have_content('fbq("track", "PageView");')
  end
end
