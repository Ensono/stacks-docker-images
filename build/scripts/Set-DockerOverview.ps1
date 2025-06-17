
[CmdletBinding()]
param (

    [string]
    # Base directory
    $base = "/eirctl/docs/docker-definitions",

    [string]
    # Output root
    $output = "/eirctl/markdown",

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
    $definition_name = [IO.Path]::GetFileNameWithoutExtension($overview)

    $new_directory = [IO.Path]::GetDirectoryName($overview.FullName) -replace $base, $output

    New-Item -ItemType Directory -Path ("{0}/{1}" -f $new_directory, $definition_name)

    # Determine the paths that are needed for the conversions
    $db_path = "{0}.xml" -f [IO.Path]::Combine($temp, $definition_name)

    # take the parent off the source path
    $dd = (Split-Path -Path $overview.Fullname -Parent).Replace($base, "").TrimStart("\").TrimStart("/")
    $target = [IO.Path]::Combine($output, $dd, ("{0}/README.md" -f $definition_name))

    # Generate the docbook file and then finally the markdown
    Invoke-External -Command "asciidoctor --failure-level warning -b docbook -o $db_path $overview"
    Invoke-External -Command "pandoc -f docbook -t markdown_strict $db_path -o $target"
}
