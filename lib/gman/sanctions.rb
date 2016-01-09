class Gman
  # http://www.treasury.gov/resource-center/sanctions/Programs/Pages/Programs.aspx
  SANCTIONED_COUNTRIES = %w(
    112
    384
    192
    180
    364
    368
    422
    434
    408
    706
    728
    729
    760
    804
    887
    716
    430
    694
    716
  ).freeze

  def sanctioned?
    SANCTIONED_COUNTRIES.include?(country.numeric) if country
  end
end
