require 'spec_helper'

describe Heroku::Tagged::Deploy do
  it 'has a version number' do
    expect(Heroku::Tagged::Deploy::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
