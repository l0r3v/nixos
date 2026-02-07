{
  runCommand,
  ...
}:

runCommand "authentik-docs-dummy" {} ''
  mkdir -p $out
  echo "Documentation build skipped to avoid npm errors" > $out/README.md
  
  # Create minimal structure that might be expected
  mkdir -p $out/static/blueprints
  
  # If the server crashes looking for index.html, we might need to add dummy files here.
  # But usually static assets are just served if present.
''