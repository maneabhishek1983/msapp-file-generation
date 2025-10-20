// Natural England Condition Assessment Demo - Field Status Screen
// Map & Field Status - "Breckland Heath Survey 2025"

Screen(
  Fill: varTheme.Background,
  
  // Header Banner
  Rectangle(
    X: 0, Y: 0, Width: Parent.Width, Height: 80,
    Fill: varTheme.Primary,
    
    Label(
      Text: "🗺️ Field Progress - Breckland Heath Survey 2025",
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
  
  // Map Container (Left Panel)
  Container(
    X: 20, Y: 100, Width: (Parent.Width - 60) * 0.6, Height: Parent.Height - 200,
    
    Label(
      Text: "Survey Map & Progress",
      X: 0, Y: 0, Width: Parent.Width, Height: 30,
      Color: varTheme.Text,
      Font: Font.'Segoe UI',
      Size: 16,
      FontWeight: FontWeight.Semibold
    ),
    
    // Map Display Area
    Rectangle(
      X: 0, Y: 40, Width: Parent.Width, Height: Parent.Height - 180,
      Fill: varTheme.Surface,
      BorderColor: varTheme.TextLight,
      BorderThickness: 1,
      RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
      
      // Simulated Map Content
      Label(
        Text: "🗺️ Breckland Heath SSSI",
        X: 20, Y: 20, Width: Parent.Width - 40, Height: 30,
        Color: varTheme.Text,
        Font: Font.'Segoe UI',
        Size: 14,
        FontWeight: FontWeight.Semibold,
        Align: Align.Center
      )
    ),
    
    // Simulate Sync Button with Progress Animation
    Button(
      Text: If(varSyncInProgress, "⏳ Syncing...", "🔄 Simulate Sync"),
      X: 0, Y: Parent.Height - 80, Width: 120, Height: 35,
      Fill: If(varSyncInProgress, varTheme.TextLight, varTheme.Info),
      Color: Color.White,
      Font: Font.'Segoe UI',
      Size: 11,
      RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
      DisplayMode: If(varSyncInProgress, DisplayMode.Disabled, DisplayMode.Edit),
      OnSelect: 
        // Start sync animation
        Set(varSyncInProgress, true);
        
        // Simulate progress with timer
        Set(varSyncTimer, 
          SetTimer(
            // Update transect statuses to simulate sync
            UpdateIf(colTransects, TransectId = "T2", {Status: "Complete", StopsRecorded: 12, LastUpdate: Now()});
            UpdateIf(colTransects, TransectId = "T3", {Status: "InProgress", StopsRecorded: 6, LastUpdate: Now()});
            
            // Update photo points
            UpdateIf(colPhotoPoints, PointId = "P3", {Status: "Complete", PhotoCount: 2, LastUpdate: Now()});
            UpdateIf(colPhotoPoints, PointId = "P5", {Status: "InProgress", PhotoCount: 1, LastUpdate: Now()});
            
            // Update last sync time
            Set(varLastSyncTime, Now());
            
            // Log sync event
            Collect(colEventLog, {
              EventID: GUID(),
              EventType: "Simulate Sync",
              Timestamp: Now(),
              UserID: varCurrentUser.UserID,
              UserName: varCurrentUser.Name,
              CorrelationID: varGenerateCorrelationID(),
              Details: "Field data synchronized - Coverage: " & Round((Sum(colTransects, StopsRecorded) / Sum(colTransects, TotalStops)) * 100, 0) & "%",
              Screen: "FieldStatusScreen"
            });
            
            // End sync animation
            Set(varSyncInProgress, false);
            
            Notify("✅ Field data synchronized successfully. Coverage now " & Round((Sum(colTransects, StopsRecorded) / Sum(colTransects, TotalStops)) * 100, 0) & "%", NotificationType.Success, 3000),
            2000
          )
        )
    ),
    
    // Refresh Button
    Button(
      Text: "🔄 Refresh",
      X: 130, Y: Parent.Height - 80, Width: 80, Height: 35,
      Fill: varTheme.Surface,
      Color: varTheme.Text,
      Font: Font.'Segoe UI',
      Size: 11,
      RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
      OnSelect: 
        // Refresh data and update last refresh time
        Set(varLastRefreshTime, Now());
        Notify("📊 Data refreshed", NotificationType.Information, 2000)
    )
  ),
  
  // Status Panel (Right Panel)
  Container(
    X: (Parent.Width - 60) * 0.6 + 40, Y: 100, Width: (Parent.Width - 60) * 0.4, Height: Parent.Height - 200,
    
    Label(
      Text: "Assessment Status",
      X: 0, Y: 0, Width: Parent.Width, Height: 30,
      Color: varTheme.Text,
      Font: Font.'Segoe UI',
      Size: 16,
      FontWeight: FontWeight.Semibold
    ),
    
    // Progress Status Counts
    Container(
      X: 0, Y: 40, Width: Parent.Width, Height: 100,
      
      // Not Started Count
      Rectangle(
        X: 0, Y: 0, Width: (Parent.Width - 20) / 3, Height: 90,
        Fill: Color.White,
        BorderColor: varTheme.Surface,
        BorderThickness: 1,
        RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
        
        Label(
          Text: CountRows(Filter(colTransects, Status = "NotStarted")) + CountRows(Filter(colPhotoPoints, Status = "NotStarted")),
          X: 0, Y: 15, Width: Parent.Width, Height: 30,
          Color: varTheme.TextLight,
          Font: Font.'Segoe UI',
          Size: 24,
          FontWeight: FontWeight.Bold,
          Align: Align.Center
        ),
        
        Label(
          Text: "Not Started",
          X: 0, Y: 50, Width: Parent.Width, Height: 25,
          Color: varTheme.TextLight,
          Font: Font.'Segoe UI',
          Size: 10,
          Align: Align.Center
        )
      ),
      
      // In Progress Count
      Rectangle(
        X: (Parent.Width - 20) / 3 + 10, Y: 0, Width: (Parent.Width - 20) / 3, Height: 90,
        Fill: Color.White,
        BorderColor: varTheme.Warning,
        BorderThickness: 2,
        RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
        
        Label(
          Text: CountRows(Filter(colTransects, Status = "InProgress")) + CountRows(Filter(colPhotoPoints, Status = "InProgress")),
          X: 0, Y: 15, Width: Parent.Width, Height: 30,
          Color: varTheme.Warning,
          Font: Font.'Segoe UI',
          Size: 24,
          FontWeight: FontWeight.Bold,
          Align: Align.Center
        ),
        
        Label(
          Text: "In Progress",
          X: 0, Y: 50, Width: Parent.Width, Height: 25,
          Color: varTheme.Warning,
          Font: Font.'Segoe UI',
          Size: 10,
          Align: Align.Center
        )
      ),
      
      // Complete Count
      Rectangle(
        X: 2 * (Parent.Width - 20) / 3 + 20, Y: 0, Width: (Parent.Width - 20) / 3, Height: 90,
        Fill: Color.White,
        BorderColor: varTheme.Success,
        BorderThickness: 2,
        RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
        
        Label(
          Text: CountRows(Filter(colTransects, Status = "Complete")) + CountRows(Filter(colPhotoPoints, Status = "Complete")),
          X: 0, Y: 15, Width: Parent.Width, Height: 30,
          Color: varTheme.Success,
          Font: Font.'Segoe UI',
          Size: 24,
          FontWeight: FontWeight.Bold,
          Align: Align.Center
        ),
        
        Label(
          Text: "Complete",
          X: 0, Y: 50, Width: Parent.Width, Height: 25,
          Color: varTheme.Success,
          Font: Font.'Segoe UI',
          Size: 10,
          Align: Align.Center
        )
      )
    ),
    
    // Assessment Summary Card
    Rectangle(
      X: 0, Y: 150, Width: Parent.Width, Height: 120,
      Fill: Color.White,
      BorderColor: varTheme.Surface,
      BorderThickness: 1,
      RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
      
      Label(
        Text: "Breckland Heath – Lowland Heathland",
        X: 15, Y: 15, Width: Parent.Width - 30, Height: 25,
        Color: varTheme.Text,
        Font: Font.'Segoe UI',
        Size: 13,
        FontWeight: FontWeight.Semibold
      ),
      
      Label(
        Text: "Last Sync: " & If(IsBlank(varLastSyncTime), "Never", Text(varLastSyncTime, "dd/mm/yyyy hh:mm")),
        X: 15, Y: 45, Width: Parent.Width - 30, Height: 20,
        Color: varTheme.TextLight,
        Font: Font.'Segoe UI',
        Size: 11
      ),
      
      Label(
        Text: "Assessor: " & LookUp(colUsers, UserID = First(colAssessments).CreatedBy, Name),
        X: 15, Y: 65, Width: Parent.Width - 30, Height: 20,
        Color: varTheme.TextLight,
        Font: Font.'Segoe UI',
        Size: 11
      ),
      
      Label(
        Text: "Coverage: " & Round((Sum(colTransects, StopsRecorded) / Sum(colTransects, TotalStops)) * 100, 0) & "%",
        X: 15, Y: 85, Width: Parent.Width - 30, Height: 20,
        Color: If((Sum(colTransects, StopsRecorded) / Sum(colTransects, TotalStops)) * 100 >= 90, varTheme.Success, 
                If((Sum(colTransects, StopsRecorded) / Sum(colTransects, TotalStops)) * 100 >= 70, varTheme.Warning, varTheme.Error)),
        Font: Font.'Segoe UI',
        Size: 11,
        FontWeight: FontWeight.Semibold
      )
    ),
    
    // Layer Details Section
    Label(
      Text: "Layer Details",
      X: 0, Y: 280, Width: Parent.Width, Height: 25,
      Color: varTheme.Text,
      Font: Font.'Segoe UI',
      Size: 14,
      FontWeight: FontWeight.Semibold
    ),
    
    // Transects Gallery
    Gallery(
      Items: colTransects,
      X: 0, Y: 310, Width: Parent.Width, Height: 120,
      Layout: Layout.Vertical,
      TemplateSize: 35,
      
      Rectangle(
        Fill: Color.White,
        BorderColor: varTheme.Surface,
        BorderThickness: 1,
        RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4,
        Width: Parent.TemplateWidth - 10,
        Height: Parent.TemplateHeight - 5,
        
        // Status Indicator
        Rectangle(
          X: 5, Y: 5, Width: 8, Height: Parent.Height - 10,
          Fill: Switch(ThisItem.Status,
            "Complete", varTheme.Success,
            "InProgress", varTheme.Warning,
            "NotStarted", varTheme.TextLight,
            varTheme.TextLight
          ),
          RadiusTopLeft: 2, RadiusTopRight: 2, RadiusBottomLeft: 2, RadiusBottomRight: 2
        ),
        
        Label(
          Text: ThisItem.Name,
          X: 20, Y: 5, Width: 120, Height: 15,
          Color: varTheme.Text,
          Font: Font.'Segoe UI',
          Size: 10,
          FontWeight: FontWeight.Semibold
        ),
        
        Label(
          Text: ThisItem.StopsRecorded & "/" & ThisItem.TotalStops & " stops",
          X: 20, Y: 20, Width: 80, Height: 10,
          Color: varTheme.TextLight,
          Font: Font.'Segoe UI',
          Size: 9
        ),
        
        Label(
          Text: If(IsBlank(ThisItem.LastUpdate), "Not started", "Updated: " & Text(ThisItem.LastUpdate, "dd/mm hh:mm")),
          X: 150, Y: 5, Width: Parent.Width - 160, Height: 15,
          Color: varTheme.TextLight,
          Font: Font.'Segoe UI',
          Size: 9
        ),
        
        Label(
          Text: If(IsBlank(ThisItem.Notes), "No notes", ThisItem.Notes),
          X: 150, Y: 20, Width: Parent.Width - 160, Height: 10,
          Color: varTheme.TextLight,
          Font: Font.'Segoe UI',
          Size: 8
        )
      )
    ),
    
    // Photo Points Gallery
    Gallery(
      Items: colPhotoPoints,
      X: 0, Y: 440, Width: Parent.Width, Height: 100,
      Layout: Layout.Vertical,
      TemplateSize: 35,
      
      Rectangle(
        Fill: Color.White,
        BorderColor: varTheme.Surface,
        BorderThickness: 1,
        RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4,
        Width: Parent.TemplateWidth - 10,
        Height: Parent.TemplateHeight - 5,
        
        // Status Indicator
        Rectangle(
          X: 5, Y: 5, Width: 8, Height: Parent.Height - 10,
          Fill: Switch(ThisItem.Status,
            "Complete", varTheme.Success,
            "InProgress", varTheme.Warning,
            "NotStarted", varTheme.TextLight,
            varTheme.TextLight
          ),
          RadiusTopLeft: 2, RadiusTopRight: 2, RadiusBottomLeft: 2, RadiusBottomRight: 2
        ),
        
        Label(
          Text: ThisItem.Name,
          X: 20, Y: 5, Width: 120, Height: 15,
          Color: varTheme.Text,
          Font: Font.'Segoe UI',
          Size: 10,
          FontWeight: FontWeight.Semibold
        ),
        
        Label(
          Text: ThisItem.PhotoCount & " photos",
          X: 20, Y: 20, Width: 80, Height: 10,
          Color: varTheme.TextLight,
          Font: Font.'Segoe UI',
          Size: 9
        ),
        
        Label(
          Text: If(IsBlank(ThisItem.LastUpdate), "Not started", "Updated: " & Text(ThisItem.LastUpdate, "dd/mm hh:mm")),
          X: 150, Y: 5, Width: Parent.Width - 160, Height: 15,
          Color: varTheme.TextLight,
          Font: Font.'Segoe UI',
          Size: 9
        ),
        
        Label(
          Text: If(IsBlank(ThisItem.Notes), "No notes", ThisItem.Notes),
          X: 150, Y: 20, Width: Parent.Width - 160, Height: 10,
          Color: varTheme.TextLight,
          Font: Font.'Segoe UI',
          Size: 8
        )
      )
    ),
    
    // Action Buttons
    Button(
      Text: "📊 View Data Summary",
      X: 0, Y: Parent.Height - 80, Width: Parent.Width, Height: 35,
      Fill: varTheme.Primary,
      Color: Color.White,
      Font: Font.'Segoe UI',
      Size: 11,
      RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
      OnSelect: Navigate(ReviewScreen)
    ),
    
    Button(
      Text: "📱 Open Field Maps",
      X: 0, Y: Parent.Height - 40, Width: Parent.Width, Height: 35,
      Fill: varTheme.Info,
      Color: Color.White,
      Font: Font.'Segoe UI',
      Size: 11,
      RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
      OnSelect: Notify("Field Maps would open here (external app)", NotificationType.Information, 2000)
    )
  )
);