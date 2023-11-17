# frozen_string_literal: true

require 'test_helper'

class MyRailsAppEnvironment
  include ExtismOpenapi::HostEnvironment
  register File.join(__dir__, '..', 'lago.yaml')
end

class TestExtismOpenapi < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ExtismOpenapi::VERSION
  end

  def test_it_does_something_useful
    env = MyRailsAppEnvironment.new(
      base_url: 'http://api.lago.dev/api/v1',
      auth: {
        type: :bearer,
        token: '973a0a35-f35f-4fab-b0e1-922d108a2204'
      }
    )
    path = '/Users/ben/gen/target/wasm32-wasi/debug/lagoplugin.wasm'
    manifest = Extism::Manifest.from_path(path)
    plugin = Extism::Plugin.new(manifest, environment: env, wasi: true)
    puts plugin.call('greet', 'okay there')
  end
end
