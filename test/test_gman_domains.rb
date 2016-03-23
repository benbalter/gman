require File.join(File.dirname(__FILE__), 'helper')

class TestGmanDomains < Minitest::Test
  WHITELIST = ['non-us gov', 'non-us mil', 'US Federal'].freeze

  def resolve_domains?
    ENV['GMAN_RESOLVE_DOMAINS'] == 'true'
  end

  should 'only contains valid domains' do
    importer = Gman::Importer.new({})
    if resolve_domains?
      importer.logger.info <<-MSG
        Validating that all domains resolve. This may take a while...
      MSG
    else
      importer.logger.info 'Skipping domain resolution.' \
        'Run `GMAN_RESOLVE_DOMAINS=true rake test` '\
        'to validate that domains resolve.'
    end

    invalid = []
    list = Gman.list.to_h
    Parallel.each(list, in_threads: 2) do |group, domains|
      next if WHITELIST.include?(group)
      invalid.push domains.reject { |domain|
        options = { skip_dupe: true, skip_resolve: !resolve_domains? }
        importer.valid_domain?(domain, options)
      }
    end
    assert_equal [], invalid.flatten.reject(&:empty?)
  end
end
