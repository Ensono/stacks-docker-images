
[CmdletBinding()]
param (

    [string]
    # Base directory
    $base = "/app/docs/docker-definitions",

    [string]
    # Output root
    $output = "/app/src/definitions",

    [string]
    # Temporary directory
    $temp = "/tmp"
)

# Find all the files that need to be converted to provide docker overview
$wildcard_path = [IO.Path]::Combine($base, "*.adoc")
$overviews = Get-ChildItem -Path $wildcard_path -recurse

# convert base to absolute path
$base = $base | Resolve-Path

# Iterate around the overviews files that have been found
foreach ($overview in $overviews) {

    # set the definition name
    $definition_name = [IO.Path]::GetFileNameWithoutExtension($overview)

    # Determine the paths that are needed for the conversions
    $db_path = "{0}.xml" -f [IO.Path]::Combine($temp, $definition_name)

    # take the parent off the source path
    $dd = (Split-Path -Path $overview.Fullname -Parent).Replace($base, "").TrimStart("\").TrimStart("/")
    $target = [IO.Path]::Combine($output, $dd, ("{0}/README.md" -f $definition_name))

    # Generate the docbook file and then finally the markdown
    Invoke-External -Command "asciidoctor -b docbook -o $db_path $overview"
    Invoke-External -Command "pandoc -f docbook -t markdown_strict $db_path -o $target"
}
