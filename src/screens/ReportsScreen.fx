// Natural England Condition Assessment Demo - Reports Screen
// "Area Condition Dashboard" - Reports and data export

Screen(
  Fill: varTheme.Background,
  
  // Header Banner
  Rectangle(
    X: 0, Y: 0, Width: Parent.Width, Height: 80,
    Fill: varTheme.Primary,
    
    Label(
      Text: "📊 Area Condition Dashboard",
      X: 20, Y: 20, Width: Parent.Width - 120, Height: 40,
      Color: Color.White,
      Font: Font.'Segoe UI',
      Size: 18,
      FontWeight: FontWeight.Semibold
    ),
    
    Button(
      Text: "← Back to Home",
      X: Parent.Width - 100, Y: 25, Width: 80, Height: 30,
      Fill: Color.Transparent,
      Color: Color.White,
      BorderColor: Color.White,
      BorderThickness: 1,
      Font: Font.'Segoe UI',
      Size: 11,
      RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4,
      OnSelect: Navigate(HomeScreen)
    )
  ),
  
  // Filter Controls
  Container(
    X: 20, Y: 100, Width: Parent.Width - 40, Height: 60,
    
    Label(
      Text: "Filters:",
      X: 0, Y: 15, Width: 60, Height: 25,
      Color: varTheme.Text,
      Font: Font.'Segoe UI',
      Size: 12,
      FontWeight: FontWeight.Semibold
    ),
    
    Label(
      Text: "Region:",
      X: 70, Y: 15, Width: 60, Height: 25,
      Color: varTheme.Text,
      Font: Font.'Segoe UI',
      Size: 11
    ),
    
    Dropdown(
      Items: ["East of England", "Yorkshire & Humber", "South West", "All Regions"],
      Default: "East of England",
      X: 140, Y: 15, Width: 150, Height: 30,
      Font: Font.'Segoe UI',
      Size: 10
    ),
    
    Label(
      Text: "Feature:",
      X: 310, Y: 15, Width: 60, Height: 25,
      Color: varTheme.Text,
      Font: Font.'Segoe UI',
      Size: 11
    ),
    
    Dropdown(
      Items: ["Heathland", "Grassland", "Woodland", "All Features"],
      Default: "Heathland",
      X: 380, Y: 15, Width: 150, Height: 30,
      Font: Font.'Segoe UI',
      Size: 10
    ),
    
    Label(
      Text: "Year:",
      X: 550, Y: 15, Width: 40, Height: 25,
      Color: varTheme.Text,
      Font: Font.'Segoe UI',
      Size: 11
    ),
    
    Dropdown(
      Items: ["2025", "2024", "2023", "2022", "All Years"],
      Default: "2025",
      X: 600, Y: 15, Width: 80, Height: 30,
      Font: Font.'Segoe UI',
      Size: 10
    )
  ),
  
  // Export Section
  Container(
    X: 20, Y: 500, Width: Parent.Width - 40, Height: 80,
    
    Label(
      Text: "Export & Reports",
      X: 0, Y: 0, Width: Parent.Width, Height: 25,
      Color: varTheme.Text,
      Font: Font.'Segoe UI',
      Size: 16,
      FontWeight: FontWeight.Semibold
    ),
    
    Gallery(
      Items: [
        {Title: "Export to Excel", Subtitle: "Site Summary Data", Icon: "📊", Action: "Excel"},
        {Title: "Generate PDF Report", Subtitle: "Condition Assessment Report", Icon: "📄", Action: "PDF"},
        {Title: "Download Raw Data", Subtitle: "CSV Format", Icon: "💾", Action: "CSV"},
        {Title: "Email Summary", Subtitle: "Send to Stakeholders", Icon: "📧", Action: "Email"}
      ],
      X: 0, Y: 30, Width: Parent.Width, Height: 45,
      Layout: Layout.Horizontal,
      TemplateSize: Parent.Width / 4,
      
      Button(
        Text: ThisItem.Icon & " " & ThisItem.Title,
        X: 5, Y: 0, Width: Parent.TemplateWidth - 10, Height: 35,
        Fill: varTheme.Info,
        Color: Color.White,
        Font: Font.'Segoe UI',
        Size: 10,
        RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
        OnSelect: Switch(ThisItem.Action,
          "Excel", Notify("Excel export would download here", NotificationType.Information, 2000),
          "PDF", Launch("https://naturalengland.gov.uk/reports/BrecklandHeath_2025.pdf"),
          "CSV", Notify("CSV download would start here", NotificationType.Information, 2000),
          "Email", Notify("Email sent to stakeholders", NotificationType.Success, 2000)
        )
      )
    )
  )
);