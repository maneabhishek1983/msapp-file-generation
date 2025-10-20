// Natural England Condition Assessment Demo - Site Detail Screen
// Comprehensive site information and management interface

Screen(
  Fill: varTheme.Background,
  
  // Header Banner with Site Information
  Rectangle(
    X: 0, Y: 0, Width: Parent.Width, Height: 120,
    Fill: varTheme.Primary,
    
    Button(
      Text: "← Back to Home",
      X: 20, Y: 25, Width: 100, Height: 30,
      Fill: Color.Transparent,
      Color: Color.White,
      BorderColor: Color.White,
      BorderThickness: 1,
      Font: Font.'Segoe UI',
      Size: 11,
      RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4,
      OnSelect: Navigate(HomeScreen)
    ),
    
    Label(
      Text: If(IsBlank(varSelectedSite), "Site Details", varSelectedSite.SiteName),
      X: 140, Y: 20, Width: Parent.Width - 300, Height: 30,
      Color: Color.White,
      Font: Font.'Segoe UI',
      Size: 20,
      FontWeight: FontWeight.Semibold
    ),
    
    Label(
      Text: If(IsBlank(varSelectedSite), "", varSelectedSite.Region & " • " & varSelectedSite.Designation & " • " & varSelectedSite.Area),
      X: 140, Y: 55, Width: Parent.Width - 300, Height: 20,
      Color: ColorFade(Color.White, 0.2),
      Font: Font.'Segoe UI',
      Size: 12
    )
  ),
  
  // Quick Stats Cards
  Container(
    X: 20, Y: 140, Width: Parent.Width - 40, Height: 100,
    
    Gallery(
      Items: [
        {
          Title: "Features", 
          Value: Text(CountRows(Filter(colFeatures, SiteId = varSelectedSite.SiteId))), 
          Icon: "🌿", 
          Color: varTheme.Success
        },
        {
          Title: "Active Assessments", 
          Value: Text(CountRows(Filter(colAssessments, SiteId = varSelectedSite.SiteId And Status <> "Completed"))), 
          Icon: "📋", 
          Color: varTheme.Info
        },
        {
          Title: "Completed This Year", 
          Value: Text(CountRows(Filter(colAssessments, SiteId = varSelectedSite.SiteId And Year(CreatedOn) = Year(Now()) And Status = "Completed"))), 
          Icon: "✅", 
          Color: varTheme.Primary
        },
        {
          Title: "Overall Condition", 
          Value: "68% Favourable", 
          Icon: "📊", 
          Color: varTheme.Warning
        }
      ],
      X: 0, Y: 0, Width: Parent.Width, Height: 100,
      Layout: Layout.Horizontal,
      TemplateSize: (Parent.Width - 40) / 4,
      
      Rectangle(
        Fill: Color.White,
        BorderColor: varTheme.Surface,
        BorderThickness: 1,
        RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
        
        Label(
          Text: ThisItem.Icon,
          X: 15, Y: 15, Width: 30, Height: 30,
          Size: 18
        ),
        
        Label(
          Text: ThisItem.Value,
          X: 55, Y: 15, Width: Parent.TemplateWidth - 70, Height: 25,
          Color: ThisItem.Color,
          Font: Font.'Segoe UI',
          Size: 18,
          FontWeight: FontWeight.Bold
        ),
        
        Label(
          Text: ThisItem.Title,
          X: 15, Y: 50, Width: Parent.TemplateWidth - 30, Height: 30,
          Color: varTheme.TextLight,
          Font: Font.'Segoe UI',
          Size: 10,
          Wrap: true
        )
      )
    )
  )
);