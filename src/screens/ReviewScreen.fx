// Natural England Condition Assessment Demo - Review & QA Screen
// Enhanced filterable work queue with delegable query patterns and comprehensive filtering

Screen(
  Fill: varTheme.Background,
  OnVisible: 
    // Initialize review screen variables
    Set(varReviewFilters, {
      Region: "All Regions",
      Site: "All Sites", 
      Feature: "All Features",
      Status: "Submitted",
      DateFrom: DateAdd(Today(), -30, Days),
      DateTo: Today()
    });
    Set(varSelectedAssessment, Blank());
    Set(varWorkQueueSortBy, "ModifiedDate");
    Set(varWorkQueueSortOrder, "Descending");
    Set(varShowBulkActions, false);
    Set(varSelectedAssessments, []);
    Set(varWorkQueuePage, 1);
    Set(varWorkQueuePageSize, 20);
    Set(varReviewTab, "Attributes");
    Set(varPhotoIndex, 1);
    Set(varSelectedAttribute, Blank());
    Set(varSelectedAttributeDetail, Blank());
    Set(varShowApprovalDialog, false);
    Set(varShowRejectionDialog, false);
    Set(varRejectionReason, "");
    Set(varRejectionCategory, "");
    
    // Log screen access
    Collect(colEventLog, {
      EventID: GUID(),
      EventType: "Screen Access",
      Timestamp: Now(),
      UserID: varCurrentUser.UserID,
      UserName: varCurrentUser.Name,
      CorrelationID: varGenerateCorrelationID(),
      Details: "Review & QA screen accessed",
      Screen: "ReviewScreen"
    }),
  
  // Header Banner
  Rectangle(
    X: 0, Y: 0, Width: Parent.Width, Height: 80,
    Fill: varTheme.Primary,
    
    Label(
      Text: "🧾 Review & QA - Assessment Work Queue",
      X: 20, Y: 20, Width: Parent.Width - 200, Height: 40,
      Color: Color.White,
      Font: Font.'Segoe UI',
      Size: 18,
      FontWeight: FontWeight.Semibold,
      AccessibleLabel: "Review and Quality Assurance screen for assessment work queue"
    ),
    
    // Bulk Actions Toggle
    Button(
      Text: If(varShowBulkActions, "Single Mode", "Bulk Mode"),
      X: Parent.Width - 180, Y: 25, Width: 80, Height: 30,
      Fill: If(varShowBulkActions, varTheme.Warning, Color.Transparent),
      Color: Color.White,
      BorderColor: Color.White,
      BorderThickness: 1,
      Font: Font.'Segoe UI',
      Size: 10,
      RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4,
      OnSelect: 
        Set(varShowBulkActions, !varShowBulkActions);
        Set(varSelectedAssessments, []);
        Set(varSelectedAssessment, Blank()),
      AccessibleLabel: If(varShowBulkActions, "Switch to single assessment mode", "Switch to bulk assessment mode")
    ),
    
    Button(
      Text: "← Back to Home",
      X: Parent.Width - 90, Y: 25, Width: 80, Height: 30,
      Fill: Color.Transparent,
      Color: Color.White,
      BorderColor: Color.White,
      BorderThickness: 1,
      Font: Font.'Segoe UI',
      Size: 11,
      RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4,
      OnSelect: Navigate(HomeScreen),
      AccessibleLabel: "Return to home screen"
    )
  ),
  
  // Enhanced Filter Panel (Left)
  Container(
    X: 20, Y: 100, Width: 320, Height: Parent.Height - 120,
    
    // Filter Header with Clear/Reset
    Container(
      X: 0, Y: 0, Width: Parent.Width, Height: 40,
      
      Label(
        Text: "Filter Work Queue",
        X: 0, Y: 5, Width: 200, Height: 30,
        Color: varTheme.Text,
        Font: Font.'Segoe UI',
        Size: 16,
        FontWeight: FontWeight.Semibold,
        AccessibleLabel: "Filter controls for assessment work queue"
      ),
      
      Button(
        Text: "Clear All",
        X: Parent.Width - 80, Y: 5, Width: 70, Height: 25,
        Fill: Color.Transparent,
        Color: varTheme.Primary,
        BorderColor: varTheme.Primary,
        BorderThickness: 1,
        Font: Font.'Segoe UI',
        Size: 10,
        RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4,
        OnSelect: 
          Set(varReviewFilters, {
            Region: "All Regions",
            Site: "All Sites",
            Feature: "All Features", 
            Status: "All Status",
            DateFrom: DateAdd(Today(), -30, Days),
            DateTo: Today()
          });
          Set(varSelectedAssessment, Blank()),
        AccessibleLabel: "Clear all filters and reset to default values"
      )
    ),
    
    // Region Filter
    Label(
      Text: "Region:",
      X: 0, Y: 50, Width: 80, Height: 25,
      Color: varTheme.Text,
      Font: Font.'Segoe UI',
      Size: 12,
      AccessibleLabel: "Filter by region"
    ),
    
    Dropdown(
      Items: Distinct(
        AddColumns(
          Table({Region: "All Regions"}),
          "SortOrder", 0
        ),
        AddColumns(
          colSites,
          "SortOrder", 1
        )
      ).Region,
      Default: varReviewFilters.Region,
      X: 90, Y: 50, Width: 220, Height: 30,
      Font: Font.'Segoe UI',
      Size: 11,
      OnChange: 
        Set(varReviewFilters, 
          Patch(varReviewFilters, {Region: Self.Selected.Value}));
        Set(varSelectedAssessment, Blank()),
      AccessibleLabel: "Select region to filter assessments"
    ),
    
    // Site Filter (filtered by Region)
    Label(
      Text: "Site:",
      X: 0, Y: 90, Width: 80, Height: 25,
      Color: varTheme.Text,
      Font: Font.'Segoe UI',
      Size: 12,
      AccessibleLabel: "Filter by site"
    ),
    
    Dropdown(
      Items: Distinct(
        AddColumns(
          Table({SiteName: "All Sites"}),
          "SortOrder", 0
        ),
        AddColumns(
          If(varReviewFilters.Region = "All Regions",
            colSites,
            Filter(colSites, Region = varReviewFilters.Region)
          ),
          "SortOrder", 1
        )
      ).SiteName,
      Default: varReviewFilters.Site,
      X: 90, Y: 90, Width: 220, Height: 30,
      Font: Font.'Segoe UI',
      Size: 11,
      OnChange: 
        Set(varReviewFilters, 
          Patch(varReviewFilters, {Site: Self.Selected.Value}));
        Set(varSelectedAssessment, Blank()),
      AccessibleLabel: "Select site to filter assessments"
    ),
    
    // Feature Filter
    Label(
      Text: "Feature:",
      X: 0, Y: 130, Width: 80, Height: 25,
      Color: varTheme.Text,
      Font: Font.'Segoe UI',
      Size: 12,
      AccessibleLabel: "Filter by habitat feature"
    ),
    
    Dropdown(
      Items: Distinct(
        AddColumns(
          Table({FeatureName: "All Features"}),
          "SortOrder", 0
        ),
        AddColumns(
          colFeatures,
          "SortOrder", 1
        )
      ).FeatureName,
      Default: varReviewFilters.Feature,
      X: 90, Y: 130, Width: 220, Height: 30,
      Font: Font.'Segoe UI',
      Size: 11,
      OnChange: 
        Set(varReviewFilters, 
          Patch(varReviewFilters, {Feature: Self.Selected.Value}));
        Set(varSelectedAssessment, Blank()),
      AccessibleLabel: "Select habitat feature to filter assessments"
    ),
    
    // Status Filter
    Label(
      Text: "Status:",
      X: 0, Y: 170, Width: 80, Height: 25,
      Color: varTheme.Text,
      Font: Font.'Segoe UI',
      Size: 12,
      AccessibleLabel: "Filter by assessment status"
    ),
    
    Dropdown(
      Items: ["All Status", "Submitted", "UnderReview", "InField", "Approved", "Rejected"],
      Default: varReviewFilters.Status,
      X: 90, Y: 170, Width: 220, Height: 30,
      Font: Font.'Segoe UI',
      Size: 11,
      OnChange: 
        Set(varReviewFilters, 
          Patch(varReviewFilters, {Status: Self.Selected.Value}));
        Set(varSelectedAssessment, Blank()),
      AccessibleLabel: "Select assessment status to filter work queue"
    ),
    
    // Date Range Filter
    Label(
      Text: "Date Range:",
      X: 0, Y: 210, Width: 80, Height: 25,
      Color: varTheme.Text,
      Font: Font.'Segoe UI',
      Size: 12,
      AccessibleLabel: "Filter by date range"
    ),
    
    DatePicker(
      DefaultDate: varReviewFilters.DateFrom,
      X: 90, Y: 210, Width: 105, Height: 30,
      Font: Font.'Segoe UI',
      Size: 10,
      OnChange: 
        Set(varReviewFilters, 
          Patch(varReviewFilters, {DateFrom: Self.SelectedDate}));
        Set(varSelectedAssessment, Blank()),
      AccessibleLabel: "Select start date for filtering assessments"
    ),
    
    DatePicker(
      DefaultDate: varReviewFilters.DateTo,
      X: 205, Y: 210, Width: 105, Height: 30,
      Font: Font.'Segoe UI',
      Size: 10,
      OnChange: 
        Set(varReviewFilters, 
          Patch(varReviewFilters, {DateTo: Self.SelectedDate}));
        Set(varSelectedAssessment, Blank()),
      AccessibleLabel: "Select end date for filtering assessments"
    ),
    
    // Sort Controls
    Label(
      Text: "Sort By:",
      X: 0, Y: 250, Width: 80, Height: 25,
      Color: varTheme.Text,
      Font: Font.'Segoe UI',
      Size: 12,
      AccessibleLabel: "Sort work queue"
    ),
    
    Dropdown(
      Items: ["ModifiedDate", "CreatedDate", "SiteName", "Status"],
      Default: varWorkQueueSortBy,
      X: 90, Y: 250, Width: 105, Height: 30,
      Font: Font.'Segoe UI',
      Size: 10,
      OnChange: Set(varWorkQueueSortBy, Self.Selected.Value),
      AccessibleLabel: "Select field to sort assessments by"
    ),
    
    Dropdown(
      Items: ["Descending", "Ascending"],
      Default: varWorkQueueSortOrder,
      X: 205, Y: 250, Width: 105, Height: 30,
      Font: Font.'Segoe UI',
      Size: 10,
      OnChange: Set(varWorkQueueSortOrder, Self.Selected.Value),
      AccessibleLabel: "Select sort order for assessments"
    ),
    
    // Work Queue Summary
    Container(
      X: 0, Y: 300, Width: Parent.Width, Height: 80,
      Fill: varTheme.Surface,
      BorderColor: varTheme.Border,
      BorderThickness: 1,
      RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
      
      Label(
        Text: "Work Queue Summary",
        X: 10, Y: 5, Width: Parent.Width - 20, Height: 20,
        Color: varTheme.Text,
        Font: Font.'Segoe UI',
        Size: 12,
        FontWeight: FontWeight.Semibold,
        AccessibleLabel: "Summary of filtered work queue"
      ),
      
      Label(
        Text: "Total: " & CountRows(
          With({
            filteredAssessments: 
              Filter(colAssessments,
                (varReviewFilters.Region = "All Regions" Or 
                 LookUp(colSites, SiteID = AssessmentID, Region) = varReviewFilters.Region) And
                (varReviewFilters.Site = "All Sites" Or SiteName = varReviewFilters.Site) And
                (varReviewFilters.Feature = "All Features" Or FeatureName = varReviewFilters.Feature) And
                (varReviewFilters.Status = "All Status" Or Status = varReviewFilters.Status) And
                ModifiedDate >= varReviewFilters.DateFrom And
                ModifiedDate <= varReviewFilters.DateTo
              )
          }, filteredAssessments)
        ) & " assessments",
        X: 10, Y: 25, Width: Parent.Width - 20, Height: 15,
        Color: varTheme.TextSecondary,
        Font: Font.'Segoe UI',
        Size: 10,
        AccessibleLabel: "Total number of assessments matching current filters"
      ),
      
      Label(
        Text: "Submitted: " & CountRows(
          Filter(colAssessments, Status = "Submitted")
        ) & " | Under Review: " & CountRows(
          Filter(colAssessments, Status = "UnderReview")
        ),
        X: 10, Y: 45, Width: Parent.Width - 20, Height: 15,
        Color: varTheme.TextSecondary,
        Font: Font.'Segoe UI',
        Size: 10,
        AccessibleLabel: "Count of submitted and under review assessments"
      )
    ),
    
    // Virtualized Assessment List with Pagination
    Label(
      Text: "Assessment Work Queue",
      X: 0, Y: 390, Width: Parent.Width, Height: 25,
      Color: varTheme.Text,
      Font: Font.'Segoe UI',
      Size: 14,
      FontWeight: FontWeight.Semibold,
      AccessibleLabel: "List of assessments in work queue"
    ),
    
    Gallery(
      Items: 
        With({
          filteredAssessments: 
            Filter(colAssessments,
              (varReviewFilters.Region = "All Regions" Or 
               LookUp(colSites, SiteID = ThisItem.SiteID, Region) = varReviewFilters.Region) And
              (varReviewFilters.Site = "All Sites" Or SiteName = varReviewFilters.Site) And
              (varReviewFilters.Feature = "All Features" Or FeatureName = varReviewFilters.Feature) And
              (varReviewFilters.Status = "All Status" Or Status = varReviewFilters.Status) And
              ModifiedDate >= varReviewFilters.DateFrom And
              ModifiedDate <= varReviewFilters.DateTo
            ),
          sortedAssessments:
            Switch(varWorkQueueSortBy,
              "ModifiedDate", 
                If(varWorkQueueSortOrder = "Descending",
                  Sort(filteredAssessments, ModifiedDate, Descending),
                  Sort(filteredAssessments, ModifiedDate, Ascending)
                ),
              "CreatedDate",
                If(varWorkQueueSortOrder = "Descending", 
                  Sort(filteredAssessments, CreatedDate, Descending),
                  Sort(filteredAssessments, CreatedDate, Ascending)
                ),
              "SiteName",
                If(varWorkQueueSortOrder = "Descending",
                  Sort(filteredAssessments, SiteName, Descending),
                  Sort(filteredAssessments, SiteName, Ascending)
                ),
              "Status",
                If(varWorkQueueSortOrder = "Descending",
                  Sort(filteredAssessments, Status, Descending),
                  Sort(filteredAssessments, Status, Ascending)
                ),
              filteredAssessments
            )
        }, 
        FirstN(
          LastN(sortedAssessments, CountRows(sortedAssessments) - (varWorkQueuePage - 1) * varWorkQueuePageSize),
          varWorkQueuePageSize
        )),
      X: 0, Y: 420, Width: Parent.Width, Height: Parent.Height - 470,
      Layout: Layout.Vertical,
      TemplateSize: 90,
      LoadingSpinner: LoadingSpinner.Data,
      AccessibleLabel: "Paginated list of assessments for review",
      
      Container(
        Fill: If(
          varShowBulkActions,
          If(ThisItem.AssessmentID in varSelectedAssessments, varTheme.Surface, Color.White),
          If(ThisItem.AssessmentID = varSelectedAssessment.AssessmentID, varTheme.Surface, Color.White)
        ),
        BorderColor: If(
          varShowBulkActions,
          If(ThisItem.AssessmentID in varSelectedAssessments, varTheme.Primary, varTheme.Border),
          If(ThisItem.AssessmentID = varSelectedAssessment.AssessmentID, varTheme.Primary, varTheme.Border)
        ),
        BorderThickness: If(
          varShowBulkActions,
          If(ThisItem.AssessmentID in varSelectedAssessments, 2, 1),
          If(ThisItem.AssessmentID = varSelectedAssessment.AssessmentID, 2, 1)
        ),
        RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
        OnSelect: 
          If(varShowBulkActions,
            If(ThisItem.AssessmentID in varSelectedAssessments,
              Set(varSelectedAssessments, 
                Filter(varSelectedAssessments, Value <> ThisItem.AssessmentID)),
              Set(varSelectedAssessments, 
                Distinct(varSelectedAssessments, ThisItem.AssessmentID))
            ),
            Set(varSelectedAssessment, ThisItem)
          ),
        AccessibleLabel: "Assessment for " & ThisItem.SiteName & " " & ThisItem.FeatureName & " with status " & ThisItem.Status,
        
        // Bulk Selection Checkbox
        If(varShowBulkActions,
          Checkbox(
            Default: ThisItem.AssessmentID in varSelectedAssessments,
            X: 10, Y: 10, Width: 20, Height: 20,
            OnCheck: 
              Set(varSelectedAssessments, 
                Distinct(varSelectedAssessments, ThisItem.AssessmentID)),
            OnUncheck:
              Set(varSelectedAssessments, 
                Filter(varSelectedAssessments, Value <> ThisItem.AssessmentID)),
            AccessibleLabel: "Select assessment for bulk action"
          )
        ),
        
        // Status Indicator
        Rectangle(
          X: If(varShowBulkActions, 40, 10), Y: 10, Width: 8, Height: Parent.TemplateHeight - 20,
          Fill: Switch(ThisItem.Status,
            "Submitted", varTheme.Warning,
            "UnderReview", varTheme.Info,
            "InField", varTheme.Secondary,
            "Approved", varTheme.Success,
            "Rejected", varTheme.Error,
            varTheme.TextSecondary
          ),
          RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4
        ),
        
        // Assessment Details
        Label(
          Text: ThisItem.SiteName,
          X: If(varShowBulkActions, 55, 25), Y: 10, Width: Parent.TemplateWidth - If(varShowBulkActions, 75, 45), Height: 20,
          Color: varTheme.Text,
          Font: Font.'Segoe UI',
          Size: 12,
          FontWeight: FontWeight.Semibold,
          Overflow: Overflow.Ellipsis
        ),
        
        Label(
          Text: ThisItem.FeatureName,
          X: If(varShowBulkActions, 55, 25), Y: 30, Width: Parent.TemplateWidth - If(varShowBulkActions, 75, 45), Height: 15,
          Color: varTheme.TextSecondary,
          Font: Font.'Segoe UI',
          Size: 10,
          Overflow: Overflow.Ellipsis
        ),
        
        Label(
          Text: "Modified: " & Text(ThisItem.ModifiedDate, "dd/mm/yyyy hh:mm") & " | " & ThisItem.Status,
          X: If(varShowBulkActions, 55, 25), Y: 50, Width: Parent.TemplateWidth - If(varShowBulkActions, 75, 45), Height: 15,
          Color: varTheme.TextLight,
          Font: Font.'Segoe UI',
          Size: 9,
          Overflow: Overflow.Ellipsis
        ),
        
        Label(
          Text: "Reviewer: " & ThisItem.ReviewerName,
          X: If(varShowBulkActions, 55, 25), Y: 65, Width: Parent.TemplateWidth - If(varShowBulkActions, 75, 45), Height: 15,
          Color: varTheme.TextLight,
          Font: Font.'Segoe UI',
          Size: 9,
          Overflow: Overflow.Ellipsis
        )
      )
    ),
    
    // Pagination Controls
    Container(
      X: 0, Y: Parent.Height - 40, Width: Parent.Width, Height: 35,
      
      Button(
        Text: "◀ Prev",
        X: 0, Y: 5, Width: 60, Height: 25,
        Fill: If(varWorkQueuePage > 1, varTheme.Primary, varTheme.Surface),
        Color: If(varWorkQueuePage > 1, Color.White, varTheme.TextLight),
        BorderColor: varTheme.Border,
        BorderThickness: 1,
        Font: Font.'Segoe UI',
        Size: 10,
        RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4,
        DisplayMode: If(varWorkQueuePage > 1, DisplayMode.Edit, DisplayMode.Disabled),
        OnSelect: Set(varWorkQueuePage, varWorkQueuePage - 1),
        AccessibleLabel: "Go to previous page of assessments"
      ),
      
      Label(
        Text: "Page " & varWorkQueuePage,
        X: 70, Y: 5, Width: 80, Height: 25,
        Color: varTheme.Text,
        Font: Font.'Segoe UI',
        Size: 10,
        Align: Align.Center,
        AccessibleLabel: "Current page number"
      ),
      
      Button(
        Text: "Next ▶",
        X: 160, Y: 5, Width: 60, Height: 25,
        Fill: varTheme.Primary,
        Color: Color.White,
        BorderColor: varTheme.Border,
        BorderThickness: 1,
        Font: Font.'Segoe UI',
        Size: 10,
        RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4,
        OnSelect: Set(varWorkQueuePage, varWorkQueuePage + 1),
        AccessibleLabel: "Go to next page of assessments"
      )
    )
  ),  // Re
view Panel (Right) - Enhanced with empty state handling
  Container(
    X: 360, Y: 100, Width: Parent.Width - 380, Height: Parent.Height - 120,
    
    // Empty State Handling
    If(CountRows(
      Filter(colAssessments,
        (varReviewFilters.Region = "All Regions" Or 
         LookUp(colSites, SiteID = ThisItem.SiteID, Region) = varReviewFilters.Region) And
        (varReviewFilters.Site = "All Sites" Or SiteName = varReviewFilters.Site) And
        (varReviewFilters.Feature = "All Features" Or FeatureName = varReviewFilters.Feature) And
        (varReviewFilters.Status = "All Status" Or Status = varReviewFilters.Status) And
        ModifiedDate >= varReviewFilters.DateFrom And
        ModifiedDate <= varReviewFilters.DateTo
      )
    ) = 0,
      // No assessments match filters
      Container(
        X: 0, Y: Parent.Height / 2 - 100, Width: Parent.Width, Height: 200,
        
        Icon(
          Icon: Icon.Search,
          X: Parent.Width / 2 - 25, Y: 20, Width: 50, Height: 50,
          Color: varTheme.TextLight
        ),
        
        Label(
          Text: "No assessments found",
          X: 0, Y: 80, Width: Parent.Width, Height: 30,
          Color: varTheme.Text,
          Font: Font.'Segoe UI',
          Size: 16,
          FontWeight: FontWeight.Semibold,
          Align: Align.Center,
          AccessibleLabel: "No assessments match the current filter criteria"
        ),
        
        Label(
          Text: "Try adjusting your filters or check back later for new submissions.",
          X: 20, Y: 115, Width: Parent.Width - 40, Height: 40,
          Color: varTheme.TextSecondary,
          Font: Font.'Segoe UI',
          Size: 12,
          Align: Align.Center,
          AccessibleLabel: "Suggestion to adjust filters or check back later"
        ),
        
        Button(
          Text: "Reset Filters",
          X: Parent.Width / 2 - 60, Y: 160, Width: 120, Height: 35,
          Fill: varTheme.Primary,
          Color: Color.White,
          Font: Font.'Segoe UI',
          Size: 12,
          RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
          OnSelect: 
            Set(varReviewFilters, {
              Region: "All Regions",
              Site: "All Sites",
              Feature: "All Features",
              Status: "Submitted",
              DateFrom: DateAdd(Today(), -30, Days),
              DateTo: Today()
            });
            Set(varSelectedAssessment, Blank()),
          AccessibleLabel: "Reset all filters to show available assessments"
        )
      ),
      
      // Assessment selected or bulk mode
      If(varShowBulkActions,
        // Bulk Actions Panel
        Container(
          // Bulk Actions Header
          Label(
            Text: "Bulk Actions (" & CountRows(varSelectedAssessments) & " selected)",
            X: 0, Y: 0, Width: Parent.Width, Height: 30,
            Color: varTheme.Text,
            Font: Font.'Segoe UI',
            Size: 16,
            FontWeight: FontWeight.Semibold,
            AccessibleLabel: CountRows(varSelectedAssessments) & " assessments selected for bulk action"
          ),
          
          If(CountRows(varSelectedAssessments) = 0,
            Label(
              Text: "Select assessments from the work queue to perform bulk actions.",
              X: 0, Y: 40, Width: Parent.Width, Height: 40,
              Color: varTheme.TextSecondary,
              Font: Font.'Segoe UI',
              Size: 12,
              Align: Align.Center,
              AccessibleLabel: "Instructions to select assessments for bulk actions"
            ),
            
            // Bulk Action Buttons
            Container(
              X: 0, Y: 40, Width: Parent.Width, Height: 60,
              
              Button(
                Text: "✅ Bulk Approve (" & CountRows(varSelectedAssessments) & ")",
                X: 0, Y: 10, Width: 150, Height: 40,
                Fill: varTheme.Success,
                Color: Color.White,
                Font: Font.'Segoe UI',
                Size: 12,
                FontWeight: FontWeight.Semibold,
                RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
                DisplayMode: If(varCanReviewAssessment(varCurrentUser.Role) And CountRows(varSelectedAssessments) > 0, DisplayMode.Edit, DisplayMode.Disabled),
                OnSelect: 
                  With({bulkCount: CountRows(varSelectedAssessments)},
                    ForAll(varSelectedAssessments,
                      UpdateIf(colAssessments, AssessmentID = Value, {Status: "UnderReview", ModifiedBy: varCurrentUser.UserID, ModifiedDate: Now()});
                      Collect(colAudit, {
                        AuditID: GUID(),
                        AssessmentID: Value,
                        Action: "Bulk Approve",
                        UserID: varCurrentUser.UserID,
                        UserName: varCurrentUser.Name,
                        Timestamp: Now(),
                        Details: "Assessment approved via bulk action (" & bulkCount & " assessments processed)",
                        Reason: "Bulk approval - quality review passed for batch processing"
                      })
                    );
                    
                    // Log bulk event
                    Collect(colEventLog, {
                      EventID: GUID(),
                      EventType: "Bulk Approve",
                      Timestamp: Now(),
                      UserID: varCurrentUser.UserID,
                      UserName: varCurrentUser.Name,
                      CorrelationID: varGenerateCorrelationID(),
                      Details: "Bulk approved " & bulkCount & " assessments by " & varCurrentUser.Name,
                      Screen: "ReviewScreen"
                    });
                    
                    Notify("✅ Bulk approved " & bulkCount & " assessments", NotificationType.Success, 4000);
                    Set(varSelectedAssessments, []);
                    Set(varShowBulkActions, false)
                  ),
                AccessibleLabel: "Approve all selected assessments in bulk"
              ),
              
              Button(
                Text: "❌ Bulk Reject (" & CountRows(varSelectedAssessments) & ")",
                X: 160, Y: 10, Width: 150, Height: 40,
                Fill: varTheme.Error,
                Color: Color.White,
                Font: Font.'Segoe UI',
                Size: 12,
                FontWeight: FontWeight.Semibold,
                RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
                DisplayMode: If(varCanReviewAssessment(varCurrentUser.Role) And CountRows(varSelectedAssessments) > 0, DisplayMode.Edit, DisplayMode.Disabled),
                OnSelect: 
                  With({bulkCount: CountRows(varSelectedAssessments)},
                    ForAll(varSelectedAssessments,
                      UpdateIf(colAssessments, AssessmentID = Value, {Status: "Rejected", ModifiedBy: varCurrentUser.UserID, ModifiedDate: Now()});
                      Collect(colAudit, {
                        AuditID: GUID(),
                        AssessmentID: Value,
                        Action: "Bulk Reject",
                        UserID: varCurrentUser.UserID,
                        UserName: varCurrentUser.Name,
                        Timestamp: Now(),
                        Details: "Assessment rejected via bulk action (" & bulkCount & " assessments processed)",
                        Reason: "Bulk rejection - assessments require individual review and rework"
                      })
                    );
                    
                    // Log bulk event
                    Collect(colEventLog, {
                      EventID: GUID(),
                      EventType: "Bulk Reject",
                      Timestamp: Now(),
                      UserID: varCurrentUser.UserID,
                      UserName: varCurrentUser.Name,
                      CorrelationID: varGenerateCorrelationID(),
                      Details: "Bulk rejected " & bulkCount & " assessments by " & varCurrentUser.Name,
                      Screen: "ReviewScreen"
                    });
                    
                    Notify("❌ Bulk rejected " & bulkCount & " assessments", NotificationType.Warning, 4000);
                    Set(varSelectedAssessments, []);
                    Set(varShowBulkActions, false)
                  ),
                AccessibleLabel: "Reject all selected assessments in bulk"
              )
            )
          )
        ),
        
        // Single Assessment Review Panel
        If(IsBlank(varSelectedAssessment),
          Container(
            X: 0, Y: Parent.Height / 2 - 60, Width: Parent.Width, Height: 120,
            
            Icon(
              Icon: Icon.CheckboxComposite,
              X: Parent.Width / 2 - 25, Y: 10, Width: 50, Height: 50,
              Color: varTheme.TextLight
            ),
            
            Label(
              Text: "Select an assessment to review",
              X: 0, Y: 70, Width: Parent.Width, Height: 25,
              Color: varTheme.Text,
              Font: Font.'Segoe UI',
              Size: 14,
              FontWeight: FontWeight.Semibold,
              Align: Align.Center,
              AccessibleLabel: "Instructions to select an assessment from the work queue"
            ),
            
            Label(
              Text: "Choose an assessment from the work queue to view details and perform review actions.",
              X: 20, Y: 95, Width: Parent.Width - 40, Height: 20,
              Color: varTheme.TextSecondary,
              Font: Font.'Segoe UI',
              Size: 11,
              Align: Align.Center,
              AccessibleLabel: "Additional instructions for assessment selection"
            )
          ),
          
          // Assessment Review Content - Placeholder for subtask 5.2
          Container(
            // Assessment Header
            Label(
              Text: "Assessment Review: " & varSelectedAssessment.SiteName,
              X: 0, Y: 0, Width: Parent.Width, Height: 30,
              Color: varTheme.Text,
              Font: Font.'Segoe UI',
              Size: 16,
              FontWeight: FontWeight.Semibold,
              AccessibleLabel: "Assessment review for " & varSelectedAssessment.SiteName
            ),
            
            Label(
              Text: varSelectedAssessment.FeatureName & " | " & varSelectedAssessment.Method & " | " & varSelectedAssessment.Year,
              X: 0, Y: 30, Width: Parent.Width, Height: 20,
              Color: varTheme.TextSecondary,
              Font: Font.'Segoe UI',
              Size: 12,
              AccessibleLabel: "Assessment details: " & varSelectedAssessment.FeatureName & " using " & varSelectedAssessment.Method & " method in " & varSelectedAssessment.Year
            ),
            
            // Attribute Comparison Grid with Pass/Fail Indicators
            Container(
              X: 0, Y: 60, Width: Parent.Width, Height: Parent.Height - 120,
              
              // Tabs for different sections
              Container(
                X: 0, Y: 0, Width: Parent.Width, Height: 40,
                
                Button(
                  Text: "Attributes",
                  X: 0, Y: 5, Width: 80, Height: 30,
                  Fill: If(varReviewTab = "Attributes" Or IsBlank(varReviewTab), varTheme.Primary, Color.Transparent),
                  Color: If(varReviewTab = "Attributes" Or IsBlank(varReviewTab), Color.White, varTheme.Primary),
                  BorderColor: varTheme.Primary,
                  BorderThickness: 1,
                  Font: Font.'Segoe UI',
                  Size: 11,
                  RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 0, RadiusBottomRight: 0,
                  OnSelect: Set(varReviewTab, "Attributes"),
                  AccessibleLabel: "View attribute comparison grid"
                ),
                
                Button(
                  Text: "Photos",
                  X: 80, Y: 5, Width: 80, Height: 30,
                  Fill: If(varReviewTab = "Photos", varTheme.Primary, Color.Transparent),
                  Color: If(varReviewTab = "Photos", Color.White, varTheme.Primary),
                  BorderColor: varTheme.Primary,
                  BorderThickness: 1,
                  Font: Font.'Segoe UI',
                  Size: 11,
                  RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 0, RadiusBottomRight: 0,
                  OnSelect: Set(varReviewTab, "Photos"),
                  AccessibleLabel: "View photo carousel"
                ),
                
                Button(
                  Text: "Pressures",
                  X: 160, Y: 5, Width: 80, Height: 30,
                  Fill: If(varReviewTab = "Pressures", varTheme.Primary, Color.Transparent),
                  Color: If(varReviewTab = "Pressures", Color.White, varTheme.Primary),
                  BorderColor: varTheme.Primary,
                  BorderThickness: 1,
                  Font: Font.'Segoe UI',
                  Size: 11,
                  RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 0, RadiusBottomRight: 0,
                  OnSelect: Set(varReviewTab, "Pressures"),
                  AccessibleLabel: "View pressures list"
                )
              ),
              
              // Tab Content
              If(varReviewTab = "Attributes" Or IsBlank(varReviewTab),
                // Attributes Tab - Comparison Grid
                Container(
                  X: 0, Y: 45, Width: Parent.Width, Height: Parent.Height - 45,
                  Fill: varTheme.Surface,
                  BorderColor: varTheme.Primary,
                  BorderThickness: 1,
                  RadiusTopLeft: 0, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
                  
                  // Grid Header
                  Container(
                    X: 10, Y: 10, Width: Parent.Width - 20, Height: 35,
                    Fill: varTheme.Primary,
                    RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4,
                    
                    Label(
                      Text: "Attribute",
                      X: 10, Y: 8, Width: 150, Height: 20,
                      Color: Color.White,
                      Font: Font.'Segoe UI',
                      Size: 11,
                      FontWeight: FontWeight.Semibold,
                      AccessibleLabel: "Attribute name column header"
                    ),
                    
                    Label(
                      Text: "Recorded",
                      X: 170, Y: 8, Width: 80, Height: 20,
                      Color: Color.White,
                      Font: Font.'Segoe UI',
                      Size: 11,
                      FontWeight: FontWeight.Semibold,
                      Align: Align.Center,
                      AccessibleLabel: "Recorded value column header"
                    ),
                    
                    Label(
                      Text: "Target",
                      X: 260, Y: 8, Width: 80, Height: 20,
                      Color: Color.White,
                      Font: Font.'Segoe UI',
                      Size: 11,
                      FontWeight: FontWeight.Semibold,
                      Align: Align.Center,
                      AccessibleLabel: "Target value column header"
                    ),
                    
                    Label(
                      Text: "Result",
                      X: 350, Y: 8, Width: 60, Height: 20,
                      Color: Color.White,
                      Font: Font.'Segoe UI',
                      Size: 11,
                      FontWeight: FontWeight.Semibold,
                      Align: Align.Center,
                      AccessibleLabel: "Pass or fail result column header"
                    ),
                    
                    Label(
                      Text: "Notes",
                      X: 420, Y: 8, Width: Parent.Width - 440, Height: 20,
                      Color: Color.White,
                      Font: Font.'Segoe UI',
                      Size: 11,
                      FontWeight: FontWeight.Semibold,
                      AccessibleLabel: "Notes column header"
                    )
                  ),
                  
                  // Attribute Rows Gallery
                  Gallery(
                    Items: 
                      AddColumns(
                        Filter(colObservations, AssessmentID = varSelectedAssessment.AssessmentID),
                        "AttributeInfo", LookUp(colAttributes, AttributeID = ThisItem.AttributeID),
                        "CategoryInfo", LookUp(colCategories, CategoryID = LookUp(colAttributes, AttributeID = ThisItem.AttributeID).CategoryID)
                      ),
                    X: 10, Y: 55, Width: Parent.Width - 20, Height: Parent.Height - 75,
                    Layout: Layout.Vertical,
                    TemplateSize: 60,
                    LoadingSpinner: LoadingSpinner.Data,
                    AccessibleLabel: "List of attributes with recorded vs target comparison",
                    
                    Container(
                      Fill: If(Mod(ThisItem.Value, 2) = 0, Color.White, varTheme.Surface),
                      BorderColor: varTheme.Border,
                      BorderThickness: 1,
                      RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4,
                      OnSelect: Set(varSelectedAttribute, ThisItem),
                      AccessibleLabel: "Attribute " & ThisItem.AttributeInfo.AttributeName & " with " & ThisItem.PassFail & " result",
                      
                      // Mandatory Indicator
                      If(ThisItem.AttributeInfo.IsMandatory,
                        Rectangle(
                          X: 5, Y: 5, Width: 4, Height: Parent.TemplateHeight - 10,
                          Fill: If(ThisItem.PassFail = "Fail", varTheme.Error, varTheme.Success),
                          RadiusTopLeft: 2, RadiusTopRight: 2, RadiusBottomLeft: 2, RadiusBottomRight: 2
                        )
                      ),
                      
                      // Attribute Name and Category
                      Label(
                        Text: ThisItem.AttributeInfo.AttributeName,
                        X: If(ThisItem.AttributeInfo.IsMandatory, 15, 10), Y: 5, Width: 150, Height: 20,
                        Color: varTheme.Text,
                        Font: Font.'Segoe UI',
                        Size: 11,
                        FontWeight: If(ThisItem.AttributeInfo.IsMandatory, FontWeight.Semibold, FontWeight.Normal),
                        Overflow: Overflow.Ellipsis
                      ),
                      
                      Label(
                        Text: ThisItem.CategoryInfo.CategoryName,
                        X: If(ThisItem.AttributeInfo.IsMandatory, 15, 10), Y: 25, Width: 150, Height: 15,
                        Color: varTheme.TextSecondary,
                        Font: Font.'Segoe UI',
                        Size: 9,
                        Overflow: Overflow.Ellipsis
                      ),
                      
                      // Recorded Value
                      Label(
                        Text: ThisItem.RecordedValue & If(!IsBlank(ThisItem.AttributeInfo.Unit), " " & ThisItem.AttributeInfo.Unit, ""),
                        X: 170, Y: 15, Width: 80, Height: 30,
                        Color: varTheme.Text,
                        Font: Font.'Segoe UI',
                        Size: 12,
                        FontWeight: FontWeight.Semibold,
                        Align: Align.Center,
                        Overflow: Overflow.Ellipsis
                      ),
                      
                      // Target Range/Values
                      Label(
                        Text: 
                          If(!IsBlank(ThisItem.AttributeInfo.AllowedValues),
                            // Choice values
                            Substitute(Substitute(ThisItem.AttributeInfo.AllowedValues, "[", ""), "]", ""),
                            // Numeric range
                            If(!IsBlank(ThisItem.AttributeInfo.TargetMin) And !IsBlank(ThisItem.AttributeInfo.TargetMax),
                              ThisItem.AttributeInfo.TargetMin & "-" & ThisItem.AttributeInfo.TargetMax & If(!IsBlank(ThisItem.AttributeInfo.Unit), " " & ThisItem.AttributeInfo.Unit, ""),
                              If(!IsBlank(ThisItem.AttributeInfo.TargetMin),
                                "≥" & ThisItem.AttributeInfo.TargetMin & If(!IsBlank(ThisItem.AttributeInfo.Unit), " " & ThisItem.AttributeInfo.Unit, ""),
                                If(!IsBlank(ThisItem.AttributeInfo.TargetMax),
                                  "≤" & ThisItem.AttributeInfo.TargetMax & If(!IsBlank(ThisItem.AttributeInfo.Unit), " " & ThisItem.AttributeInfo.Unit, ""),
                                  "Any value"
                                )
                              )
                            )
                          ),
                        X: 260, Y: 15, Width: 80, Height: 30,
                        Color: varTheme.TextSecondary,
                        Font: Font.'Segoe UI',
                        Size: 10,
                        Align: Align.Center,
                        Overflow: Overflow.Ellipsis
                      ),
                      
                      // Pass/Fail Chip
                      Container(
                        X: 350, Y: 15, Width: 60, Height: 25,
                        Fill: Switch(ThisItem.PassFail,
                          "Pass", varTheme.Success,
                          "Fail", If(ThisItem.AttributeInfo.IsMandatory, varTheme.Error, varTheme.Warning),
                          varTheme.TextSecondary
                        ),
                        RadiusTopLeft: 12, RadiusTopRight: 12, RadiusBottomLeft: 12, RadiusBottomRight: 12,
                        
                        Label(
                          Text: ThisItem.PassFail,
                          X: 0, Y: 0, Width: Parent.Width, Height: Parent.Height,
                          Color: Color.White,
                          Font: Font.'Segoe UI',
                          Size: 10,
                          FontWeight: FontWeight.Semibold,
                          Align: Align.Center,
                          AccessibleLabel: ThisItem.PassFail & " result for " & ThisItem.AttributeInfo.AttributeName
                        )
                      ),
                      
                      // Notes (truncated)
                      Label(
                        Text: If(Len(ThisItem.Notes) > 50, Left(ThisItem.Notes, 47) & "...", ThisItem.Notes),
                        X: 420, Y: 10, Width: Parent.TemplateWidth - 440, Height: 40,
                        Color: varTheme.TextSecondary,
                        Font: Font.'Segoe UI',
                        Size: 10,
                        Overflow: Overflow.Ellipsis
                      ),
                      
                      // Expand button for detailed view
                      Button(
                        Text: "ⓘ",
                        X: Parent.TemplateWidth - 30, Y: 15, Width: 25, Height: 25,
                        Fill: Color.Transparent,
                        Color: varTheme.Primary,
                        BorderColor: varTheme.Primary,
                        BorderThickness: 1,
                        Font: Font.'Segoe UI',
                        Size: 12,
                        RadiusTopLeft: 12, RadiusTopRight: 12, RadiusBottomLeft: 12, RadiusBottomRight: 12,
                        OnSelect: Set(varSelectedAttributeDetail, ThisItem),
                        AccessibleLabel: "View detailed information for " & ThisItem.AttributeInfo.AttributeName
                      )
                    )
                  )
                )
              ),
              
              If(varReviewTab = "Photos",
                // Photos Tab - Carousel Component
                Container(
                  X: 0, Y: 45, Width: Parent.Width, Height: Parent.Height - 45,
                  Fill: varTheme.Surface,
                  BorderColor: varTheme.Primary,
                  BorderThickness: 1,
                  RadiusTopLeft: 0, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
                  
                  If(CountRows(Filter(colObservations, AssessmentID = varSelectedAssessment.AssessmentID And !IsBlank(PhotoURL))) = 0,
                    // No photos available
                    Container(
                      X: 0, Y: Parent.Height / 2 - 60, Width: Parent.Width, Height: 120,
                      
                      Icon(
                        Icon: Icon.Camera,
                        X: Parent.Width / 2 - 25, Y: 10, Width: 50, Height: 50,
                        Color: varTheme.TextLight
                      ),
                      
                      Label(
                        Text: "No photos available",
                        X: 0, Y: 70, Width: Parent.Width, Height: 25,
                        Color: varTheme.Text,
                        Font: Font.'Segoe UI',
                        Size: 14,
                        FontWeight: FontWeight.Semibold,
                        Align: Align.Center,
                        AccessibleLabel: "No photos are available for this assessment"
                      ),
                      
                      Label(
                        Text: "Photos will be captured during field work and displayed here for review.",
                        X: 20, Y: 95, Width: Parent.Width - 40, Height: 20,
                        Color: varTheme.TextSecondary,
                        Font: Font.'Segoe UI',
                        Size: 11,
                        Align: Align.Center,
                        AccessibleLabel: "Information about photo availability"
                      )
                    ),
                    
                    // Photo Carousel
                    Container(
                      // Photo Navigation
                      Container(
                        X: 10, Y: 10, Width: Parent.Width - 20, Height: 40,
                        
                        Label(
                          Text: "Photos (" & CountRows(Filter(colObservations, AssessmentID = varSelectedAssessment.AssessmentID And !IsBlank(PhotoURL))) & ")",
                          X: 0, Y: 10, Width: 200, Height: 20,
                          Color: varTheme.Text,
                          Font: Font.'Segoe UI',
                          Size: 14,
                          FontWeight: FontWeight.Semibold,
                          AccessibleLabel: "Photo carousel with " & CountRows(Filter(colObservations, AssessmentID = varSelectedAssessment.AssessmentID And !IsBlank(PhotoURL))) & " photos"
                        ),
                        
                        Button(
                          Text: "◀ Prev",
                          X: Parent.Width - 120, Y: 5, Width: 50, Height: 30,
                          Fill: If(varPhotoIndex > 1, varTheme.Primary, varTheme.Surface),
                          Color: If(varPhotoIndex > 1, Color.White, varTheme.TextLight),
                          BorderColor: varTheme.Border,
                          BorderThickness: 1,
                          Font: Font.'Segoe UI',
                          Size: 10,
                          RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4,
                          DisplayMode: If(varPhotoIndex > 1, DisplayMode.Edit, DisplayMode.Disabled),
                          OnSelect: Set(varPhotoIndex, varPhotoIndex - 1),
                          AccessibleLabel: "Go to previous photo"
                        ),
                        
                        Button(
                          Text: "Next ▶",
                          X: Parent.Width - 60, Y: 5, Width: 50, Height: 30,
                          Fill: varTheme.Primary,
                          Color: Color.White,
                          BorderColor: varTheme.Border,
                          BorderThickness: 1,
                          Font: Font.'Segoe UI',
                          Size: 10,
                          RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4,
                          OnSelect: Set(varPhotoIndex, varPhotoIndex + 1),
                          AccessibleLabel: "Go to next photo"
                        )
                      ),
                      
                      // Current Photo Display
                      With({
                        currentPhoto: Index(Filter(colObservations, AssessmentID = varSelectedAssessment.AssessmentID And !IsBlank(PhotoURL)), If(IsBlank(varPhotoIndex), 1, varPhotoIndex))
                      },
                        Container(
                          X: 10, Y: 60, Width: Parent.Width - 20, Height: Parent.Height - 120,
                          Fill: Color.Black,
                          BorderColor: varTheme.Border,
                          BorderThickness: 2,
                          RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
                          
                          // Photo placeholder (in real implementation, this would be an Image control)
                          Container(
                            X: 10, Y: 10, Width: Parent.Width - 20, Height: Parent.Height - 60,
                            Fill: varTheme.Surface,
                            BorderColor: varTheme.Border,
                            BorderThickness: 1,
                            RadiusTopLeft: 4, RadiusTopRight: 4, RadiusBottomLeft: 4, RadiusBottomRight: 4,
                            
                            Icon(
                              Icon: Icon.Camera,
                              X: Parent.Width / 2 - 30, Y: Parent.Height / 2 - 30, Width: 60, Height: 60,
                              Color: varTheme.TextLight
                            ),
                            
                            Label(
                              Text: "Photo: " & currentPhoto.PhotoURL,
                              X: 10, Y: Parent.Height / 2 + 40, Width: Parent.Width - 20, Height: 20,
                              Color: varTheme.TextSecondary,
                              Font: Font.'Segoe UI',
                              Size: 11,
                              Align: Align.Center,
                              AccessibleLabel: "Photo filename: " & currentPhoto.PhotoURL
                            )
                          ),
                          
                          // Photo Caption and Details
                          Container(
                            X: 10, Y: Parent.Height - 45, Width: Parent.Width - 20, Height: 35,
                            Fill: RGBA(0, 0, 0, 0.7),
                            RadiusTopLeft: 0, RadiusTopRight: 0, RadiusBottomLeft: 6, RadiusBottomRight: 6,
                            
                            Label(
                              Text: currentPhoto.AttributeInfo.AttributeName,
                              X: 10, Y: 5, Width: Parent.Width - 20, Height: 15,
                              Color: Color.White,
                              Font: Font.'Segoe UI',
                              Size: 11,
                              FontWeight: FontWeight.Semibold,
                              Overflow: Overflow.Ellipsis
                            ),
                            
                            Label(
                              Text: If(!IsBlank(currentPhoto.Notes), currentPhoto.Notes, "No caption provided"),
                              X: 10, Y: 20, Width: Parent.Width - 20, Height: 12,
                              Color: Color.White,
                              Font: Font.'Segoe UI',
                              Size: 9,
                              Overflow: Overflow.Ellipsis
                            )
                          )
                        )
                      )
                    )
                  )
                )
              ),
              
              If(varReviewTab = "Pressures",
                // Pressures Tab - List with Risk Indicators
                Container(
                  X: 0, Y: 45, Width: Parent.Width, Height: Parent.Height - 45,
                  Fill: varTheme.Surface,
                  BorderColor: varTheme.Primary,
                  BorderThickness: 1,
                  RadiusTopLeft: 0, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
                  
                  // Pressures Header
                  Label(
                    Text: "Identified Pressures and Threats",
                    X: 15, Y: 15, Width: Parent.Width - 30, Height: 25,
                    Color: varTheme.Text,
                    Font: Font.'Segoe UI',
                    Size: 14,
                    FontWeight: FontWeight.Semibold,
                    AccessibleLabel: "List of pressures and threats identified during assessment"
                  ),
                  
                  // Demo Pressures List (in real implementation, this would be linked to assessment data)
                  Gallery(
                    Items: 
                      Filter(colPressures, 
                        PressureID In ["PRESS-GRAZ", "PRESS-TRAM", "PRESS-INVA"] // Demo: show relevant pressures
                      ),
                    X: 15, Y: 50, Width: Parent.Width - 30, Height: Parent.Height - 70,
                    Layout: Layout.Vertical,
                    TemplateSize: 80,
                    AccessibleLabel: "List of pressures affecting this assessment",
                    
                    Container(
                      Fill: Color.White,
                      BorderColor: varTheme.Border,
                      BorderThickness: 1,
                      RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
                      
                      // Risk Level Indicator
                      Rectangle(
                        X: 10, Y: 10, Width: 6, Height: Parent.TemplateHeight - 20,
                        Fill: Switch(ThisItem.RiskLevel,
                          "High", varTheme.Error,
                          "Medium", varTheme.Warning,
                          "Low", varTheme.Success,
                          varTheme.TextSecondary
                        ),
                        RadiusTopLeft: 3, RadiusTopRight: 3, RadiusBottomLeft: 3, RadiusBottomRight: 3
                      ),
                      
                      // Pressure Details
                      Label(
                        Text: ThisItem.PressureName,
                        X: 25, Y: 10, Width: Parent.TemplateWidth - 120, Height: 20,
                        Color: varTheme.Text,
                        Font: Font.'Segoe UI',
                        Size: 12,
                        FontWeight: FontWeight.Semibold,
                        Overflow: Overflow.Ellipsis
                      ),
                      
                      Label(
                        Text: ThisItem.BroadCategory & " | " & ThisItem.DetailedCategory,
                        X: 25, Y: 30, Width: Parent.TemplateWidth - 120, Height: 15,
                        Color: varTheme.TextSecondary,
                        Font: Font.'Segoe UI',
                        Size: 10,
                        Overflow: Overflow.Ellipsis
                      ),
                      
                      Label(
                        Text: ThisItem.Description,
                        X: 25, Y: 45, Width: Parent.TemplateWidth - 120, Height: 25,
                        Color: varTheme.TextSecondary,
                        Font: Font.'Segoe UI',
                        Size: 9,
                        Overflow: Overflow.Ellipsis
                      ),
                      
                      // Risk Level Badge
                      Container(
                        X: Parent.TemplateWidth - 90, Y: 15, Width: 70, Height: 20,
                        Fill: Switch(ThisItem.RiskLevel,
                          "High", varTheme.Error,
                          "Medium", varTheme.Warning,
                          "Low", varTheme.Success,
                          varTheme.TextSecondary
                        ),
                        RadiusTopLeft: 10, RadiusTopRight: 10, RadiusBottomLeft: 10, RadiusBottomRight: 10,
                        
                        Label(
                          Text: ThisItem.RiskLevel & " Risk",
                          X: 0, Y: 0, Width: Parent.Width, Height: Parent.Height,
                          Color: Color.White,
                          Font: Font.'Segoe UI',
                          Size: 9,
                          FontWeight: FontWeight.Semibold,
                          Align: Align.Center,
                          AccessibleLabel: ThisItem.RiskLevel & " risk level for " & ThisItem.PressureName
                        )
                      ),
                      
                      // Urgent Indicator
                      If(ThisItem.IsUrgent,
                        Icon(
                          Icon: Icon.Warning,
                          X: Parent.TemplateWidth - 25, Y: 45, Width: 15, Height: 15,
                          Color: varTheme.Error,
                          AccessibleLabel: "Urgent action required"
                        )
                      )
                    )
                  )
                )
              )
            ),
            
            // Action Buttons - Enhanced for subtask 5.3
            Container(
              X: 0, Y: Parent.Height - 60, Width: Parent.Width, Height: 50,
              
              If(varCanReviewAssessment(varCurrentUser.Role),
                Button(
                  Text: "✅ Approve",
                  X: 0, Y: 10, Width: 100, Height: 40,
                  Fill: varTheme.Success,
                  Color: Color.White,
                  Font: Font.'Segoe UI',
                  Size: 12,
                  FontWeight: FontWeight.Semibold,
                  RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
                  OnSelect: 
                    // Show approval confirmation dialog
                    Set(varShowApprovalDialog, true),
                  AccessibleLabel: "Approve this assessment and move to under review status"
                ),
                Label(
                  Text: "❌ No permission to review this assessment",
                  X: 0, Y: 10, Width: 250, Height: 40,
                  Color: varTheme.Error,
                  Font: Font.'Segoe UI',
                  Size: 11,
                  Align: Align.Center,
                  AccessibleLabel: "You do not have permission to review this assessment"
                )
              ),
              
              If(varCanReviewAssessment(varCurrentUser.Role),
                Button(
                  Text: "❌ Reject",
                  X: 110, Y: 10, Width: 100, Height: 40,
                  Fill: varTheme.Error,
                  Color: Color.White,
                  Font: Font.'Segoe UI',
                  Size: 12,
                  FontWeight: FontWeight.Semibold,
                  RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
                  OnSelect: 
                    // Show rejection reason dialog
                    Set(varShowRejectionDialog, true);
                    Set(varRejectionReason, "");
                    Set(varRejectionCategory, ""),
                  AccessibleLabel: "Reject this assessment and return to assessor"
                )
              )
            )
          )
        )
      )
    )
  ),
  
  // Approval Confirmation Dialog
  If(varShowApprovalDialog,
    Container(
      X: 0, Y: 0, Width: Parent.Width, Height: Parent.Height,
      Fill: RGBA(0, 0, 0, 0.5),
      
      Container(
        X: Parent.Width / 2 - 200, Y: Parent.Height / 2 - 150, Width: 400, Height: 300,
        Fill: Color.White,
        BorderColor: varTheme.Primary,
        BorderThickness: 2,
        RadiusTopLeft: 12, RadiusTopRight: 12, RadiusBottomLeft: 12, RadiusBottomRight: 12,
        
        // Dialog Header
        Container(
          X: 0, Y: 0, Width: Parent.Width, Height: 50,
          Fill: varTheme.Primary,
          RadiusTopLeft: 10, RadiusTopRight: 10, RadiusBottomLeft: 0, RadiusBottomRight: 0,
          
          Label(
            Text: "✅ Confirm Approval",
            X: 20, Y: 15, Width: Parent.Width - 60, Height: 20,
            Color: Color.White,
            Font: Font.'Segoe UI',
            Size: 14,
            FontWeight: FontWeight.Semibold,
            AccessibleLabel: "Confirm approval dialog"
          ),
          
          Button(
            Text: "✕",
            X: Parent.Width - 35, Y: 10, Width: 25, Height: 25,
            Fill: Color.Transparent,
            Color: Color.White,
            BorderColor: Color.Transparent,
            Font: Font.'Segoe UI',
            Size: 14,
            OnSelect: Set(varShowApprovalDialog, false),
            AccessibleLabel: "Close approval dialog"
          )
        ),
        
        // Dialog Content
        Label(
          Text: "Are you sure you want to approve this assessment?",
          X: 20, Y: 70, Width: Parent.Width - 40, Height: 25,
          Color: varTheme.Text,
          Font: Font.'Segoe UI',
          Size: 12,
          FontWeight: FontWeight.Semibold,
          AccessibleLabel: "Confirmation question for approval"
        ),
        
        Label(
          Text: "Assessment: " & varSelectedAssessment.SiteName & " - " & varSelectedAssessment.FeatureName,
          X: 20, Y: 100, Width: Parent.Width - 40, Height: 20,
          Color: varTheme.TextSecondary,
          Font: Font.'Segoe UI',
          Size: 11,
          AccessibleLabel: "Assessment details being approved"
        ),
        
        Label(
          Text: "This will move the assessment to 'Under Review' status and notify the manager for final outcome determination.",
          X: 20, Y: 130, Width: Parent.Width - 40, Height: 40,
          Color: varTheme.TextSecondary,
          Font: Font.'Segoe UI',
          Size: 10,
          AccessibleLabel: "Information about what happens after approval"
        ),
        
        // Action Buttons
        Container(
          X: 0, Y: Parent.Height - 60, Width: Parent.Width, Height: 50,
          
          Button(
            Text: "Cancel",
            X: Parent.Width - 180, Y: 10, Width: 80, Height: 35,
            Fill: Color.Transparent,
            Color: varTheme.TextSecondary,
            BorderColor: varTheme.Border,
            BorderThickness: 1,
            Font: Font.'Segoe UI',
            Size: 11,
            RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
            OnSelect: Set(varShowApprovalDialog, false),
            AccessibleLabel: "Cancel approval action"
          ),
          
          Button(
            Text: "✅ Approve",
            X: Parent.Width - 90, Y: 10, Width: 80, Height: 35,
            Fill: varTheme.Success,
            Color: Color.White,
            Font: Font.'Segoe UI',
            Size: 11,
            FontWeight: FontWeight.Semibold,
            RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
            OnSelect: 
              // Execute approval with comprehensive audit trail
              UpdateIf(colAssessments, AssessmentID = varSelectedAssessment.AssessmentID, {
                Status: "UnderReview", 
                ModifiedBy: varCurrentUser.UserID, 
                ModifiedDate: Now()
              });
              
              // Create detailed audit record
              Collect(colAudit, {
                AuditID: GUID(),
                AssessmentID: varSelectedAssessment.AssessmentID,
                Action: "Approve",
                UserID: varCurrentUser.UserID,
                UserName: varCurrentUser.Name,
                Timestamp: Now(),
                Details: "Assessment approved by reviewer and moved to Under Review status for manager outcome determination",
                Reason: "Quality review passed - all mandatory attributes reviewed and assessment meets standards"
              });
              
              // Log event for diagnostics
              Collect(colEventLog, {
                EventID: GUID(),
                EventType: "Approve",
                Timestamp: Now(),
                UserID: varCurrentUser.UserID,
                UserName: varCurrentUser.Name,
                CorrelationID: varGenerateCorrelationID(),
                Details: "Assessment " & varSelectedAssessment.AssessmentID & " approved by " & varCurrentUser.Name,
                Screen: "ReviewScreen"
              });
              
              // Close dialog and notify
              Set(varShowApprovalDialog, false);
              Notify("✅ Assessment approved and moved to Under Review", NotificationType.Success, 4000);
              Set(varSelectedAssessment, Blank()),
            AccessibleLabel: "Confirm approval of assessment"
          )
        )
      )
    )
  ),
  
  // Rejection Reason Dialog
  If(varShowRejectionDialog,
    Container(
      X: 0, Y: 0, Width: Parent.Width, Height: Parent.Height,
      Fill: RGBA(0, 0, 0, 0.5),
      
      Container(
        X: Parent.Width / 2 - 250, Y: Parent.Height / 2 - 200, Width: 500, Height: 400,
        Fill: Color.White,
        BorderColor: varTheme.Error,
        BorderThickness: 2,
        RadiusTopLeft: 12, RadiusTopRight: 12, RadiusBottomLeft: 12, RadiusBottomRight: 12,
        
        // Dialog Header
        Container(
          X: 0, Y: 0, Width: Parent.Width, Height: 50,
          Fill: varTheme.Error,
          RadiusTopLeft: 10, RadiusTopRight: 10, RadiusBottomLeft: 0, RadiusBottomRight: 0,
          
          Label(
            Text: "❌ Rejection Reason Required",
            X: 20, Y: 15, Width: Parent.Width - 60, Height: 20,
            Color: Color.White,
            Font: Font.'Segoe UI',
            Size: 14,
            FontWeight: FontWeight.Semibold,
            AccessibleLabel: "Rejection reason dialog"
          ),
          
          Button(
            Text: "✕",
            X: Parent.Width - 35, Y: 10, Width: 25, Height: 25,
            Fill: Color.Transparent,
            Color: Color.White,
            BorderColor: Color.Transparent,
            Font: Font.'Segoe UI',
            Size: 14,
            OnSelect: Set(varShowRejectionDialog, false),
            AccessibleLabel: "Close rejection dialog"
          )
        ),
        
        // Dialog Content
        Label(
          Text: "Please provide a reason for rejecting this assessment:",
          X: 20, Y: 70, Width: Parent.Width - 40, Height: 25,
          Color: varTheme.Text,
          Font: Font.'Segoe UI',
          Size: 12,
          FontWeight: FontWeight.Semibold,
          AccessibleLabel: "Instructions to provide rejection reason"
        ),
        
        Label(
          Text: "Assessment: " & varSelectedAssessment.SiteName & " - " & varSelectedAssessment.FeatureName,
          X: 20, Y: 100, Width: Parent.Width - 40, Height: 20,
          Color: varTheme.TextSecondary,
          Font: Font.'Segoe UI',
          Size: 11,
          AccessibleLabel: "Assessment details being rejected"
        ),
        
        // Rejection Category
        Label(
          Text: "Rejection Category:",
          X: 20, Y: 130, Width: 150, Height: 25,
          Color: varTheme.Text,
          Font: Font.'Segoe UI',
          Size: 11,
          AccessibleLabel: "Select rejection category"
        ),
        
        Dropdown(
          Items: [
            "Data Quality Issues",
            "Incomplete Field Work", 
            "Methodology Concerns",
            "Missing Required Photos",
            "Attribute Validation Failures",
            "Insufficient Evidence",
            "Other - See Notes"
          ],
          Default: varRejectionCategory,
          X: 20, Y: 155, Width: Parent.Width - 40, Height: 35,
          Font: Font.'Segoe UI',
          Size: 11,
          OnChange: Set(varRejectionCategory, Self.Selected.Value),
          AccessibleLabel: "Select the primary reason category for rejection"
        ),
        
        // Detailed Reason
        Label(
          Text: "Detailed Reason (required):",
          X: 20, Y: 200, Width: 200, Height: 25,
          Color: varTheme.Text,
          Font: Font.'Segoe UI',
          Size: 11,
          AccessibleLabel: "Provide detailed rejection reason"
        ),
        
        TextInput(
          Default: varRejectionReason,
          X: 20, Y: 225, Width: Parent.Width - 40, Height: 80,
          Mode: TextMode.MultiLine,
          Font: Font.'Segoe UI',
          Size: 11,
          OnChange: Set(varRejectionReason, Self.Text),
          HintText: "Please provide specific details about why this assessment is being rejected and what needs to be corrected...",
          AccessibleLabel: "Enter detailed reason for rejection"
        ),
        
        // Action Buttons
        Container(
          X: 0, Y: Parent.Height - 60, Width: Parent.Width, Height: 50,
          
          Button(
            Text: "Cancel",
            X: Parent.Width - 180, Y: 10, Width: 80, Height: 35,
            Fill: Color.Transparent,
            Color: varTheme.TextSecondary,
            BorderColor: varTheme.Border,
            BorderThickness: 1,
            Font: Font.'Segoe UI',
            Size: 11,
            RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
            OnSelect: 
              Set(varShowRejectionDialog, false);
              Set(varRejectionReason, "");
              Set(varRejectionCategory, ""),
            AccessibleLabel: "Cancel rejection action"
          ),
          
          Button(
            Text: "❌ Reject",
            X: Parent.Width - 90, Y: 10, Width: 80, Height: 35,
            Fill: varTheme.Error,
            Color: Color.White,
            Font: Font.'Segoe UI',
            Size: 11,
            FontWeight: FontWeight.Semibold,
            RadiusTopLeft: 8, RadiusTopRight: 8, RadiusBottomLeft: 8, RadiusBottomRight: 8,
            DisplayMode: If(IsBlank(varRejectionCategory) Or IsBlank(varRejectionReason), DisplayMode.Disabled, DisplayMode.Edit),
            OnSelect: 
              // Execute rejection with comprehensive audit trail
              UpdateIf(colAssessments, AssessmentID = varSelectedAssessment.AssessmentID, {
                Status: "Rejected", 
                ModifiedBy: varCurrentUser.UserID, 
                ModifiedDate: Now()
              });
              
              // Create detailed audit record with reason
              Collect(colAudit, {
                AuditID: GUID(),
                AssessmentID: varSelectedAssessment.AssessmentID,
                Action: "Reject",
                UserID: varCurrentUser.UserID,
                UserName: varCurrentUser.Name,
                Timestamp: Now(),
                Details: "Assessment rejected by reviewer - Category: " & varRejectionCategory & " | Details: " & varRejectionReason,
                Reason: varRejectionCategory & " - " & varRejectionReason
              });
              
              // Log event for diagnostics
              Collect(colEventLog, {
                EventID: GUID(),
                EventType: "Reject",
                Timestamp: Now(),
                UserID: varCurrentUser.UserID,
                UserName: varCurrentUser.Name,
                CorrelationID: varGenerateCorrelationID(),
                Details: "Assessment " & varSelectedAssessment.AssessmentID & " rejected by " & varCurrentUser.Name & " - " & varRejectionCategory,
                Screen: "ReviewScreen"
              });
              
              // Close dialog and notify
              Set(varShowRejectionDialog, false);
              Set(varRejectionReason, "");
              Set(varRejectionCategory, "");
              Notify("❌ Assessment rejected and returned to assessor", NotificationType.Warning, 4000);
              Set(varSelectedAssessment, Blank()),
            AccessibleLabel: "Confirm rejection of assessment with provided reason"
          )
        )
      )
    )
  )
);