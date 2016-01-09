require File.join(File.dirname(__FILE__), 'helper')

class TestGmanIdentifier < Minitest::Test
  should 'Parse the dotgov list' do
    assert Gman.dotgov_list
    assert_equal CSV::Table, Gman.dotgov_list.class
    assert_equal CSV::Row, Gman.dotgov_list.first.class
    assert Gman.dotgov_list.first['Domain Name']
  end

  context 'locality domains' do
    should 'detect state domains' do
      domain = Gman.new('state.ak.us')
      assert domain.state?

      refute domain.dotgov?
      refute domain.city?
      refute domain.federal?
      refute domain.county?

      assert_equal :state, domain.type
      assert_equal 'AK', domain.state
    end

    should 'detect city domains' do
      domain = Gman.new('ci.champaign.il.us')
      assert domain.city?

      refute domain.dotgov?
      refute domain.state?
      refute domain.federal?
      refute domain.county?

      assert_equal :city, domain.type
      assert_equal 'IL', domain.state
    end
  end

  context 'dotgovs' do
    should 'detect federal dotgovs' do
      domain = Gman.new 'whitehouse.gov'
      assert domain.federal?
      assert domain.dotgov?

      refute domain.city?
      refute domain.state?
      refute domain.county?

      assert_equal :federal, domain.type
      assert_equal 'DC', domain.state
      assert_equal 'Washington', domain.city
      assert_equal 'Executive Office of the President', domain.agency
    end

    should 'detect state dotgovs' do
      domain = Gman.new 'illinois.gov'
      assert domain.state?
      assert domain.dotgov?

      refute domain.city?
      refute domain.federal?
      refute domain.county?

      assert_equal :state, domain.type
      assert_equal 'IL', domain.state
      assert_equal 'Springfield', domain.city
    end

    should 'detect county dotgovs' do
      domain = Gman.new 'ALLEGHENYCOUNTYPA.GOV'
      assert domain.county?
      assert domain.dotgov?

      refute domain.city?
      refute domain.federal?
      refute domain.state?

      assert_equal :county, domain.type
      assert_equal 'PA', domain.state
      assert_equal 'Pittsburgh', domain.city
    end

    should 'detect the list category' do
      assert_equal 'US Federal', Gman.new('whitehouse.gov').send('list_category')
    end
  end

  context 'non-dotgov domains' do
    should "determine a domain's group" do
      assert_equal 'usagovIN', Gman.new('cityofperu.org').send('list_category')
      assert_equal :unknown, Gman.new('cityofperu.org').type

      assert_equal 'Canada municipal', Gman.new('acme.ca').send('list_category')
      assert_equal :"Canada municipal", Gman.new('acme.ca').type

      assert_equal 'Canada federal', Gman.new('canada.ca').send('list_category')
      assert_equal :"Canada federal", Gman.new('canada.ca').type
    end

    should 'detect the state' do
      assert_equal 'OR', Gman.new('ashland.or.us').state
      refute Gman.new('canada.ca').state
    end
  end
end
