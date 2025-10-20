// Natural England Condition Assessment Demo - Home Screen
// "My Condition Assessments" - Main dashboard

Screen(
  Fill: varTheme.Background,
  
  // Header Banner
  Rectangle(
    X: 0, Y: 0, Width: Parent.Width, Height: 80,
    Fill: varTheme.Primary,
    
    // Natural England Logo and Title
    Label(
      Text: "Natural England – Condition Monitoring Portal",
      X: 20, Y: 20, Width: Parent.Width - 40, Height: 40,
      Color: Color.White,
      Font: Font.'Segoe UI',
      Size: 18,
      FontWeight: FontWeight.Semibold,
      AccessibleLabel: "Natural England Condition Monitoring Portal - Main Application Header"
    )
  ),
  
  // KPI Cards Section
  Label(
    Text: "Dashboard Overview",
    X: 20, Y: 100, Width: 300, Height: 30,
    Color: varTheme.Text,
    Font: Font.'Segoe UI',
    Size: 16,
    FontWeight: FontWeight.Semibold,
    AccessibleLabel: "Dashboard Overview Section - Key Performance Indicators"
  ),
  
  // KPI Cards Container
  Gallery(
    Items: [
      {Title: "Assessments Due This Quarter", Value: Text(varKPIs.AssessmentsDue), Icon: "Assessment", Color: varTheme.Info},
      {Title: "Awaiting Review", Value: Text(varKPIs.AwaitingReview), Icon: "Review", Color: varTheme.Warning},
      {Title: "Features Favourable (YTD)", Value: Text(varKPIs.FavourablePercentage) & "%", Icon: "Success", Color: varTheme.Success}
    ],
    X: 20, Y: 140, Width: Parent.Width - 40, Height: 120,
    Layout: Layout.Horizontal,
    TemplateSize: (Parent.Width - 80) / 3,
    
    // KPI Card Template
    Rectangle(
      Fill: Color.White,
      BorderColor: varTheme.Surface,
      BorderThickness: 1,
      RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
      
      Label(
        Text: ThisItem.Icon,
        X: 15, Y: 15, Width: 30, Height: 30,
        Size: 20,
        AccessibleLabel: ThisItem.Icon & " icon for " & ThisItem.Title
      ),
      
      Label(
        Text: ThisItem.Value,
        X: 55, Y: 15, Width: Parent.TemplateWidth - 70, Height: 35,
        Color: ThisItem.Color,
        Font: Font.'Segoe UI',
        Size: 24,
        FontWeight: FontWeight.Bold,
        AccessibleLabel: ThisItem.Title & " value: " & ThisItem.Value
      ),
      
      Label(
        Text: ThisItem.Title,
        X: 15, Y: 55, Width: Parent.TemplateWidth - 30, Height: 40,
        Color: varTheme.TextLight,
        Font: Font.'Segoe UI',
        Size: 12,
        Wrap: true,
        AccessibleLabel: ThisItem.Title & " KPI card"
      )
    )
  ),
  
  // Site Cards Section
  Label(
    Text: "Key SSSI Sites",
    X: 20, Y: 280, Width: 300, Height: 30,
    Color: varTheme.Text,
    Font: Font.'Segoe UI',
    Size: 16,
    FontWeight: FontWeight.Semibold
  ),
  
  // Site Cards Gallery
  Gallery(
    Items: Filter(colSites, Status = "Active"),
    X: 20, Y: 320, Width: Parent.Width - 40, Height: 200,
    Layout: Layout.Vertical,
    TemplateSize: 180,
    
    // Site Card Template
    Rectangle(
      Fill: Color.White,
      BorderColor: varTheme.Surface,
      BorderThickness: 1,
      RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
      
      Label(
        Text: ThisItem.SiteName,
        X: 15, Y: 15, Width: Parent.TemplateWidth - 120, Height: 25,
        Color: varTheme.Text,
        Font: Font.'Segoe UI',
        Size: 14,
        FontWeight: FontWeight.Semibold
      ),
      
      Label(
        Text: ThisItem.Region & " • " & ThisItem.Area,
        X: 15, Y: 45, Width: Parent.TemplateWidth - 120, Height: 20,
        Color: varTheme.TextLight,
        Font: Font.'Segoe UI',
        Size: 11
      ),
      
      Label(
        Text: ThisItem.Designation,
        X: 15, Y: 70, Width: 60, Height: 25,
        Color: Color.White,
        Fill: If(ThisItem.Designation = "SSSI", varTheme.Primary, 
               If(ThisItem.Designation = "SAC", varTheme.Accent, varTheme.Secondary)),
        Align: Align.Center,
        Font: Font.'Segoe UI',
        Size: 10,
        FontWeight: FontWeight.Semibold,
        RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4
      ),
      
      // Features count for this site
      Label(
        Text: CountRows(Filter(colFeatures, SiteId = ThisItem.SiteId)) & " features",
        X: 85, Y: 70, Width: 80, Height: 25,
        Color: varTheme.TextLight,
        Font: Font.'Segoe UI',
        Size: 10
      ),
      
      Button(
        Text: "View Details",
        X: Parent.TemplateWidth - 100, Y: 15, Width: 80, Height: 30,
        Fill: varTheme.Primary,
        Color: Color.White,
        Font: Font.'Segoe UI',
        Size: 11,
        RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4,
        OnSelect: Set(varSelectedSite, ThisItem); Navigate(SiteDetailScreen)
      )
    )
  ),
  
  // Action Buttons Section
  Label(
    Text: "Quick Actions",
    X: 20, Y: 540, Width: 300, Height: 30,
    Color: varTheme.Text,
    Font: Font.'Segoe UI',
    Size: 16,
    FontWeight: FontWeight.Semibold
  ),
  
  // Action Buttons Container (filtered by permissions)
  Gallery(
    Items: Filter([
      {Title: "Create New Assessment", Icon: "➕", Action: "CreateAssessment", Color: varTheme.Success, Permission: "CreateAssessment"},
      {Title: "View Field Progress", Icon: "🔍", Action: "ViewProgress", Color: varTheme.Info, Permission: "ViewAssessments"},
      {Title: "Review Submissions", Icon: "🧾", Action: "ReviewSubmissions", Color: varTheme.Warning, Permission: "ReviewAssessments"},
      {Title: "Reports & Exports", Icon: "📊", Action: "Reports", Color: varTheme.Accent, Permission: "ViewReports"}
    ], varHasPermission(Permission)),
    X: 20, Y: 580, Width: Parent.Width - 40, Height: 60,
    Layout: Layout.Horizontal,
    TemplateSize: (Parent.Width - 80) / 4,
    
    // Action Button Template
    Button(
      Text: ThisItem.Icon & " " & ThisItem.Title,
      Fill: ThisItem.Color,
      Color: Color.White,
      Font: Font.'Segoe UI',
      Size: 12,
      FontWeight: FontWeight.Semibold,
      RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
      OnSelect: Switch(ThisItem.Action,
        "CreateAssessment", Set(varWizardStep, 1); Navigate(AssessmentWizardScreen),
        "ViewProgress", Navigate(FieldStatusScreen),
        "ReviewSubmissions", Navigate(ReviewScreen),
        "Reports", Navigate(ReportsScreen)
      )
    )
  ),
  
  // Recent Activity Section
  Label(
    Text: "Recent Activity",
    X: 20, Y: 660, Width: 300, Height: 30,
    Color: varTheme.Text,
    Font: Font.'Segoe UI',
    Size: 16,
    FontWeight: FontWeight.Semibold
  ),
  
  // Recent Assessments Gallery
  Gallery(
    Items: colAssessments,
    X: 20, Y: 700, Width: Parent.Width - 40, Height: 150,
    Layout: Layout.Vertical,
    TemplateSize: 140,
    
    // Recent Assessment Template
    Rectangle(
      Fill: Color.White,
      BorderColor: varTheme.Surface,
      BorderThickness: 1,
      RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
      
      Label(
        Text: LookUp(colSites, SiteId = ThisItem.SiteId, SiteName) & " – " & 
              LookUp(colFeatures, FeatureId = ThisItem.FeatureId, FeatureName),
        X: 15, Y: 15, Width: Parent.TemplateWidth - 120, Height: 25,
        Color: varTheme.Text,
        Font: Font.'Segoe UI',
        Size: 13,
        FontWeight: FontWeight.Semibold
      ),
      
      Label(
        Text: "Created: " & Text(ThisItem.CreatedOn, "dd/mm/yyyy") & " by " & 
              LookUp(colUsers, UserId = ThisItem.CreatedBy, Name),
        X: 15, Y: 45, Width: Parent.TemplateWidth - 120, Height: 20,
        Color: varTheme.TextLight,
        Font: Font.'Segoe UI',
        Size: 11
      ),
      
      Label(
        Text: ThisItem.Status,
        X: 15, Y: 70, Width: 100, Height: 25,
        Color: Color.White,
        Fill: Switch(ThisItem.Status,
          "AwaitingReview", varTheme.Warning,
          "InField", varTheme.Info,
          "Approved", varTheme.Success,
          "UnderReview", varTheme.Accent,
          varTheme.TextLight
        ),
        Align: Align.Center,
        Font: Font.'Segoe UI',
        Size: 10,
        FontWeight: FontWeight.Semibold,
        RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4
      ),
      
      Button(
        Text: "Open",
        X: Parent.TemplateWidth - 80, Y: 15, Width: 60, Height: 30,
        Fill: varTheme.Primary,
        Color: Color.White,
        Font: Font.'Segoe UI',
        Size: 11,
        RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4,
        OnSelect: Set(varSelectedAssessment, ThisItem); 
                  Switch(ThisItem.Status,
                    "AwaitingReview", Navigate(ReviewScreen),
                    "InField", Navigate(FieldStatusScreen),
                    Navigate(AssessmentDetailScreen)
                  )
      )
    )
  )
);