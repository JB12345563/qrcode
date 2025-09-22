# frozen_string_literal: true

require_relative "lib/qrcode/version"

Gem::Specification.new do |spec|
	spec.name = "qrcode"
	spec.version = QRCode::VERSION
	
	spec.summary = "A library to encode QR Codes"
	spec.authors = ["Duncan Robertson", "Björn Blomqvist", "Gioele Barabucci", "Sam Sayer", "Samuel Williams", "Fabio Napoleoni", "xn", "Tonči Damjanić", "Bjorn Blomqvist", "Christopher Lord", "Andreas Finger", "Andy Brody", "James Neal", "Jon Evans", "Marcos Piccinini", "Yauhen Kharuzhy", "Bart Jedrocha", "Chris Mowforth", "Christian Campbell", "Daniel Schierbeck", "Ferdinand Rosario", "Jeremy Evans", "José Luis Honorato", "Ken Collins", "Masataka Pocke Kuwabara", "Matt Rohrer", "Nathaniel Roman", "Nicolò Gnudi", "Sean Doig", "Simon Males", "Simon Schrape", "Thibaut Barrère", "Tore Darell", "dependabot[bot]"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.homepage = "https://github.com/socketry/qrcode"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/qrcode/",
		"source_code_uri" => "https://github.com/socketry/qrcode.git",
	}
	
	spec.files = Dir.glob(["{.github,fixtures,lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.2"
end
