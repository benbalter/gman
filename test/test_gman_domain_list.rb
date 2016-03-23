require File.join(File.dirname(__FILE__), 'helper')

class TestGmanDomainList < Minitest::Test
  INIT_TYPES = [:path, :contents, :data].freeze

  def setup
    @original_domain_list = File.read(stubbed_list_path)
  end

  def teardown
    File.write stubbed_list_path, @original_domain_list
  end

  def domain_list(type)
    case type
    when :path
      Gman::DomainList.new(path: Gman.list_path)
    when :contents
      contents = File.read(Gman.list_path)
      Gman::DomainList.new(contents: contents)
    when :data
      data = Gman::DomainList.new(path: Gman.list_path).to_h
      Gman::DomainList.new(data: data)
    end
  end

  INIT_TYPES.each do |type|
    context "when initalized with #{type}" do
      should 'store the init vars' do
        refute domain_list(type).public_send(type).nil?
      end

      should 'return the domain data' do
        list = domain_list(type)
        assert list.data.key? 'Canada federal'
        assert list.data.any? { |_key, values| values.include? 'gov' }
      end

      should 'return the list contents' do
        list = domain_list(type)
        assert_match /^gov$/, list.contents
      end

      should 'return the list path' do
        list = domain_list(type)
        assert_equal list.path, Gman.list_path
      end

      should 'return the public suffix parsed list' do
        list = domain_list(type)
        assert list.public_suffix_list.class == PublicSuffix::List
      end

      should 'know if a domain is valid' do
        list = domain_list(type)
        assert list.valid? 'whitehouse.gov'
      end

      should 'know if a domain is invalid' do
        list = domain_list(type)
        refute list.valid? 'example.com'
      end

      should 'return the domain groups' do
        list = domain_list(type)
        assert list.groups.include?('Canada federal')
      end

      should 'return the domains' do
        list = domain_list(type)
        assert list.domains.include?('gov')
      end

      should 'return the domain count' do
        list = domain_list(type)
        assert list.count.is_a?(Integer)
        assert list.count > 100
      end

      should 'alphabetize the list' do
        list = domain_list(type)
        list.data['Canada municipal'].shuffle!
        assert list.data['Canada municipal'].first != '100milehouse.com'
        list.alphabetize
        assert list.data['Canada municipal'].first == '100milehouse.com'
      end

      should 'write the list' do
        list = domain_list(type)
        list.instance_variable_set('@path', stubbed_list_path)
        list.data = { 'foo' => ['bar.gov', 'baz.net'] }
        list.write
        contents = File.read(stubbed_list_path)
        assert_match %r{^// foo$}, contents
        expected = "// foo\nbar.gov\nbaz.net"
        assert contents.include?(expected)
      end

      should 'output the list in public_suffix format' do
        list = domain_list(type)
        string = list.to_s
        assert_match %r{^// Canada federal$}, string
        assert string.include? "// Canada federal\ncanada\.ca\n"
      end

      should "find a domain's parent" do
        list = domain_list(type)
        assert_equal 'gov.uk', list.parent_domain('foo.gov.uk')
      end
    end
  end
end
