require File.join(File.dirname(__FILE__), 'helper')

class TestGManImporter < Minitest::Test
  def setup
    @importer = Gman::Importer.new 'test' => ['example.com']
    @stdout = StringIO.new
    @importer.instance_variable_set '@logger', Logger.new(@stdout)

    @original_domain_list = stubbed_list.contents
  end

  def teardown
    File.write stubbed_list_path, @original_domain_list
  end

  should 'init the domain list' do
    assert_equal Gman::DomainList, @importer.domain_list.class
    assert_equal 1, @importer.domain_list.count
    assert_equal 'example.com', @importer.domain_list.domains.first
  end

  should 'init the logger' do
    assert_equal Logger, @importer.logger.class
  end

  should 'return the current domain list' do
    assert_equal Gman::DomainList, @importer.current.class
  end

  should 'return the resolver' do
    assert_equal Resolv::DNS, @importer.resolver.class
  end

  context 'domain rejection' do
    should 'return false for a rejected domain' do
      refute @importer.reject 'example.com', 'reasons'
    end

    should 'return the reason when asked' do
      with_env 'RECONCILING', 'true' do
        assert_equal 'reasons', @importer.reject('example.com', 'reasons')
      end
    end
  end

  context 'manipulating the domain list' do
    should 'normalize domains within the domain list' do
      importer = Gman::Importer.new 'test' => ['www.EXAMPLE.com/']
      importer.send :normalize_domains!
      assert_equal 'example.com', importer.domain_list.domains.first
    end

    should 'remove invalid domains from the domain list' do
      importer = Gman::Importer.new 'test' => ['foo.github.io', 'example.com']
      importer.instance_variable_set '@logger', Logger.new(@stdout)

      assert_equal 2, importer.domain_list.count
      importer.send :ensure_validity!
      assert_equal 1, importer.domain_list.count
    end

    context 'writing the domain list' do
      should 'add domains to the current domain list' do
        domains = { 'test' => ['example.com'], 'test2' => ['github.com'] }
        importer = Gman::Importer.new domains
        importer.instance_variable_set "@current", stubbed_list
        importer.send :add_to_current
        expected = "// test\nexample.com\ngov\n\n// test2\ngithub.com"
        assert_equal expected, File.open(stubbed_list_path).read
      end

      should 'import' do
        domains = {
          'test'  => ['www.example.com', 'goo.github.io'],
          'test2' => ['github.com', 'www.github.com', 'whitehouse.gov']
        }

        importer = Gman::Importer.new domains
        importer.instance_variable_set "@current", stubbed_list
        importer.instance_variable_set '@logger', Logger.new(@stdout)
        importer.import(skip_resolve: true)

        expected = "// test\nexample.com\ngov\n\n// test2\ngithub.com"
        assert_equal expected, File.open(stubbed_list_path).read
      end
    end
  end

  context 'domain validation' do
    should 'allow valid domains' do
      assert @importer.send :ensure_valid, 'whitehouse.gov'
    end

    should 'reject empty domains' do
      refute @importer.send :ensure_valid, ''
    end

    should 'reject blacklisted domains' do
      refute @importer.send :ensure_valid, 'egovlink.com'
    end

    should 'reject invalid domains' do
      refute @importer.send :ensure_valid, 'foo.invalid'
    end

    should 'reject academic domains' do
      refute @importer.send :ensure_valid, 'harvard.edu'
    end

    should "reject regex'd domains" do
      refute @importer.send :ensure_valid, 'foo.github.io'
    end
  end

  context 'duplicate domains' do
    should 'know a unique domain is not a dupe' do
      refute @importer.send :dupe?, 'gman.com'
    end

    should "know when a domain's a dupe" do
      assert @importer.send :dupe?, 'gov'
    end

    should "know when a domain's a subdomain of an existing domain" do
      assert @importer.send :dupe?, 'whitehouse.gov'
    end

    should 'allow unique domains' do
      assert @importer.send :ensure_not_dupe, 'gman.com'
    end

    should 'reject duplicate domains' do
      refute @importer.send :ensure_not_dupe, 'gov'
    end

    should 'reject subdomains' do
      refute @importer.send :ensure_not_dupe, 'whitehouse.gov'
    end
  end

  context 'domain resolution' do
    should 'know if a domain resolves' do
      assert @importer.domain_resolves?('github.com')
      assert @importer.send :ensure_resolves, 'github.com'
    end

    should "know if a domain doesn't resolve" do
      refute @importer.domain_resolves?('foo.invalid')
      refute @importer.send :ensure_resolves, 'foo.invalid'
    end

    should 'know if a domain has an IP' do
    end

    should 'know if a domain returns a given record' do
    end
  end

  context 'regex checks' do
    should 'pass valid domains' do
      assert @importer.send :ensure_regex, 'example.com'
    end

    should 'reject domains that begin with home.' do
      refute @importer.send :ensure_regex, 'home.example.com'
    end

    should 'reject domains that begin with user.' do
      refute @importer.send :ensure_regex, 'user.example.com'
    end

    should 'reject domains that begin with site.' do
      refute @importer.send :ensure_regex, 'user.example.com'
    end

    should 'reject weebly domains' do
      refute @importer.send :ensure_regex, 'foo.weebly.com'
    end

    should 'reject wordpress domains' do
      refute @importer.send :ensure_regex, 'foo.wordpress.com'
    end

    should 'reject govoffice domains' do
      refute @importer.send :ensure_regex, 'foo.govoffice.com'
      refute @importer.send :ensure_regex, 'foo.govoffice1.com'
    end

    should 'reject homestead domains' do
      refute @importer.send :ensure_regex, 'foo.homestead.com'
    end

    should 'reject wix domains' do
      refute @importer.send :ensure_regex, 'foo.wix.com'
    end

    should 'reject blogspot domains' do
      refute @importer.send :ensure_regex, 'foo.blogspot.com'
    end

    should 'reject tripod domains' do
      refute @importer.send :ensure_regex, 'foo.tripod.com'
    end

    should 'reject squarespace domains' do
      refute @importer.send :ensure_regex, 'foo.squarespace.com'
    end

    should 'reject github.io domains' do
      refute @importer.send :ensure_regex, 'foo.github.io'
    end

    should 'reject locality domains' do
      refute @importer.send :ensure_regex, 'ci.champaign.il.us'
    end
  end

  context 'normalizing domains' do
    should 'normalize URLs to domains' do
      expected = 'example.com'
      assert_equal expected, @importer.normalize_domain('http://example.com')
    end

    should 'strip WWW' do
      assert_equal 'example.com', @importer.normalize_domain('www.example.com')
    end

    should 'remove trailing slashes' do
      assert_equal 'example.com', @importer.normalize_domain('example.com/')
    end

    should 'remove paths' do
      assert_equal 'example.com', @importer.normalize_domain('example.com/foo')
    end

    should 'remove paths with trailing slashes' do
      assert_equal 'example.com', @importer.normalize_domain('example.com/foo/')
    end

    should 'downcase' do
      assert_equal 'example.com', @importer.normalize_domain('EXAMPLE.com')
    end
  end
end
