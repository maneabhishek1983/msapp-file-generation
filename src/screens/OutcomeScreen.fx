// Natural England Condition Assessment Demo - Outcome Screen
// "Feature Condition Decision" - Final condition determination

Screen(
  Fill: varTheme.Background,
  
  // Header Banner
  Rectangle(
    X: 0, Y: 0, Width: Parent.Width, Height: 80,
    Fill: varTheme.Primary,
    
    Label(
      Text: "📋 Feature Condition Decision",
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
  
  // Assessment Header
  Container(
    X: 20, Y: 100, Width: Parent.Width - 40, Height: 100,
    
    Rectangle(
      Fill: varTheme.Surface,
      RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
      
      Label(
        Text: "Breckland Heath – Lowland Heathland (2025)",
        X: 20, Y: 15, Width: Parent.Width - 40, Height: 30,
        Color: varTheme.Text,
        Font: Font.'Segoe UI',
        Size: 16,
        FontWeight: FontWeight.Semibold
      ),
      
      Label(
        Text: "Common Standards Monitoring Protocol: Heathland v4",
        X: 20, Y: 50, Width: Parent.Width - 40, Height: 20,
        Color: varTheme.TextLight,
        Font: Font.'Segoe UI',
        Size: 12
      ),
      
      Label(
        Text: "Reviewed by: " & LookUp(colUsers, UserId = "ben.hughes@naturalengland.org.uk", Name) & " | " & Text(Now(), "dd/mm/yyyy"),
        X: 20, Y: 70, Width: Parent.Width - 40, Height: 15,
        Color: varTheme.TextLight,
        Font: Font.'Segoe UI',
        Size: 10
      )
    )
  ),
  
  // System Suggestion
  Container(
    X: 20, Y: 220, Width: Parent.Width - 40, Height: 120,
    
    Label(
      Text: "System Condition Assessment",
      X: 0, Y: 0, Width: Parent.Width, Height: 30,
      Color: varTheme.Text,
      Font: Font.'Segoe UI',
      Size: 16,
      FontWeight: FontWeight.Semibold
    ),
    
    Rectangle(
      Fill: Color.White,
      BorderColor: varTheme.Success,
      BorderThickness: 2,
      RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
      
      Label(
        Text: "🤖 System suggests condition:",
        X: 20, Y: 15, Width: 200, Height: 25,
        Color: varTheme.Text,
        Font: Font.'Segoe UI',
        Size: 12
      ),
      
      Label(
        Text: "Favourable",
        X: 230, Y: 15, Width: 150, Height: 25,
        Color: varTheme.Success,
        Font: Font.'Segoe UI',
        Size: 16,
        FontWeight: FontWeight.Bold
      ),
      
      Label(
        Text: "Based on mandatory attributes passing target thresholds",
        X: 20, Y: 45, Width: Parent.Width - 40, Height: 40,
        Color: varTheme.TextLight,
        Font: Font.'Segoe UI',
        Size: 11,
        Wrap: true
      )
    )
  ),
  
  // Action Buttons
  Container(
    X: 20, Y: Parent.Height - 80, Width: Parent.Width - 40, Height: 60,
    
    Button(
      Text: "💾 Save Outcome",
      X: Parent.Width - 200, Y: 10, Width: 180, Height: 40,
      Fill: varTheme.Success,
      Color: Color.White,
      Font: Font.'Segoe UI',
      Size: 12,
      FontWeight: FontWeight.Semibold,
      RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
      OnSelect: 
        // Update assessment with final outcome
        UpdateIf(colAssessments, AssessmentId = varFirstAssessmentId, {
          Status: "Completed",
          FinalCondition: "Favourable",
          Confidence: "High",
          Evidence: "Evidence of minor litter accumulation but overall stable structure.",
          CompletedOn: Now(),
          CompletedBy: varCurrentUser.UserId
        });
        
        // Success message and navigate back
        Notify("Condition outcome saved successfully. Assessment completed.", NotificationType.Success, 3000);
        Navigate(HomeScreen)
    ),
    
    Button(
      Text: "📊 View Reports",
      X: Parent.Width - 390, Y: 10, Width: 120, Height: 40,
      Fill: varTheme.Info,
      Color: Color.White,
      Font: Font.'Segoe UI',
      Size: 12,
      RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
      OnSelect: Navigate(ReportsScreen)
    ),
    
    Button(
      Text: "🔄 Back to Review",
      X: Parent.Width - 260, Y: 10, Width: 120, Height: 40,
      Fill: varTheme.Surface,
      Color: varTheme.Text,
      Font: Font.'Segoe UI',
      Size: 12,
      RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
      OnSelect: Navigate(ReviewScreen)
    )
  )
);