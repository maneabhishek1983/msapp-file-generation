// Natural England Condition Assessment Demo - Assessment Wizard Screen
// Enhanced multi-step wizard for creating new condition assessments with validation guardrails

Screen(
  Fill: varTheme.Background,
  OnVisible: 
    // Initialize wizard state and preserve user entries
    If(IsBlank(varWizardInitialized),
      Set(varWizardStep, 1);
      Set(varWizardInitialized, true);
      Set(varWizardErrors, []);
      Set(varFocusedControl, "");
      // Initialize wizard data preservation
      Set(varWizardData, {
        Site: varSelectedSite,
        Feature: varSelectedFeature,
        Method: "CSM2020",
        Year: 2025,
        Cycle: "6-year",
        Attributes: varSelectedAttributes,
        WebMapID: "",
        Reviewer: Blank(),
        ValidationErrors: []
      })
    ),
  
  // Header Banner with breadcrumb navigation
  Rectangle(
    X: 0, Y: 0, Width: Parent.Width, Height: 100,
    Fill: varTheme.Primary,
    
    // Main title
    Label(
      Text: "🍃 Create Condition Assessment",
      X: 20, Y: 15, Width: Parent.Width - 120, Height: 30,
      Color: Color.White,
      Font: Font.'Segoe UI',
      Size: 18,
      FontWeight: FontWeight.Semibold,
      AccessibleLabel: "Create Condition Assessment wizard"
    ),
    
    // Breadcrumb navigation
    Label(
      Text: "Home > Create Assessment > " & 
        Switch(varWizardStep,
          1, "Site & Feature Selection",
          2, "Monitoring Attributes",
          3, "WebMap Configuration", 
          4, "Review & Publish",
          "Unknown Step"
        ),
      X: 20, Y: 45, Width: Parent.Width - 120, Height: 20,
      Color: RGBA(255, 255, 255, 0.8),
      Font: Font.'Segoe UI',
      Size: 11,
      AccessibleLabel: "Breadcrumb navigation: " & Self.Text
    ),
    
    Button(
      Text: "← Back to Home",
      X: Parent.Width - 100, Y: 30, Width: 80, Height: 30,
      Fill: Color.Transparent,
      Color: Color.White,
      BorderColor: Color.White,
      BorderThickness: 1,
      Font: Font.'Segoe UI',
      Size: 11,
      RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4,
      OnSelect: 
        // Confirm navigation away if user has made changes
        If(
          !IsBlank(varWizardData.Site) Or !IsBlank(varWizardData.Feature) Or !IsBlank(varWizardData.WebMapID),
          If(
            Confirm("You have unsaved changes. Are you sure you want to leave?"),
            Set(varWizardInitialized, false); Navigate(HomeScreen),
            false
          ),
          Set(varWizardInitialized, false); Navigate(HomeScreen)
        ),
      AccessibleLabel: "Return to home screen"
    )
  ),
  
  // Enhanced Progress Indicator with visual progress tracking
  Container(
    X: 20, Y: 120, Width: Parent.Width - 40, Height: 80,
    
    // Progress bar background
    Rectangle(
      X: 0, Y: 35, Width: Parent.Width, Height: 4,
      Fill: varTheme.SurfaceDark,
      RadiusTopLeft: 2, RadiusTopRight: 2, RadiusBottomLeft: 2, RadiusBottomRight: 2
    ),
    
    // Progress bar fill
    Rectangle(
      X: 0, Y: 35, Width: Parent.Width * (varWizardStep - 1) / 3, Height: 4,
      Fill: varTheme.Success,
      RadiusTopLeft: 2, RadiusTopRight: 2, RadiusBottomLeft: 2, RadiusBottomRight: 2
    ),
    
    // Step indicators
    Gallery(
      Items: [
        {Step: 1, Title: "Site & Feature", Description: "Choose site and habitat feature", Active: varWizardStep = 1, Complete: varWizardStep > 1, HasErrors: CountRows(Filter(varWizardErrors, Step = 1)) > 0},
        {Step: 2, Title: "Monitoring Pack", Description: "Select monitoring attributes", Active: varWizardStep = 2, Complete: varWizardStep > 2, HasErrors: CountRows(Filter(varWizardErrors, Step = 2)) > 0},
        {Step: 3, Title: "WebMap Config", Description: "Configure spatial references", Active: varWizardStep = 3, Complete: varWizardStep > 3, HasErrors: CountRows(Filter(varWizardErrors, Step = 3)) > 0},
        {Step: 4, Title: "Review & Publish", Description: "Review and publish assessment", Active: varWizardStep = 4, Complete: varWizardStep > 4, HasErrors: CountRows(Filter(varWizardErrors, Step = 4)) > 0}
      ],
      X: 0, Y: 0, Width: Parent.Width, Height: 70,
      Layout: Layout.Horizontal,
      TemplateSize: Parent.Width / 4,
      
      Container(
        Width: Parent.TemplateWidth,
        Height: 70,
        
        // Step circle
        Circle(
          X: (Parent.TemplateWidth - 40) / 2, Y: 20, Width: 40, Height: 40,
          Fill: If(ThisItem.HasErrors, varTheme.Error,
                  If(ThisItem.Complete, varTheme.Success, 
                    If(ThisItem.Active, varTheme.Primary, varTheme.Surface))),
          BorderColor: If(ThisItem.Active, varTheme.Primary, varTheme.Border),
          BorderThickness: If(ThisItem.Active, 2, 1),
          
          // Step number or checkmark
          Label(
            Text: If(ThisItem.Complete And !ThisItem.HasErrors, "✓", Text(ThisItem.Step)),
            Color: If(ThisItem.Complete Or ThisItem.Active Or ThisItem.HasErrors, Color.White, varTheme.TextLight),
            Font: Font.'Segoe UI',
            Size: If(ThisItem.Complete And !ThisItem.HasErrors, 16, 14),
            FontWeight: FontWeight.Bold,
            Align: Align.Center,
            AccessibleLabel: If(ThisItem.Complete, "Step " & ThisItem.Step & " completed", 
                               If(ThisItem.Active, "Current step " & ThisItem.Step, 
                                 If(ThisItem.HasErrors, "Step " & ThisItem.Step & " has errors", "Step " & ThisItem.Step)))
          )
        ),
        
        // Step title
        Label(
          Text: ThisItem.Title,
          X: 0, Y: 65, Width: Parent.TemplateWidth, Height: 15,
          Color: If(ThisItem.Active, varTheme.Primary, 
                   If(ThisItem.HasErrors, varTheme.Error, varTheme.Text)),
          Font: Font.'Segoe UI',
          Size: 10,
          FontWeight: If(ThisItem.Active, FontWeight.Semibold, FontWeight.Normal),
          Align: Align.Center,
          AccessibleLabel: ThisItem.Title & ". " & ThisItem.Description
        )
      )
    )
  ),
  
  // Error Banner - Top-level error display
  If(CountRows(varWizardErrors) > 0,
    Container(
      X: 20, Y: 220, Width: Parent.Width - 40, Height: 60,
      
      Rectangle(
        Fill: RGBA(220, 53, 69, 0.1),
        BorderColor: varTheme.Error,
        BorderThickness: 1,
        RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
        
        Icon(
          Icon: Icon.Warning,
          X: 15, Y: 15, Width: 20, Height: 20,
          Color: varTheme.Error
        ),
        
        Label(
          Text: "Please correct the following errors:",
          X: 45, Y: 10, Width: Parent.Width - 60, Height: 20,
          Color: varTheme.Error,
          Font: Font.'Segoe UI',
          Size: 12,
          FontWeight: FontWeight.Semibold
        ),
        
        Label(
          Text: Concat(varWizardErrors, Message, "; "),
          X: 45, Y: 30, Width: Parent.Width - 60, Height: 20,
          Color: varTheme.Error,
          Font: Font.'Segoe UI',
          Size: 11,
          Wrap: true,
          AccessibleLabel: "Validation errors: " & Self.Text
        )
      )
    )
  ),
  
  // Step 1: Site and Feature Selection
  If(varWizardStep = 1,
    Container(
      X: 20, Y: If(CountRows(varWizardErrors) > 0, 300, 240), Width: Parent.Width - 40, Height: 450,
      
      Label(
        Text: "Step 1: Site & Feature Selection",
        X: 0, Y: 0, Width: Parent.Width, Height: 30,
        Color: varTheme.Text,
        Font: Font.'Segoe UI',
        Size: 16,
        FontWeight: FontWeight.Semibold,
        AccessibleLabel: "Step 1: Site and Feature Selection"
      ),
      
      Label(
        Text: "Select the SSSI site and habitat feature for this condition assessment.",
        X: 0, Y: 35, Width: Parent.Width, Height: 20,
        Color: varTheme.TextSecondary,
        Font: Font.'Segoe UI',
        Size: 11
      ),
      
      // Site Selection with Region Filtering
      Container(
        X: 0, Y: 70, Width: Parent.Width, Height: 120,
        
        Label(
          Text: "Choose Site (SSSI):",
          X: 0, Y: 0, Width: 150, Height: 25,
          Color: varTheme.Text,
          Font: Font.'Segoe UI',
          Size: 12,
          AccessibleLabel: "Site selection required"
        ),
        
        // Region filter
        Label(
          Text: "Filter by Region:",
          X: 0, Y: 30, Width: 150, Height: 20,
          Color: varTheme.TextSecondary,
          Font: Font.'Segoe UI',
          Size: 10
        ),
        
        Dropdown(
          Items: Distinct(colSites, Region),
          DefaultSelectedItems: If(IsBlank(varRegionFilter), Blank(), [varRegionFilter]),
          X: 160, Y: 30, Width: 200, Height: 25,
          DisplayFields: ["Value"],
          SearchFields: ["Value"],
          OnChange: Set(varRegionFilter, Self.Selected.Value); Set(varWizardData, Patch(varWizardData, {Site: Blank()})),
          AccessibleLabel: "Filter sites by region"
        ),
        
        Button(
          Text: "Clear Filter",
          X: 370, Y: 30, Width: 80, Height: 25,
          Fill: varTheme.Surface,
          Color: varTheme.Text,
          BorderColor: varTheme.Border,
          BorderThickness: 1,
          Font: Font.'Segoe UI',
          Size: 10,
          RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4,
          OnSelect: Set(varRegionFilter, Blank()),
          AccessibleLabel: "Clear region filter"
        ),
        
        Dropdown(
          Items: If(IsBlank(varRegionFilter), colSites, Filter(colSites, Region = varRegionFilter)),
          DefaultSelectedItems: If(IsBlank(varWizardData.Site), Blank(), [varWizardData.Site]),
          X: 160, Y: 60, Width: 350, Height: 35,
          DisplayFields: ["SiteName"],
          SearchFields: ["SiteName", "Region", "SiteType"],
          OnChange: 
            Set(varWizardData, Patch(varWizardData, {Site: Self.Selected, Feature: Blank()}));
            // Clear site-related errors
            Set(varWizardErrors, Filter(varWizardErrors, !(Field = "Site" And Step = 1))),
          TabIndex: If(varFocusedControl = "Site", 0, -1),
          AccessibleLabel: "Select SSSI site for assessment. Search by site name, region, or site type."
        ),
        
        // Site validation error
        If(CountRows(Filter(varWizardErrors, Field = "Site" And Step = 1)) > 0,
          Label(
            Text: First(Filter(varWizardErrors, Field = "Site" And Step = 1)).Message,
            X: 160, Y: 100, Width: 350, Height: 15,
            Color: varTheme.Error,
            Font: Font.'Segoe UI',
            Size: 10
          )
        )
      ),
      
      // Feature Selection with CSM Method Integration
      If(!IsBlank(varWizardData.Site),
        Container(
          X: 0, Y: 200, Width: Parent.Width, Height: 200,
          
          Label(
            Text: "Choose Habitat Feature:",
            X: 0, Y: 0, Width: 150, Height: 25,
            Color: varTheme.Text,
            Font: Font.'Segoe UI',
            Size: 12,
            AccessibleLabel: "Feature selection required"
          ),
          
          Dropdown(
            Items: colFeatures,
            DefaultSelectedItems: If(IsBlank(varWizardData.Feature), Blank(), [varWizardData.Feature]),
            X: 160, Y: 0, Width: 350, Height: 35,
            DisplayFields: ["FeatureName"],
            SearchFields: ["FeatureName", "FeatureCode", "Category"],
            OnChange: 
              Set(varWizardData, Patch(varWizardData, {Feature: Self.Selected}));
              // Clear feature-related errors
              Set(varWizardErrors, Filter(varWizardErrors, !(Field = "Feature" And Step = 1))),
            TabIndex: If(varFocusedControl = "Feature", 0, -1),
            AccessibleLabel: "Select habitat feature. Search by feature name, EU code, or category."
          ),
          
          // Feature validation error
          If(CountRows(Filter(varWizardErrors, Field = "Feature" And Step = 1)) > 0,
            Label(
              Text: First(Filter(varWizardErrors, Field = "Feature" And Step = 1)).Message,
              X: 160, Y: 40, Width: 350, Height: 15,
              Color: varTheme.Error,
              Font: Font.'Segoe UI',
              Size: 10
            )
          ),
          
          // Year/Cycle Selection with Current Year Default
          Label(
            Text: "Monitoring Cycle:",
            X: 0, Y: 60, Width: 150, Height: 25,
            Color: varTheme.Text,
            Font: Font.'Segoe UI',
            Size: 12
          ),
          
          Dropdown(
            Items: [
              {Year: 2025, Cycle: "6-year", Display: "2025 - 6 Year Cycle"},
              {Year: 2024, Cycle: "6-year", Display: "2024 - 6 Year Cycle"},
              {Year: 2023, Cycle: "6-year", Display: "2023 - 6 Year Cycle"}
            ],
            DefaultSelectedItems: [{Year: 2025, Cycle: "6-year", Display: "2025 - 6 Year Cycle"}],
            X: 160, Y: 60, Width: 200, Height: 35,
            DisplayFields: ["Display"],
            OnChange: Set(varWizardData, Patch(varWizardData, {Year: Self.Selected.Year, Cycle: Self.Selected.Cycle})),
            AccessibleLabel: "Select monitoring year and cycle. Default is current year 2025."
          ),
          
          // Method Selection
          Label(
            Text: "Method:",
            X: 0, Y: 110, Width: 150, Height: 25,
            Color: varTheme.Text,
            Font: Font.'Segoe UI',
            Size: 12
          ),
          
          Label(
            Text: "CSM 2020 (Common Standards Monitoring)",
            X: 160, Y: 110, Width: 300, Height: 25,
            Color: varTheme.TextSecondary,
            Font: Font.'Segoe UI',
            Size: 12,
            FontWeight: FontWeight.Semibold,
            AccessibleLabel: "Method: CSM 2020 Common Standards Monitoring"
          ),
          
          // Site/Feature Dependency Validation and Summary
          If(!IsBlank(varWizardData.Feature),
            Container(
              X: 0, Y: 150, Width: Parent.Width, Height: 80,
              
              Rectangle(
                Fill: varTheme.Surface,
                BorderColor: varTheme.Success,
                BorderThickness: 1,
                RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
                
                Icon(
                  Icon: Icon.CheckMark,
                  X: 15, Y: 15, Width: 20, Height: 20,
                  Color: varTheme.Success
                ),
                
                Label(
                  Text: "Selected: " & varWizardData.Site.SiteName & " – " & varWizardData.Feature.FeatureName & " (" & varWizardData.Feature.FeatureCode & ")",
                  X: 45, Y: 10, Width: Parent.Width - 60, Height: 25,
                  Color: varTheme.Text,
                  Font: Font.'Segoe UI',
                  Size: 12,
                  FontWeight: FontWeight.Semibold,
                  Wrap: true
                ),
                
                Label(
                  Text: varWizardData.Feature.Description,
                  X: 45, Y: 35, Width: Parent.Width - 60, Height: 35,
                  Color: varTheme.TextSecondary,
                  Font: Font.'Segoe UI',
                  Size: 11,
                  Wrap: true,
                  AccessibleLabel: "Feature description: " & Self.Text
                )
              )
            )
          )
        )
      )
    )
  ),
  
  // Step 2: Monitoring Attributes Selection
  If(varWizardStep = 2,
    Container(
      X: 20, Y: If(CountRows(varWizardErrors) > 0, 300, 240), Width: Parent.Width - 40, Height: 450,
      
      Label(
        Text: "Step 2: Monitoring Attributes",
        X: 0, Y: 0, Width: Parent.Width, Height: 30,
        Color: varTheme.Text,
        Font: Font.'Segoe UI',
        Size: 16,
        FontWeight: FontWeight.Semibold
      ),
      
      Label(
        Text: "Select the monitoring attributes for " & If(IsBlank(varWizardData.Feature), "this feature", varWizardData.Feature.FeatureName) & ". Mandatory attributes are marked with *.",
        X: 0, Y: 35, Width: Parent.Width, Height: 20,
        Color: varTheme.TextSecondary,
        Font: Font.'Segoe UI',
        Size: 11
      ),
      
      // Attributes selection gallery
      Gallery(
        Items: SortByColumns(colAttributes, "IsMandatory", Descending, "CategoryID", Ascending),
        X: 0, Y: 70, Width: Parent.Width, Height: 350,
        Layout: Layout.Vertical,
        TemplateSize: 80,
        
        Container(
          Width: Parent.TemplateWidth,
          Height: 75,
          
          Rectangle(
            Fill: If(ThisItem.AttributeID in varWizardData.Attributes.AttributeID, 
                    RGBA(40, 167, 69, 0.1), varTheme.Surface),
            BorderColor: If(ThisItem.IsMandatory, varTheme.Warning, varTheme.Border),
            BorderThickness: If(ThisItem.IsMandatory, 2, 1),
            RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
            
            Checkbox(
              Text: "",
              X: 15, Y: 15, Width: 20, Height: 20,
              Default: ThisItem.AttributeID in varWizardData.Attributes.AttributeID,
              OnCheck: 
                Set(varWizardData, Patch(varWizardData, {
                  Attributes: Distinct(Collect(varWizardData.Attributes, ThisItem), AttributeID)
                }));
                // Clear attribute-related errors
                Set(varWizardErrors, Filter(varWizardErrors, !(Field = "Attributes" And Step = 2))),
              OnUncheck: 
                If(!ThisItem.IsMandatory,
                  Set(varWizardData, Patch(varWizardData, {
                    Attributes: Filter(varWizardData.Attributes, AttributeID <> ThisItem.AttributeID)
                  }))
                ),
              AccessibleLabel: If(ThisItem.IsMandatory, "Mandatory attribute: ", "Optional attribute: ") & ThisItem.AttributeName
            ),
            
            Label(
              Text: ThisItem.AttributeName & If(ThisItem.IsMandatory, " *", ""),
              X: 45, Y: 10, Width: Parent.TemplateWidth - 60, Height: 20,
              Color: If(ThisItem.IsMandatory, varTheme.Warning, varTheme.Text),
              Font: Font.'Segoe UI',
              Size: 12,
              FontWeight: If(ThisItem.IsMandatory, FontWeight.Semibold, FontWeight.Normal)
            ),
            
            Label(
              Text: ThisItem.Description,
              X: 45, Y: 30, Width: Parent.TemplateWidth - 60, Height: 15,
              Color: varTheme.TextSecondary,
              Font: Font.'Segoe UI',
              Size: 10,
              Wrap: true
            ),
            
            Label(
              Text: If(!IsBlank(ThisItem.HelpText), "ℹ️ " & ThisItem.HelpText, ""),
              X: 45, Y: 50, Width: Parent.TemplateWidth - 60, Height: 20,
              Color: varTheme.Info,
              Font: Font.'Segoe UI',
              Size: 9,
              Wrap: true
            )
          )
        )
      ),
      
      // Attributes validation error
      If(CountRows(Filter(varWizardErrors, Field = "Attributes" And Step = 2)) > 0,
        Label(
          Text: First(Filter(varWizardErrors, Field = "Attributes" And Step = 2)).Message,
          X: 0, Y: 430, Width: Parent.Width, Height: 15,
          Color: varTheme.Error,
          Font: Font.'Segoe UI',
          Size: 10
        )
      )
    )
  ),
  
  // Step 3: AGOL WebMap Configuration and Validation
  If(varWizardStep = 3,
    Container(
      X: 20, Y: If(CountRows(varWizardErrors) > 0, 300, 240), Width: Parent.Width - 40, Height: 450,
      
      Label(
        Text: "Step 3: WebMap Configuration",
        X: 0, Y: 0, Width: Parent.Width, Height: 30,
        Color: varTheme.Text,
        Font: Font.'Segoe UI',
        Size: 16,
        FontWeight: FontWeight.Semibold
      ),
      
      Label(
        Text: "Configure the ArcGIS Online WebMap for spatial data collection and visualization.",
        X: 0, Y: 35, Width: Parent.Width, Height: 20,
        Color: varTheme.TextSecondary,
        Font: Font.'Segoe UI',
        Size: 11
      ),
      
      // WebMap ID Input with Format Validation
      Container(
        X: 0, Y: 70, Width: Parent.Width, Height: 120,
        
        Label(
          Text: "WebMap ID (GUID):",
          X: 0, Y: 0, Width: 150, Height: 25,
          Color: varTheme.Text,
          Font: Font.'Segoe UI',
          Size: 12,
          AccessibleLabel: "WebMap ID required in GUID format"
        ),
        
        TextInput(
          Text: varWizardData.WebMapID,
          X: 160, Y: 0, Width: 350, Height: 35,
          HintText: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
          Font: Font.'Segoe UI',
          Size: 11,
          OnChange: 
            Set(varWizardData, Patch(varWizardData, {WebMapID: Self.Text}));
            // Real-time format validation
            Set(varWebMapValidation, varValidateWebMapID(Self.Text));
            // Clear WebMap-related errors if format becomes valid
            If(varWebMapValidation.FormatValid,
              Set(varWizardErrors, Filter(varWizardErrors, !(Field = "WebMapID" And Step = 3)))
            ),
          TabIndex: If(varFocusedControl = "WebMapID", 0, -1),
          AccessibleLabel: "Enter WebMap ID in GUID format. Example: a1b2c3d4-e5f6-7890-abcd-ef1234567890"
        ),
        
        // Format validation indicator
        If(!IsBlank(varWizardData.WebMapID),
          Container(
            X: 520, Y: 5, Width: 100, Height: 25,
            
            If(varWebMapValidation.FormatValid,
              Container(
                Icon(
                  Icon: Icon.CheckMark,
                  X: 0, Y: 0, Width: 20, Height: 20,
                  Color: varTheme.Success
                ),
                Label(
                  Text: "Valid Format",
                  X: 25, Y: 0, Width: 75, Height: 20,
                  Color: varTheme.Success,
                  Font: Font.'Segoe UI',
                  Size: 9
                )
              ),
              Container(
                Icon(
                  Icon: Icon.Cancel,
                  X: 0, Y: 0, Width: 20, Height: 20,
                  Color: varTheme.Error
                ),
                Label(
                  Text: "Invalid Format",
                  X: 25, Y: 0, Width: 75, Height: 20,
                  Color: varTheme.Error,
                  Font: Font.'Segoe UI',
                  Size: 9
                )
              )
            )
          )
        ),
        
        // WebMap validation error
        If(CountRows(Filter(varWizardErrors, Field = "WebMapID" And Step = 3)) > 0,
          Label(
            Text: First(Filter(varWizardErrors, Field = "WebMapID" And Step = 3)).Message,
            X: 160, Y: 40, Width: 350, Height: 15,
            Color: varTheme.Error,
            Font: Font.'Segoe UI',
            Size: 10
          )
        ),
        
        // Availability checking with retry mechanism
        If(!IsBlank(varWizardData.WebMapID) And varWebMapValidation.FormatValid,
          Container(
            X: 0, Y: 60, Width: Parent.Width, Height: 50,
            
            Button(
              Text: "🔍 Check Availability",
              X: 160, Y: 0, Width: 150, Height: 30,
              Fill: varTheme.Info,
              Color: Color.White,
              Font: Font.'Segoe UI',
              Size: 11,
              RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4,
              OnSelect: 
                // Simulate availability check with timeout handling
                Set(varWebMapChecking, true);
                Set(varWebMapCheckResult, Blank());
                // Simulate network delay
                Set(varWebMapCheckTimer, Timer.Start(2000));
                // Simulate availability result (demo logic)
                Set(varWebMapAvailable, 
                  varWizardData.WebMapID in [
                    "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
                    "b2c3d4e5-f6g7-8901-bcde-f23456789012",
                    "c3d4e5f6-g7h8-9012-cdef-345678901234"
                  ]
                );
                Set(varWebMapMetadata, If(varWebMapAvailable, {
                  Title: "Natural England Monitoring Sites 2025",
                  Description: "Transects, photo points, and monitoring stops for " & If(IsBlank(varWizardData.Site), "selected site", varWizardData.Site.SiteName),
                  LastUpdated: DateAdd(Now(), -3, Days),
                  Owner: "Natural England GIS Team"
                }, Blank())),
              AccessibleLabel: "Check if WebMap is available and accessible"
            ),
            
            If(varWebMapChecking,
              Container(
                X: 320, Y: 5, Width: 200, Height: 20,
                
                Label(
                  Text: "Checking availability...",
                  Color: varTheme.Info,
                  Font: Font.'Segoe UI',
                  Size: 10,
                  AccessibleLabel: "Checking WebMap availability, please wait"
                )
              )
            ),
            
            // Availability result
            If(!varWebMapChecking And !IsBlank(varWebMapCheckResult),
              If(varWebMapAvailable,
                Container(
                  X: 320, Y: 0, Width: 200, Height: 40,
                  
                  Icon(
                    Icon: Icon.CheckMark,
                    X: 0, Y: 0, Width: 20, Height: 20,
                    Color: varTheme.Success
                  ),
                  
                  Label(
                    Text: "WebMap Available",
                    X: 25, Y: 0, Width: 100, Height: 20,
                    Color: varTheme.Success,
                    Font: Font.'Segoe UI',
                    Size: 10,
                    FontWeight: FontWeight.Semibold
                  ),
                  
                  Button(
                    Text: "Preview Layers",
                    X: 130, Y: 0, Width: 70, Height: 20,
                    Fill: varTheme.Surface,
                    Color: varTheme.Text,
                    BorderColor: varTheme.Border,
                    BorderThickness: 1,
                    Font: Font.'Segoe UI',
                    Size: 9,
                    RadiusTopLeft: 3, RadiusTopRight: 3, RadiusBottomLeft: 3, RadiusBottomRight: 3,
                    OnSelect: Set(varShowLayerPreview, !varShowLayerPreview),
                    AccessibleLabel: "Preview WebMap layers and metadata"
                  )
                ),
                Container(
                  X: 320, Y: 0, Width: 200, Height: 40,
                  
                  Icon(
                    Icon: Icon.Cancel,
                    X: 0, Y: 0, Width: 20, Height: 20,
                    Color: varTheme.Error
                  ),
                  
                  Label(
                    Text: "WebMap Unavailable",
                    X: 25, Y: 0, Width: 100, Height: 20,
                    Color: varTheme.Error,
                    Font: Font.'Segoe UI',
                    Size: 10,
                    FontWeight: FontWeight.Semibold
                  ),
                  
                  Button(
                    Text: "Retry",
                    X: 130, Y: 0, Width: 40, Height: 20,
                    Fill: varTheme.Error,
                    Color: Color.White,
                    Font: Font.'Segoe UI',
                    Size: 9,
                    RadiusTopLeft: 3, RadiusTopRight: 3, RadiusBottomLeft: 3, RadiusBottomRight: 3,
                    OnSelect: Set(varWebMapCheckResult, Blank()),
                    AccessibleLabel: "Retry WebMap availability check"
                  )
                )
              )
            )
          )
        )
      ),
      
      // Layer Selection Interface with Preview
      If(varWebMapAvailable And varShowLayerPreview,
        Container(
          X: 0, Y: 200, Width: Parent.Width, Height: 200,
          
          Rectangle(
            Fill: varTheme.Surface,
            BorderColor: varTheme.Border,
            BorderThickness: 1,
            RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
            
            Label(
              Text: "Layer Selection & Preview",
              X: 15, Y: 10, Width: Parent.Width - 30, Height: 20,
              Color: varTheme.Text,
              Font: Font.'Segoe UI',
              Size: 12,
              FontWeight: FontWeight.Semibold
            ),
            
            Gallery(
              Items: [
                {LayerName: "Transects", Description: "Survey transect lines", Visible: true, Type: "Line"},
                {LayerName: "Photo Points", Description: "Photo monitoring locations", Visible: true, Type: "Point"},
                {LayerName: "Monitoring Stops", Description: "Detailed monitoring locations", Visible: true, Type: "Point"},
                {LayerName: "Site Boundary", Description: "SSSI boundary polygon", Visible: false, Type: "Polygon"}
              ],
              X: 15, Y: 35, Width: Parent.Width - 30, Height: 120,
              Layout: Layout.Vertical,
              TemplateSize: 25,
              
              Container(
                Width: Parent.TemplateWidth,
                Height: 20,
                
                Checkbox(
                  Text: "",
                  X: 0, Y: 0, Width: 20, Height: 20,
                  Default: ThisItem.Visible,
                  AccessibleLabel: "Toggle " & ThisItem.LayerName & " layer visibility"
                ),
                
                Label(
                  Text: ThisItem.LayerName,
                  X: 25, Y: 0, Width: 120, Height: 20,
                  Color: varTheme.Text,
                  Font: Font.'Segoe UI',
                  Size: 10,
                  FontWeight: FontWeight.Semibold
                ),
                
                Label(
                  Text: ThisItem.Description,
                  X: 150, Y: 0, Width: 200, Height: 20,
                  Color: varTheme.TextSecondary,
                  Font: Font.'Segoe UI',
                  Size: 9
                ),
                
                Label(
                  Text: ThisItem.Type,
                  X: 360, Y: 0, Width: 60, Height: 20,
                  Color: varTheme.TextLight,
                  Font: Font.'Segoe UI',
                  Size: 9
                )
              )
            )
          )
        )
      ),
      
      // WebMap Metadata Display
      If(varWebMapAvailable And !IsBlank(varWebMapMetadata),
        Container(
          X: 0, Y: If(varShowLayerPreview, 410, 210), Width: Parent.Width, Height: 100,
          
          Rectangle(
            Fill: RGBA(40, 167, 69, 0.1),
            BorderColor: varTheme.Success,
            BorderThickness: 1,
            RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
            
            Icon(
              Icon: Icon.Globe,
              X: 15, Y: 15, Width: 20, Height: 20,
              Color: varTheme.Success
            ),
            
            Label(
              Text: "WebMap Metadata",
              X: 45, Y: 10, Width: 150, Height: 20,
              Color: varTheme.Success,
              Font: Font.'Segoe UI',
              Size: 12,
              FontWeight: FontWeight.Semibold
            ),
            
            Label(
              Text: "Title: " & varWebMapMetadata.Title,
              X: 45, Y: 30, Width: Parent.Width - 60, Height: 15,
              Color: varTheme.Text,
              Font: Font.'Segoe UI',
              Size: 10
            ),
            
            Label(
              Text: "Description: " & varWebMapMetadata.Description,
              X: 45, Y: 45, Width: Parent.Width - 60, Height: 15,
              Color: varTheme.TextSecondary,
              Font: Font.'Segoe UI',
              Size: 10,
              Wrap: true
            ),
            
            Label(
              Text: "Last Updated: " & Text(varWebMapMetadata.LastUpdated, "dd/mm/yyyy") & " | Owner: " & varWebMapMetadata.Owner,
              X: 45, Y: 65, Width: Parent.Width - 60, Height: 15,
              Color: varTheme.TextLight,
              Font: Font.'Segoe UI',
              Size: 9
            )
          )
        )
      )
    )
  ),
  
  // Step 4: Review & Publish with Publishing Guardrails
  If(varWizardStep = 4,
    Container(
      X: 20, Y: If(CountRows(varWizardErrors) > 0, 300, 240), Width: Parent.Width - 40, Height: 450,
      
      Label(
        Text: "Step 4: Review & Publish",
        X: 0, Y: 0, Width: Parent.Width, Height: 30,
        Color: varTheme.Text,
        Font: Font.'Segoe UI',
        Size: 16,
        FontWeight: FontWeight.Semibold
      ),
      
      Label(
        Text: "Review your assessment configuration and assign a reviewer before publishing.",
        X: 0, Y: 35, Width: Parent.Width, Height: 20,
        Color: varTheme.TextSecondary,
        Font: Font.'Segoe UI',
        Size: 11
      ),
      
      // Reviewer Assignment with Role Validation
      Container(
        X: 0, Y: 70, Width: Parent.Width, Height: 80,
        
        Label(
          Text: "Assign Reviewer:",
          X: 0, Y: 0, Width: 150, Height: 25,
          Color: varTheme.Text,
          Font: Font.'Segoe UI',
          Size: 12,
          AccessibleLabel: "Reviewer assignment required"
        ),
        
        Dropdown(
          Items: Filter(colUsers, Role in ["Reviewer", "Manager"]),
          DefaultSelectedItems: If(IsBlank(varWizardData.Reviewer), Blank(), [varWizardData.Reviewer]),
          X: 160, Y: 0, Width: 300, Height: 35,
          DisplayFields: ["Name"],
          SearchFields: ["Name", "Team", "Region"],
          OnChange: 
            Set(varWizardData, Patch(varWizardData, {Reviewer: Self.Selected}));
            // Clear reviewer-related errors
            Set(varWizardErrors, Filter(varWizardErrors, !(Field = "Reviewer" And Step = 4))),
          TabIndex: If(varFocusedControl = "Reviewer", 0, -1),
          AccessibleLabel: "Select reviewer from available reviewers and managers. Search by name, team, or region."
        ),
        
        // Reviewer availability checking
        If(!IsBlank(varWizardData.Reviewer),
          Label(
            Text: "✓ " & varWizardData.Reviewer.Name & " (" & varWizardData.Reviewer.Role & ", " & varWizardData.Reviewer.Team & ")",
            X: 160, Y: 40, Width: 300, Height: 20,
            Color: varTheme.Success,
            Font: Font.'Segoe UI',
            Size: 10,
            AccessibleLabel: "Selected reviewer: " & varWizardData.Reviewer.Name & ", role: " & varWizardData.Reviewer.Role & ", team: " & varWizardData.Reviewer.Team
          )
        ),
        
        // Reviewer validation error
        If(CountRows(Filter(varWizardErrors, Field = "Reviewer" And Step = 4)) > 0,
          Label(
            Text: First(Filter(varWizardErrors, Field = "Reviewer" And Step = 4)).Message,
            X: 160, Y: 60, Width: 300, Height: 15,
            Color: varTheme.Error,
            Font: Font.'Segoe UI',
            Size: 10
          )
        )
      ),
      
      // Assessment Summary
      Container(
        X: 0, Y: 160, Width: Parent.Width, Height: 200,
        
        Rectangle(
          Fill: varTheme.Surface,
          BorderColor: varTheme.Border,
          BorderThickness: 1,
          RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
          
          Label(
            Text: "Assessment Summary",
            X: 15, Y: 10, Width: Parent.Width - 30, Height: 20,
            Color: varTheme.Text,
            Font: Font.'Segoe UI',
            Size: 12,
            FontWeight: FontWeight.Semibold
          ),
          
          // Summary details
          Label(
            Text: "Site: " & If(IsBlank(varWizardData.Site), "Not selected", varWizardData.Site.SiteName & " (" & varWizardData.Site.Region & ")"),
            X: 15, Y: 35, Width: Parent.Width - 30, Height: 15,
            Color: If(IsBlank(varWizardData.Site), varTheme.Error, varTheme.Text),
            Font: Font.'Segoe UI',
            Size: 10
          ),
          
          Label(
            Text: "Feature: " & If(IsBlank(varWizardData.Feature), "Not selected", varWizardData.Feature.FeatureName & " (" & varWizardData.Feature.FeatureCode & ")"),
            X: 15, Y: 50, Width: Parent.Width - 30, Height: 15,
            Color: If(IsBlank(varWizardData.Feature), varTheme.Error, varTheme.Text),
            Font: Font.'Segoe UI',
            Size: 10
          ),
          
          Label(
            Text: "Attributes: " & If(CountRows(varWizardData.Attributes) = 0, "None selected", CountRows(varWizardData.Attributes) & " selected"),
            X: 15, Y: 65, Width: Parent.Width - 30, Height: 15,
            Color: If(CountRows(varWizardData.Attributes) = 0, varTheme.Error, varTheme.Text),
            Font: Font.'Segoe UI',
            Size: 10
          ),
          
          Label(
            Text: "WebMap ID: " & If(IsBlank(varWizardData.WebMapID), "Not provided", varWizardData.WebMapID),
            X: 15, Y: 80, Width: Parent.Width - 30, Height: 15,
            Color: If(IsBlank(varWizardData.WebMapID), varTheme.Error, varTheme.Text),
            Font: Font.'Segoe UI',
            Size: 10,
            Wrap: true
          ),
          
          Label(
            Text: "Reviewer: " & If(IsBlank(varWizardData.Reviewer), "Not assigned", varWizardData.Reviewer.Name),
            X: 15, Y: 95, Width: Parent.Width - 30, Height: 15,
            Color: If(IsBlank(varWizardData.Reviewer), varTheme.Error, varTheme.Text),
            Font: Font.'Segoe UI',
            Size: 10
          ),
          
          Label(
            Text: "Method: " & varWizardData.Method & " | Year: " & varWizardData.Year & " | Cycle: " & varWizardData.Cycle,
            X: 15, Y: 110, Width: Parent.Width - 30, Height: 15,
            Color: varTheme.TextSecondary,
            Font: Font.'Segoe UI',
            Size: 10
          ),
          
          // Publishing guardrails validation
          With(
            {
              publishValidation: {
                HasSite: !IsBlank(varWizardData.Site),
                HasFeature: !IsBlank(varWizardData.Feature),
                HasAttributes: CountRows(varWizardData.Attributes) > 0,
                HasWebMapID: !IsBlank(varWizardData.WebMapID) And varValidateWebMapID(varWizardData.WebMapID).IsValid,
                HasReviewer: !IsBlank(varWizardData.Reviewer)
              }
            },
            Container(
              X: 15, Y: 135, Width: Parent.Width - 30, Height: 50,
              
              Label(
                Text: "Publishing Requirements:",
                X: 0, Y: 0, Width: 200, Height: 15,
                Color: varTheme.Text,
                Font: Font.'Segoe UI',
                Size: 10,
                FontWeight: FontWeight.Semibold
              ),
              
              Label(
                Text: Concatenate(
                  If(!publishValidation.HasSite, "❌ Site required; ", "✅ Site selected; "),
                  If(!publishValidation.HasFeature, "❌ Feature required; ", "✅ Feature selected; "),
                  If(!publishValidation.HasAttributes, "❌ ≥1 attribute required; ", "✅ Attributes selected; "),
                  If(!publishValidation.HasWebMapID, "❌ Valid WebMap ID required; ", "✅ WebMap ID valid; "),
                  If(!publishValidation.HasReviewer, "❌ Reviewer required", "✅ Reviewer assigned")
                ),
                X: 0, Y: 20, Width: Parent.Width - 30, Height: 25,
                Color: varTheme.TextSecondary,
                Font: Font.'Segoe UI',
                Size: 9,
                Wrap: true,
                AccessibleLabel: "Publishing requirements checklist: " & Self.Text
              )
            )
          )
        )
      )
    )
  ),
  
  // Publish Confirmation Dialog
  If(varShowPublishConfirmation,
    Container(
      X: 0, Y: 0, Width: Parent.Width, Height: Parent.Height,
      Fill: RGBA(0, 0, 0, 0.5),
      
      Container(
        X: (Parent.Width - 500) / 2, Y: (Parent.Height - 300) / 2, Width: 500, Height: 300,
        
        Rectangle(
          Fill: varTheme.Background,
          BorderColor: varTheme.Border,
          BorderThickness: 2,
          RadiusTopLeft: 12, RadiusTopRight: 12, RadiusBottomLeft: 12, RadiusBottomRight: 12,
          
          Label(
            Text: "Confirm Assessment Publication",
            X: 20, Y: 20, Width: 460, Height: 30,
            Color: varTheme.Text,
            Font: Font.'Segoe UI',
            Size: 16,
            FontWeight: FontWeight.Semibold,
            AccessibleLabel: "Confirm assessment publication dialog"
          ),
          
          Label(
            Text: "You are about to publish this assessment for field collection:",
            X: 20, Y: 60, Width: 460, Height: 20,
            Color: varTheme.TextSecondary,
            Font: Font.'Segoe UI',
            Size: 11
          ),
          
          Label(
            Text: "• Site: " & varWizardData.Site.SiteName & Char(10) &
                  "• Feature: " & varWizardData.Feature.FeatureName & Char(10) &
                  "• Attributes: " & CountRows(varWizardData.Attributes) & " selected" & Char(10) &
                  "• Reviewer: " & varWizardData.Reviewer.Name & Char(10) &
                  "• WebMap: " & varWizardData.WebMapID,
            X: 20, Y: 90, Width: 460, Height: 100,
            Color: varTheme.Text,
            Font: Font.'Segoe UI',
            Size: 11,
            Wrap: true
          ),
          
          Label(
            Text: "Once published, the assessment will be available for field data collection and cannot be easily modified.",
            X: 20, Y: 200, Width: 460, Height: 30,
            Color: varTheme.Warning,
            Font: Font.'Segoe UI',
            Size: 10,
            Wrap: true
          ),
          
          Button(
            Text: "Cancel",
            X: 280, Y: 240, Width: 100, Height: 40,
            Fill: varTheme.Surface,
            Color: varTheme.Text,
            BorderColor: varTheme.Border,
            BorderThickness: 1,
            Font: Font.'Segoe UI',
            Size: 12,
            RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
            OnSelect: Set(varShowPublishConfirmation, false),
            AccessibleLabel: "Cancel publication"
          ),
          
          Button(
            Text: "🚀 Publish",
            X: 390, Y: 240, Width: 100, Height: 40,
            Fill: varTheme.Success,
            Color: Color.White,
            Font: Font.'Segoe UI',
            Size: 12,
            FontWeight: FontWeight.Semibold,
            RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
            OnSelect: 
              // Create assessment record
              With(
                {newAssessmentID: GUID()},
                Collect(colAssessments, {
                  AssessmentID: newAssessmentID,
                  SiteID: varWizardData.Site.SiteID,
                  SiteName: varWizardData.Site.SiteName,
                  FeatureID: varWizardData.Feature.FeatureID,
                  FeatureName: varWizardData.Feature.FeatureName,
                  Method: varWizardData.Method,
                  Year: varWizardData.Year,
                  Cycle: varWizardData.Cycle,
                  Status: "InField",
                  ReviewerID: varWizardData.Reviewer.UserID,
                  ReviewerName: varWizardData.Reviewer.Name,
                  WebMapID: varWizardData.WebMapID,
                  CreatedBy: varCurrentUser.UserID,
                  CreatedDate: Now(),
                  ModifiedBy: varCurrentUser.UserID,
                  ModifiedDate: Now()
                });
                
                // Create audit record
                Collect(colAudit, {
                  AuditID: GUID(),
                  AssessmentID: newAssessmentID,
                  Action: "Publish",
                  UserID: varCurrentUser.UserID,
                  UserName: varCurrentUser.Name,
                  Timestamp: Now(),
                  Details: "Assessment published for field collection",
                  Reason: "Initial publication via wizard"
                });
                
                // Log event
                Collect(colEventLog, {
                  EventID: GUID(),
                  EventType: "Publish",
                  Timestamp: Now(),
                  UserID: varCurrentUser.UserID,
                  UserName: varCurrentUser.Name,
                  CorrelationID: varGenerateCorrelationID(),
                  Details: "Assessment " & newAssessmentID & " published for " & varWizardData.Site.SiteName & " - " & varWizardData.Feature.FeatureName,
                  Screen: "AssessmentWizard"
                });
                
                // Reset wizard state
                Set(varWizardInitialized, false);
                Set(varShowPublishConfirmation, false);
                
                // Show success message and navigate
                Notify("✅ Assessment published successfully! " & varWizardData.Site.SiteName & " – " & varWizardData.Feature.FeatureName & " is now available for field collection.", NotificationType.Success, 4000);
                Navigate(FieldStatusScreen)
              ),
            AccessibleLabel: "Confirm and publish assessment"
          )
        )
      )
    )
  ),
  
  // Enhanced Navigation Buttons with Step Validation
  Container(
    X: 20, Y: Parent.Height - 80, Width: Parent.Width - 40, Height: 60,
    
    If(varWizardStep > 1,
      Button(
        Text: "← Previous",
        X: 0, Y: 15, Width: 100, Height: 40,
        Fill: varTheme.Surface,
        Color: varTheme.Text,
        BorderColor: varTheme.Border,
        BorderThickness: 1,
        Font: Font.'Segoe UI',
        Size: 12,
        RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
        OnSelect: 
          Set(varWizardStep, varWizardStep - 1);
          Set(varFocusedControl, ""),
        AccessibleLabel: "Go to previous step"
      )
    ),
    
    If(varWizardStep < 4,
      Button(
        Text: "Next →",
        X: Parent.Width - 100, Y: 15, Width: 100, Height: 40,
        Fill: varTheme.Primary,
        Color: Color.White,
        Font: Font.'Segoe UI',
        Size: 12,
        RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
        OnSelect: 
          // Enhanced step validation before proceeding
          Set(varStepValid, true);
          Set(varWizardErrors, []);
          
          Switch(varWizardStep,
            1, // Step 1 validation
              If(IsBlank(varWizardData.Site),
                Set(varWizardErrors, Collect(varWizardErrors, {Step: 1, Field: "Site", Message: "Site selection is required"}));
                Set(varFocusedControl, "Site");
                Set(varStepValid, false)
              );
              If(IsBlank(varWizardData.Feature),
                Set(varWizardErrors, Collect(varWizardErrors, {Step: 1, Field: "Feature", Message: "Feature selection is required"}));
                If(varFocusedControl = "", Set(varFocusedControl, "Feature"));
                Set(varStepValid, false)
              ),
            2, // Step 2 validation
              If(CountRows(varWizardData.Attributes) = 0,
                Set(varWizardErrors, Collect(varWizardErrors, {Step: 2, Field: "Attributes", Message: "At least one monitoring attribute must be selected"}));
                Set(varFocusedControl, "Attributes");
                Set(varStepValid, false)
              ),
            3, // Step 3 validation
              If(IsBlank(varWizardData.WebMapID),
                Set(varWizardErrors, Collect(varWizardErrors, {Step: 3, Field: "WebMapID", Message: "WebMap ID is required"}));
                Set(varFocusedControl, "WebMapID");
                Set(varStepValid, false)
              );
              If(!IsBlank(varWizardData.WebMapID) And !varValidateWebMapID(varWizardData.WebMapID).IsValid,
                Set(varWizardErrors, Collect(varWizardErrors, {Step: 3, Field: "WebMapID", Message: "WebMap ID format is invalid or WebMap is not available"}));
                If(varFocusedControl = "", Set(varFocusedControl, "WebMapID"));
                Set(varStepValid, false)
              )
          );
          
          If(varStepValid,
            Set(varWizardStep, varWizardStep + 1);
            Set(varFocusedControl, "")
          ),
        AccessibleLabel: "Go to next step"
      )
    )
  )
);