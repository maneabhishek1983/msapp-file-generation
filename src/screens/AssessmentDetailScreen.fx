// Natural England Condition Assessment Demo - Assessment Detail Screen
// Comprehensive view of individual assessment with full data and analysis

Screen(
  Fill: varTheme.Background,
  
  // Header Banner with Assessment Information
  Rectangle(
    X: 0, Y: 0, Width: Parent.Width, Height: 100,
    Fill: varTheme.Primary,
    
    Button(
      Text: "← Back",
      X: 20, Y: 25, Width: 60, Height: 30,
      Fill: Color.Transparent,
      Color: Color.White,
      BorderColor: Color.White,
      BorderThickness: 1,
      Font: Font.'Segoe UI',
      Size: 11,
      RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4,
      OnSelect: Back()
    ),
    
    Label(
      Text: If(IsBlank(varSelectedAssessment), "Assessment Details", 
               LookUp(colSites, SiteId = varSelectedAssessment.SiteId, SiteName) & " – " &
               LookUp(colFeatures, FeatureId = varSelectedAssessment.FeatureId, FeatureName)),
      X: 100, Y: 15, Width: Parent.Width - 250, Height: 30,
      Color: Color.White,
      Font: Font.'Segoe UI',
      Size: 16,
      FontWeight: FontWeight.Semibold
    ),
    
    Label(
      Text: If(IsBlank(varSelectedAssessment), "", 
               "Assessment ID: " & varSelectedAssessment.AssessmentId & " • " &
               Text(varSelectedAssessment.CreatedOn, "dd/mm/yyyy")),
      X: 100, Y: 50, Width: Parent.Width - 250, Height: 20,
      Color: ColorFade(Color.White, 0.2),
      Font: Font.'Segoe UI',
      Size: 11
    ),
    
    // Status and Actions
    Container(
      X: Parent.Width - 140, Y: 15, Width: 120, Height: 70,
      
      Label(
        Text: If(IsBlank(varSelectedAssessment), "Unknown", varSelectedAssessment.Status),
        X: 0, Y: 0, Width: 120, Height: 25,
        Color: Color.White,
        Fill: Switch(varSelectedAssessment.Status,
          "Completed", varTheme.Success,
          "AwaitingReview", varTheme.Warning,
          "InField", varTheme.Info,
          "UnderReview", varTheme.Accent,
          varTheme.TextLight
        ),
        Align: Align.Center,
        Font: Font.'Segoe UI',
        Size: 10,
        FontWeight: FontWeight.Semibold,
        RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4
      )
    )
  ),
  
  // Assessment Overview Cards
  Container(
    X: 20, Y: 120, Width: Parent.Width - 40, Height: 120,
    
    Gallery(
      Items: [
        {
          Title: "Overall Score", 
          Value: "85/100", 
          Icon: "🎯", 
          Color: varTheme.Success,
          Subtitle: "High Quality"
        },
        {
          Title: "Data Completeness", 
          Value: "94%", 
          Icon: "📊", 
          Color: varTheme.Info,
          Subtitle: "6 attributes missing"
        },
        {
          Title: "Photo Coverage", 
          Value: "12/15", 
          Icon: "📷", 
          Color: varTheme.Warning,
          Subtitle: "3 points pending"
        },
        {
          Title: "Condition Result", 
          Value: If(IsBlank(varSelectedAssessment.FinalCondition), "Pending", varSelectedAssessment.FinalCondition), 
          Icon: "🌿", 
          Color: Switch(varSelectedAssessment.FinalCondition,
            "Favourable", varTheme.Success,
            "Unfavourable – Recovering", varTheme.Warning,
            "Unfavourable – Declining", varTheme.Error,
            varTheme.TextLight
          ),
          Subtitle: If(IsBlank(varSelectedAssessment.Confidence), "TBD", varSelectedAssessment.Confidence & " confidence")
        }
      ],
      X: 0, Y: 0, Width: Parent.Width, Height: 120,
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
          Size: 20
        ),
        
        Label(
          Text: ThisItem.Value,
          X: 55, Y: 15, Width: Parent.TemplateWidth - 70, Height: 30,
          Color: ThisItem.Color,
          Font: Font.'Segoe UI',
          Size: 16,
          FontWeight: FontWeight.Bold
        ),
        
        Label(
          Text: ThisItem.Title,
          X: 15, Y: 50, Width: Parent.TemplateWidth - 30, Height: 20,
          Color: varTheme.Text,
          Font: Font.'Segoe UI',
          Size: 11,
          FontWeight: FontWeight.Semibold
        ),
        
        Label(
          Text: ThisItem.Subtitle,
          X: 15, Y: 75, Width: Parent.TemplateWidth - 30, Height: 30,
          Color: varTheme.TextLight,
          Font: Font.'Segoe UI',
          Size: 9,
          Wrap: true
        )
      )
    )
  )
);