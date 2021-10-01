Connect-SPOService -Url "https://[YOUR TENANT]-admin.sharepoint.com"

$themepalette = @{
    "themePrimary" = "#0050b5";
    "themeLighterAlt" = "#f2f6fc";
    "themeLighter" = "#ccdef3";
    "themeLight" = "#a3c2e9";
    "themeTertiary" = "#548dd3";
    "themeSecondary" = "#1762be";
    "themeDarkAlt" = "#0049a3";
    "themeDark" = "#003e8a";
    "themeDarker" = "#002e65";
    "neutralLighterAlt" = "#faf9f8";
    "neutralLighter" = "#f3f2f1";
    "neutralLight" = "#edebe9";
    "neutralQuaternaryAlt" = "#e1dfdd";
    "neutralQuaternary" = "#d0d0d0";
    "neutralTertiaryAlt" = "#c8c6c4";
    "neutralTertiary" = "#a19f9d";
    "neutralSecondary" = "#605e5c";
    "neutralPrimaryAlt" = "#3b3a39";
    "neutralPrimary" = "#323130";
    "neutralDark" = "#201f1e";
    "black" = "#000000";
    "white" = "#ffffff";
    }

Add-SPOTheme -Identity "Dev Theme" -Palette $themepalette -IsInverted $false
