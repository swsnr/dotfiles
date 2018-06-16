# Use lualatex by default
$pdf_mode = 4;

if ($^O eq "darwin") {
  # On OSX, use Skim as previewer
  $pdf_previewer = 'open -a Skim.app %S --args %O';
}

# Add a couple of additional generated extensions
push @generated_exts, "nav"; # Beamer nav files
push @generated_exts, "snm"; # Also something from beamer?
push @generated_exts, "vrb"; # Fancyvrb (e.g. via minted)
