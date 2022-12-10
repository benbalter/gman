# Only works on unixy type systems.
# http://blog.behindlogic.com/2008/10/auto-generate-your-manifest-and-gemspec.html
desc 'Rebuild manifest and gemspec.'
task :cultivate do
  system %q{touch Manifest.txt; rake check_manifest | grep -v "(in " | patch}
  system %q{rake debug_gem | grep -v "(in " > `basename \`pwd\``.gemspec}
end
