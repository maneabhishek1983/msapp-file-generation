// Natural England Branding Component
// Provides consistent branding, styling, and theme across the application

// Component properties
Property BrandingType As Text = "Header"; // Header, Footer, Logo, Colors
Property ShowLogo As Boolean = true;
Property ShowTitle As Boolean = true;
Property Title As Text = "Condition Assessment";
Property Subtitle As Text = "Natural England";

// Natural England brand colors and styling constants
Set(varNEBrandColors, {
  PrimaryGreen: "#1F4D3A",
  SecondaryGreen: "#6B8E23",
  AccentGreen: "#228B22",
  White: "#FFFFFF",
  LightGrey: "#F8F9FA",
  MediumGrey: "#6C757D",
  DarkGrey: "#212529",
  BorderGrey: "#DEE2E6"
});

// Brand typography settings
Set(varNETypography, {
  HeaderFont: "Segoe UI",
  BodyFont: "Segoe UI",
  HeaderSize: 24,
  SubheaderSize: 18,
  BodySize: 14,
  SmallSize: 12
});

// Logo and imagery settings
Set(varNEImagery, {
  LogoPath: "resources/images/NE_logo.png",
  BannerPath: "resources/images/heathland_banner.jpg",
  LogoWidth: 120,
  LogoHeight: 60
});

// Accessibility settings
Set(varNEAccessibility, {
  MinContrastRatio: 4.5,
  FocusOutlineWidth: 2,
  FocusOutlineColor: "#80BDFF",
  HighContrastMode: false
});

// Component styling based on type
Switch(BrandingType,
  "Header", 
    // Header branding container
    Container(
      Fill: varNEBrandColors.PrimaryGreen,
      Height: 80,
      Width: Parent.Width,
      // Header content
      HorizontalContainer(
        // Logo section
        If(ShowLogo,
          Image(
            Image: varNEImagery.LogoPath,
            Width: varNEImagery.LogoWidth,
            Height: varNEImagery.LogoHeight,
            ImagePosition: ImagePosition.Fit,
            AccessibleLabel: "Natural England Logo"
          )
        ),
        // Title section
        If(ShowTitle,
          VerticalContainer(
            Label(
              Text: Title,
              Font: varNETypography.HeaderFont,
              Size: varNETypography.HeaderSize,
              Color: varNEBrandColors.White,
              FontWeight: FontWeight.Bold,
              AccessibleLabel: Title
            ),
            If(!IsBlank(Subtitle),
              Label(
                Text: Subtitle,
                Font: varNETypography.BodyFont,
                Size: varNETypography.BodySize,
                Color: varNEBrandColors.White,
                AccessibleLabel: Subtitle
              )
            )
          )
        )
      )
    ),
    
  "Footer",
    // Footer branding container
    Container(
      Fill: varNEBrandColors.LightGrey,
      Height: 60,
      Width: Parent.Width,
      BorderColor: varNEBrandColors.BorderGrey,
      BorderThickness: 1,
      // Footer content
      HorizontalContainer(
        Align: Align.Center,
        Label(
          Text: "© Natural England " & Year(Now()) & " | SSSI Condition Assessment",
          Font: varNETypography.BodyFont,
          Size: varNETypography.SmallSize,
          Color: varNEBrandColors.MediumGrey,
          AccessibleLabel: "Copyright Natural England " & Year(Now())
        )
      )
    ),
    
  "Logo",
    // Standalone logo
    Image(
      Image: varNEImagery.LogoPath,
      Width: varNEImagery.LogoWidth,
      Height: varNEImagery.LogoHeight,
      ImagePosition: ImagePosition.Fit,
      AccessibleLabel: "Natural England Logo"
    ),
    
  "Colors",
    // Color palette reference (invisible component for theme access)
    Container(
      Visible: false,
      // Expose colors through component properties
      Fill: varNEBrandColors.PrimaryGreen
    )
);

// Accessibility enhancements
OnSelect: 
  // Handle keyboard navigation and screen reader announcements
  If(BrandingType = "Header" And ShowLogo,
    // Announce navigation to home when logo is selected
    Announce("Navigating to home screen", 'Polite');
    Navigate(HomeScreen, ScreenTransition.Fade)
  );

// Focus management for accessibility
TabIndex: If(BrandingType = "Header" And ShowLogo, 1, -1);

// High contrast mode support
If(varNEAccessibility.HighContrastMode,
  // Adjust colors for high contrast
  Set(varNEBrandColors, {
    PrimaryGreen: "#000000",
    SecondaryGreen: "#000000", 
    AccentGreen: "#000000",
    White: "#FFFFFF",
    LightGrey: "#FFFFFF",
    MediumGrey: "#000000",
    DarkGrey: "#000000",
    BorderGrey: "#000000"
  })
);