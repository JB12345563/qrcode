# frozen_string_literal: true

require_relative "lib/qrcode/version"

Gem::Specification.new do |spec|
	spec.name = "qrcode"
	spec.version = QRCode::VERSION
	
	spec.summary = "A library to encode QR Codes"
	spec.authors = ["Duncan Robertson", "Björn Blomqvist", "Gioele Barabucci", "Sam Sayer", "Fabio Napoleoni", "xn", "Tonči Damjanić", "Bjorn Blomqvist", "Christopher Lord", "Samuel Williams", "Andreas Finger", "Andy Brody", "James Neal", "Jon Evans", "Marcos Piccinini", "Yauhen Kharuzhy", "Bart Jedrocha", "Chris Mowforth", "Christian Campbell", "Daniel Schierbeck", "Ferdinand Rosario", "Jeremy Evans", "José Luis Honorato", "Ken Collins", "Masataka Pocke Kuwabara", "Matt Rohrer", "Nathaniel Roman", "Nicolò Gnudi", "Sean Doig", "Simon Males", "Simon Schrape", "Thibaut Barrère", "Tore Darell", "dependabot[bot]"]
	spec.license = "MIT"
	
	spec.homepage = "https://github.com/whomwah/rqrcode_core"
	
	spec.metadata = {
		"bug_tracker_uri" => "https://github.com/whomwah/rqrcode_core/issues",
		"changelog_uri" => "https://github.com/whomwah/rqrcode_core/blob/main/CHANGELOG.md",
		"funding_uri" => "https://github.com/sponsors/whomwah/",
		"source_code_uri" => "https://github.com/whomwah/rqrcode_core.git",
	}
	
	spec.files = Dir.glob(["{.github,bin,fixtures,lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.2"
end
