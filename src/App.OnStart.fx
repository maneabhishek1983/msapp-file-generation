// Natural England Condition Assessment Demo - App OnStart
// Initialize all collections with exact schema from design document

// Sites Collection - SSSI and other designated sites
ClearCollect(colSites,
  {SiteID:"SSSI-101", SiteName:"Breckland Heath SSSI", Region:"East of England", SiteType:"SSSI", IsActive:true},
  {SiteID:"SSSI-205", SiteName:"North York Moors SSSI", Region:"Yorkshire & Humber", SiteType:"SSSI", IsActive:true},
  {SiteID:"SSSI-156", SiteName:"Wicken Fen NNR", Region:"East of England", SiteType:"NNR", IsActive:true},
  {SiteID:"SAC-089", SiteName:"Cotswold Beechwoods SAC", Region:"South West", SiteType:"SAC", IsActive:true},
  {SiteID:"SSSI-312", SiteName:"Dorset Heathlands SSSI", Region:"South West", SiteType:"SSSI", IsActive:true},
  {SiteID:"SSSI-445", SiteName:"Peak District Moors SSSI", Region:"North West", SiteType:"SSSI", IsActive:true}
);

// Features Collection - Habitat types and species features
ClearCollect(colFeatures,
  {FeatureID:"H4030", FeatureName:"European dry heaths", FeatureCode:"H4030", Category:"Heathland", Description:"Lowland heathland dominated by dwarf shrubs", IsActive:true},
  {FeatureID:"H6210", FeatureName:"Semi-natural dry grasslands", FeatureCode:"H6210", Category:"Grassland", Description:"Calcareous grasslands on limestone substrates", IsActive:true},
  {FeatureID:"H7210", FeatureName:"Calcareous fens", FeatureCode:"H7210", Category:"Wetland", Description:"Calcareous fens with Cladium mariscus and species of the Caricion davallianae", IsActive:true},
  {FeatureID:"H9130", FeatureName:"Asperulo-Fagetum beech forests", FeatureCode:"H9130", Category:"Woodland", Description:"Beech forests on neutral to rich soils", IsActive:true},
  {FeatureID:"H4010", FeatureName:"Northern Atlantic wet heaths", FeatureCode:"H4010", Category:"Heathland", Description:"Wet heathland with Erica tetralix", IsActive:true},
  {FeatureID:"H8220", FeatureName:"Siliceous rocky slopes", FeatureCode:"H8220", Category:"Rocky", Description:"Siliceous rocky slopes with chasmophytic vegetation", IsActive:true}
);

// Attributes Collection - Monitoring attributes with exact schema from design
ClearCollect(colAttributes,
  {AttributeID:"ATTR-BG01", CategoryID:"CAT-SF", AttributeName:"Bare Ground Percentage", Description:"Percentage of bare ground within monitoring area", HelpText:"Favourable range 1-10%. Estimate visually in 10m plot; use calliper board if uncertain.", IsMandatory:true, TargetMin:1, TargetMax:10, AllowedValues:"", DataType:"Number", Unit:"%"},
  {AttributeID:"ATTR-DS01", CategoryID:"CAT-VC", AttributeName:"Dwarf Shrub Cover", Description:"Percentage cover of dwarf shrub species", HelpText:"Target range for mature heath 25-90%. Include Calluna, Erica species.", IsMandatory:true, TargetMin:25, TargetMax:90, AllowedValues:"", DataType:"Number", Unit:"%"},
  {AttributeID:"ATTR-LI01", CategoryID:"CAT-ID", AttributeName:"Litter Depth", Description:"Depth of litter layer in millimeters", HelpText:"<10mm generally favourable. Measure at 5 random points per quadrat.", IsMandatory:false, TargetMin:0, TargetMax:10, AllowedValues:"", DataType:"Number", Unit:"mm"},
  {AttributeID:"ATTR-INV01", CategoryID:"CAT-ID", AttributeName:"Invasive Species Presence", Description:"Presence or absence of invasive species", HelpText:"Presence indicates Unfavourable condition. Record species if present.", IsMandatory:false, TargetMin:0, TargetMax:0, AllowedValues:"[\"Absent\",\"Present\"]", DataType:"Choice", Unit:""},
  {AttributeID:"ATTR-GH01", CategoryID:"CAT-SF", AttributeName:"Grass Height", Description:"Average height of grass sward in centimeters", HelpText:"Target 2-15cm for calcareous grassland. Measure at multiple points.", IsMandatory:true, TargetMin:2, TargetMax:15, AllowedValues:"", DataType:"Number", Unit:"cm"},
  {AttributeID:"ATTR-FC01", CategoryID:"CAT-VC", AttributeName:"Forb Cover Percentage", Description:"Percentage cover of forb species", HelpText:"Include all non-grass flowering plants. Key indicator for grassland quality.", IsMandatory:true, TargetMin:30, TargetMax:90, AllowedValues:"", DataType:"Number", Unit:"%"},
  {AttributeID:"ATTR-WL01", CategoryID:"CAT-SF", AttributeName:"Water Level", Description:"Water level relative to surface", HelpText:"Critical for wetland features. Measure from fixed datum point.", IsMandatory:true, TargetMin:-10, TargetMax:5, AllowedValues:"", DataType:"Number", Unit:"cm"},
  {AttributeID:"ATTR-PH01", CategoryID:"CAT-SF", AttributeName:"Soil pH", Description:"Soil pH measurement", HelpText:"Important for calcareous habitats. Use calibrated pH meter.", IsMandatory:false, TargetMin:6.5, TargetMax:8.5, AllowedValues:"", DataType:"Number", Unit:"pH"}
);

// Categories Collection - Attribute categories
ClearCollect(colCategories,
  {CategoryID:"CAT-SF", CategoryName:"Structure & Function", Description:"Physical structure and functional attributes", SortOrder:1, IsActive:true},
  {CategoryID:"CAT-VC", CategoryName:"Vegetation Composition", Description:"Species composition and vegetation characteristics", SortOrder:2, IsActive:true},
  {CategoryID:"CAT-ID", CategoryName:"Indicators of Damage", Description:"Signs of damage or negative pressures", SortOrder:3, IsActive:true},
  {CategoryID:"CAT-WQ", CategoryName:"Water Quality", Description:"Water quality parameters for aquatic features", SortOrder:4, IsActive:true}
);

// Pressures Collection - Threats and pressures affecting sites
ClearCollect(colPressures,
  {PressureID:"PRESS-GRAZ", PressureName:"Inappropriate grazing", BroadCategory:"Management", DetailedCategory:"Grazing pressure", RiskLevel:"High", IsUrgent:true, Description:"Over or under-grazing affecting vegetation structure"},
  {PressureID:"PRESS-TRAM", PressureName:"Trampling", BroadCategory:"Recreation", DetailedCategory:"Physical damage", RiskLevel:"Medium", IsUrgent:false, Description:"Damage from foot traffic and informal recreation"},
  {PressureID:"PRESS-INVA", PressureName:"Invasive species", BroadCategory:"Species", DetailedCategory:"Non-native species", RiskLevel:"High", IsUrgent:true, Description:"Spread of invasive non-native plant species"},
  {PressureID:"PRESS-POLL", PressureName:"Air pollution", BroadCategory:"Pollution", DetailedCategory:"Atmospheric deposition", RiskLevel:"Medium", IsUrgent:false, Description:"Nitrogen deposition and other air pollutants"},
  {PressureID:"PRESS-WATR", PressureName:"Water level changes", BroadCategory:"Hydrology", DetailedCategory:"Water abstraction", RiskLevel:"High", IsUrgent:true, Description:"Changes to natural water levels"},
  {PressureID:"PRESS-FIRE", PressureName:"Inappropriate burning", BroadCategory:"Management", DetailedCategory:"Fire management", RiskLevel:"Medium", IsUrgent:false, Description:"Uncontrolled or inappropriate burning regime"}
);

// Users Collection - System users with role-based access
ClearCollect(colUsers,
  {UserID:"alice.evans@naturalengland.org.uk", Name:"Alice Evans", Role:"Planner", Team:"Norfolk & Suffolk", Region:"East of England"},
  {UserID:"ben.hughes@naturalengland.org.uk", Name:"Ben Hughes", Role:"Reviewer", Team:"East of England", Region:"East of England"},
  {UserID:"chloe.patel@naturalengland.org.uk", Name:"Chloe Patel", Role:"Manager", Team:"East of England", Region:"East of England"},
  {UserID:"david.smith@naturalengland.org.uk", Name:"David Smith", Role:"Admin", Team:"IT Support", Region:"National"},
  {UserID:"emma.jones@naturalengland.org.uk", Name:"Emma Jones", Role:"Planner", Team:"Yorkshire Dales", Region:"Yorkshire & Humber"},
  {UserID:"frank.wilson@naturalengland.org.uk", Name:"Frank Wilson", Role:"Reviewer", Team:"South West", Region:"South West"}
);

// Assessments Collection - Core assessment records with exact schema from design
Set(varSampleAssessmentID, GUID());
ClearCollect(colAssessments,
  {
    AssessmentID: varSampleAssessmentID,
    SiteID: "SSSI-101",
    SiteName: "Breckland Heath SSSI",
    FeatureID: "H4030",
    FeatureName: "European dry heaths",
    Method: "CSM2020",
    Year: 2025,
    Cycle: "6-year",
    Status: "Submitted", // Draft → InField → Submitted → UnderReview → Approved | Rejected
    ReviewerID: "ben.hughes@naturalengland.org.uk",
    ReviewerName: "Ben Hughes",
    WebMapID: "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    CreatedBy: "alice.evans@naturalengland.org.uk",
    CreatedDate: DateAdd(Now(), -7, Days),
    ModifiedBy: "alice.evans@naturalengland.org.uk",
    ModifiedDate: DateAdd(Now(), -2, Days)
  },
  {
    AssessmentID: GUID(),
    SiteID: "SSSI-205",
    SiteName: "North York Moors SSSI",
    FeatureID: "H6210",
    FeatureName: "Semi-natural dry grasslands",
    Method: "CSM2020",
    Year: 2025,
    Cycle: "6-year",
    Status: "Draft",
    ReviewerID: "frank.wilson@naturalengland.org.uk",
    ReviewerName: "Frank Wilson",
    WebMapID: "b2c3d4e5-f6g7-8901-bcde-f23456789012",
    CreatedBy: "emma.jones@naturalengland.org.uk",
    CreatedDate: DateAdd(Now(), -3, Days),
    ModifiedBy: "emma.jones@naturalengland.org.uk",
    ModifiedDate: DateAdd(Now(), -1, Days)
  },
  {
    AssessmentID: GUID(),
    SiteID: "SSSI-156",
    SiteName: "Wicken Fen NNR",
    FeatureID: "H7210",
    FeatureName: "Calcareous fens",
    Method: "CSM2020",
    Year: 2025,
    Cycle: "6-year",
    Status: "UnderReview",
    ReviewerID: "ben.hughes@naturalengland.org.uk",
    ReviewerName: "Ben Hughes",
    WebMapID: "c3d4e5f6-g7h8-9012-cdef-345678901234",
    CreatedBy: "alice.evans@naturalengland.org.uk",
    CreatedDate: DateAdd(Now(), -14, Days),
    ModifiedBy: "ben.hughes@naturalengland.org.uk",
    ModifiedDate: DateAdd(Now(), -1, Days)
  }
);

// Observations Collection - Field observation data with exact schema from design
ClearCollect(colObservations,
  {
    ObservationID: GUID(),
    AssessmentID: varSampleAssessmentID,
    AttributeID: "ATTR-BG01",
    RecordedValue: "6",
    PassFail: "Pass",
    Notes: "Within favourable range, good natural regeneration visible",
    PhotoURL: "breckland_bare_ground_001.jpg",
    LocationX: 52.4821,
    LocationY: 0.7519,
    RecordedBy: "alice.evans@naturalengland.org.uk",
    RecordedDate: DateAdd(Now(), -2, Days)
  },
  {
    ObservationID: GUID(),
    AssessmentID: varSampleAssessmentID,
    AttributeID: "ATTR-DS01",
    RecordedValue: "40",
    PassFail: "Pass",
    Notes: "Healthy dwarf shrub community, good age structure",
    PhotoURL: "breckland_dwarf_shrub_001.jpg",
    LocationX: 52.4825,
    LocationY: 0.7522,
    RecordedBy: "alice.evans@naturalengland.org.uk",
    RecordedDate: DateAdd(Now(), -2, Days)
  },
  {
    ObservationID: GUID(),
    AssessmentID: varSampleAssessmentID,
    AttributeID: "ATTR-LI01",
    RecordedValue: "15",
    PassFail: "Fail",
    Notes: "Slight excess litter accumulation near access point",
    PhotoURL: "breckland_litter_001.jpg",
    LocationX: 52.4818,
    LocationY: 0.7515,
    RecordedBy: "alice.evans@naturalengland.org.uk",
    RecordedDate: DateAdd(Now(), -2, Days)
  },
  {
    ObservationID: GUID(),
    AssessmentID: varSampleAssessmentID,
    AttributeID: "ATTR-INV01",
    RecordedValue: "Absent",
    PassFail: "Pass",
    Notes: "No invasive species observed during survey",
    PhotoURL: "",
    LocationX: 52.4823,
    LocationY: 0.7520,
    RecordedBy: "alice.evans@naturalengland.org.uk",
    RecordedDate: DateAdd(Now(), -2, Days)
  }
);

// Outcomes Collection - Assessment outcomes with exact schema from design
ClearCollect(colOutcomes,
  {
    OutcomeID: GUID(),
    AssessmentID: varSampleAssessmentID,
    SuggestedOutcome: "Unfavourable – No Change",
    FinalOutcome: "Unfavourable – No Change",
    IsOverride: false,
    Justification: "Automated calculation based on mandatory attribute failures",
    Confidence: "High",
    ApprovedBy: "",
    ApprovedDate: Blank()
  }
);

// Audit Collection - Action audit trail with exact schema from design
ClearCollect(colAudit,
  {
    AuditID: GUID(),
    AssessmentID: varSampleAssessmentID,
    Action: "Publish",
    UserID: "alice.evans@naturalengland.org.uk",
    UserName: "Alice Evans",
    Timestamp: DateAdd(Now(), -7, Days),
    Details: "Assessment published for field collection",
    Reason: "Initial publication"
  },
  {
    AuditID: GUID(),
    AssessmentID: varSampleAssessmentID,
    Action: "Simulate Sync",
    UserID: "alice.evans@naturalengland.org.uk",
    UserName: "Alice Evans",
    Timestamp: DateAdd(Now(), -2, Days),
    Details: "Field data synchronized from mobile device",
    Reason: "Field work completed"
  }
);

// Assessment Lifecycle State Machine Implementation
// Valid states: Draft → InField → Submitted → UnderReview → Approved | Rejected
Set(varValidStates, ["Draft", "InField", "Submitted", "UnderReview", "Approved", "Rejected"]);

// State transition validation function
Set(varValidateStateTransition, Function(currentState As Text, newState As Text) As Boolean:
  Switch(currentState,
    "Draft", newState = "InField",
    "InField", newState = "Submitted" Or newState = "Rejected",
    "Submitted", newState = "UnderReview" Or newState = "Rejected",
    "UnderReview", newState = "Approved" Or newState = "Rejected",
    "Approved", false, // Terminal state
    "Rejected", newState = "Draft", // Can restart from rejected
    false
  )
);

// State transition function with audit logging
Set(varTransitionAssessmentState, Function(assessmentID As Text, newState As Text, userID As Text, userName As Text, reason As Text) As Boolean:
  With(
    {currentAssessment: LookUp(colAssessments, AssessmentID = assessmentID)},
    If(
      IsBlank(currentAssessment),
      false,
      If(
        varValidateStateTransition(currentAssessment.Status, newState),
        // Valid transition - update assessment and log audit
        UpdateIf(colAssessments, AssessmentID = assessmentID, {Status: newState, ModifiedBy: userID, ModifiedDate: Now()});
        Collect(colAudit, {
          AuditID: GUID(),
          AssessmentID: assessmentID,
          Action: "State Change: " & currentAssessment.Status & " → " & newState,
          UserID: userID,
          UserName: userName,
          Timestamp: Now(),
          Details: "Assessment status changed from " & currentAssessment.Status & " to " & newState,
          Reason: reason
        });
        true,
        false
      )
    )
  )
);

// Demo data for reports and analytics
ClearCollect(colReportData,
  {Year:2019, Outcome:"Favourable", Count:45, Region:"East of England"},
  {Year:2019, Outcome:"Unfavourable – Recovering", Count:23, Region:"East of England"},
  {Year:2019, Outcome:"Unfavourable – No Change", Count:18, Region:"East of England"},
  {Year:2019, Outcome:"Unfavourable – Declining", Count:12, Region:"East of England"},
  {Year:2020, Outcome:"Favourable", Count:42, Region:"East of England"},
  {Year:2020, Outcome:"Unfavourable – Recovering", Count:28, Region:"East of England"},
  {Year:2020, Outcome:"Unfavourable – No Change", Count:15, Region:"East of England"},
  {Year:2020, Outcome:"Unfavourable – Declining", Count:10, Region:"East of England"},
  {Year:2021, Outcome:"Favourable", Count:48, Region:"East of England"},
  {Year:2021, Outcome:"Unfavourable – Recovering", Count:25, Region:"East of England"},
  {Year:2021, Outcome:"Unfavourable – No Change", Count:16, Region:"East of England"},
  {Year:2021, Outcome:"Unfavourable – Declining", Count:8, Region:"East of England"},
  {Year:2022, Outcome:"Favourable", Count:51, Region:"East of England"},
  {Year:2022, Outcome:"Unfavourable – Recovering", Count:22, Region:"East of England"},
  {Year:2022, Outcome:"Unfavourable – No Change", Count:14, Region:"East of England"},
  {Year:2022, Outcome:"Unfavourable – Declining", Count:9, Region:"East of England"}
);

// Pressure statistics for reports
ClearCollect(colPressureStats,
  {PressureType:"Inappropriate grazing", Count:15, Percentage:33, RiskLevel:"High"},
  {PressureType:"Trampling", Count:12, Percentage:27, RiskLevel:"Medium"},
  {PressureType:"Invasive species", Count:8, Percentage:18, RiskLevel:"High"},
  {PressureType:"Air pollution", Count:6, Percentage:13, RiskLevel:"Medium"},
  {PressureType:"Water level changes", Count:4, Percentage:9, RiskLevel:"High"}
);

// Set current user context (demo user)
Set(varCurrentUser, LookUp(colUsers, UserID="alice.evans@naturalengland.org.uk"));

// Initialize error handling and correlation ID tracking
ClearCollect(colErrorLog, {});
Set(varCorrelationIDCounter, 1);

// Generate correlation ID function (timestamp + random suffix)
Set(varGenerateCorrelationID, Function() As Text:
  Text(Now(), "yyyymmddhhmmss") & "-" & Text(RandBetween(1000, 9999))
);

// Role-based permission functions
Set(varCanCreateAssessment, Function(userRole As Text) As Boolean:
  userRole In ["Planner", "Manager", "Admin"]
);

Set(varCanReviewAssessment, Function(userRole As Text) As Boolean:
  userRole In ["Reviewer", "Manager", "Admin"]
);

Set(varCanApproveOutcome, Function(userRole As Text) As Boolean:
  userRole In ["Manager", "Admin"]
);

Set(varCanManageAdmin, Function(userRole As Text) As Boolean:
  userRole = "Admin"
);

// Assessment validation functions
Set(varCanEditAssessment, Function(assessment As Record, userID As Text, userRole As Text) As Boolean:
  If(
    userRole In ["Manager", "Admin"],
    true,
    If(
      userRole = "Planner" And assessment.CreatedBy = userID And assessment.Status In ["Draft", "InField"],
      true,
      false
    )
  )
);

// Assessment publishing validation (guardrails)
Set(varValidatePublishGuardrails, Function(assessment As Record) As Record:
  With(
    {
      hasSite: !IsBlank(assessment.SiteID),
      hasFeature: !IsBlank(assessment.FeatureID),
      hasAttributes: CountRows(Filter(colObservations, AssessmentID = assessment.AssessmentID)) > 0,
      hasWebMapID: !IsBlank(assessment.WebMapID),
      hasReviewer: !IsBlank(assessment.ReviewerID),
      hasValidWebMapFormat: IsMatch(assessment.WebMapID, "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")
    },
    {
      CanPublish: hasSite And hasFeature And hasAttributes And hasWebMapID And hasReviewer And hasValidWebMapFormat,
      Errors: Concatenate(
        If(!hasSite, "Site selection required; ", ""),
        If(!hasFeature, "Feature selection required; ", ""),
        If(!hasAttributes, "At least one attribute required; ", ""),
        If(!hasWebMapID, "WebMap ID required; ", ""),
        If(!hasReviewer, "Reviewer assignment required; ", ""),
        If(!hasValidWebMapFormat And !IsBlank(assessment.WebMapID), "Invalid WebMap ID format; ", "")
      )
    }
  )
);

// WebMap ID validation function
Set(varValidateWebMapID, Function(webMapID As Text) As Record:
  With(
    {
      isValidFormat: IsMatch(webMapID, "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"),
      isAvailable: true // Demo: assume all valid format IDs are available
    },
    {
      IsValid: isValidFormat And isAvailable,
      FormatValid: isValidFormat,
      Available: isAvailable,
      Message: If(
        !isValidFormat,
        "Invalid GUID format. Expected format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        If(!isAvailable, "WebMap not accessible or does not exist", "Valid WebMap ID")
      )
    }
  )
);

// Initialize enhanced wizard and application variables
Set(varWizardStep, 1);
Set(varWizardInitialized, false);
Set(varWizardErrors, []);
Set(varFocusedControl, "");
Set(varShowPublishConfirmation, false);
Set(varRegionFilter, Blank());
Set(varWebMapValidation, Blank());
Set(varWebMapChecking, false);
Set(varWebMapCheckResult, Blank());
Set(varWebMapAvailable, false);
Set(varWebMapMetadata, Blank());
Set(varShowLayerPreview, false);
Set(varSelectedSite, Blank());
Set(varSelectedFeature, Blank());
Set(varSelectedAttributes, []);
Set(varNewAssessment, Blank());
Set(varCurrentAssessment, Blank());

// Initialize wizard data structure for preserving user entries
Set(varWizardData, {
  Site: Blank(),
  Feature: Blank(),
  Method: "CSM2020",
  Year: 2025,
  Cycle: "6-year",
  Attributes: [],
  WebMapID: "",
  Reviewer: Blank(),
  ValidationErrors: []
});

// Initialize Field Status Screen variables
Set(varMapLoading, false);
Set(varMapLoadTimeout, false);
Set(varMapError, false);
Set(varMapErrorMessage, "");
Set(varMapRetryCount, 0);
Set(varShowLayerToggles, true);
Set(varLayerVisibility, {
  Transects: true,
  PhotoPoints: true,
  Stops: true
});
Set(varSelectedLayerItem, Blank());
Set(varShowItemDetail, false);
Set(varSyncInProgress, false);
Set(varLastSyncTime, Blank());
Set(varLastRefreshTime, Blank());
Set(varFieldCoverage, 75);
Set(varCurrentAssessmentForField, First(Filter(colAssessments, Status = "InField" Or Status = "Submitted")));

// Set Natural England branding theme colors
Set(varTheme, {
  Primary: "#1F4D3A",        // Natural England Green
  Secondary: "#6B8E23",      // Olive Green  
  Accent: "#228B22",         // Forest Green
  Background: "#FFFFFF",     // White
  Surface: "#F8F9FA",        // Light Grey Surface
  SurfaceDark: "#E9ECEF",    // Darker Surface
  Text: "#212529",           // Dark Text
  TextSecondary: "#6C757D",  // Secondary Text
  TextLight: "#ADB5BD",      // Light Text
  Success: "#28A745",        // Success Green
  Warning: "#FFC107",        // Warning Amber
  Error: "#DC3545",          // Error Red
  Info: "#17A2B8",           // Info Blue
  Border: "#DEE2E6",         // Border Grey
  Focus: "#80BDFF"           // Focus Blue
});

// Application metadata (for About panel)
Set(varAppMetadata, {
  Version: "1.0.0",
  BuildTimestamp: "2025-01-19T10:30:00Z",
  CommitHash: "abc123def456",
  Environment: "Demo"
});

// Initialize field status collections for AGOL integration
ClearCollect(colTransects,
  {TransectId:"T1", Name:"Transect 1 - North Heath", Status:"Complete", StopsRecorded:15, TotalStops:15, LastUpdate:DateAdd(Now(), -3, Days), Notes:"All stops completed successfully", AssessmentID:varSampleAssessmentID},
  {TransectId:"T2", Name:"Transect 2 - Central Heath", Status:"InProgress", StopsRecorded:8, TotalStops:12, LastUpdate:DateAdd(Now(), -1, Days), Notes:"Partial completion - weather delay", AssessmentID:varSampleAssessmentID},
  {TransectId:"T3", Name:"Transect 3 - South Heath", Status:"NotStarted", StopsRecorded:0, TotalStops:10, LastUpdate:Blank(), Notes:"", AssessmentID:varSampleAssessmentID},
  {TransectId:"T4", Name:"Transect 4 - East Boundary", Status:"Complete", StopsRecorded:8, TotalStops:8, LastUpdate:DateAdd(Now(), -2, Days), Notes:"Completed with full photo documentation", AssessmentID:varSampleAssessmentID}
);

ClearCollect(colPhotoPoints,
  {PointId:"P1", Name:"Photo Point 1 - Heath Overview", Status:"Complete", PhotoCount:3, LastUpdate:DateAdd(Now(), -3, Days), Notes:"Good overview shots of heath structure", AssessmentID:varSampleAssessmentID},
  {PointId:"P2", Name:"Photo Point 2 - Dwarf Shrub Detail", Status:"Complete", PhotoCount:2, LastUpdate:DateAdd(Now(), -3, Days), Notes:"Close-up of Calluna and Erica", AssessmentID:varSampleAssessmentID},
  {PointId:"P3", Name:"Photo Point 3 - Bare Ground", Status:"InProgress", PhotoCount:1, LastUpdate:DateAdd(Now(), -1, Days), Notes:"Need additional angle shots", AssessmentID:varSampleAssessmentID},
  {PointId:"P4", Name:"Photo Point 4 - Boundary Feature", Status:"Complete", PhotoCount:4, LastUpdate:DateAdd(Now(), -2, Days), Notes:"Boundary with adjacent woodland", AssessmentID:varSampleAssessmentID},
  {PointId:"P5", Name:"Photo Point 5 - Pressure Evidence", Status:"NotStarted", PhotoCount:0, LastUpdate:Blank(), Notes:"", AssessmentID:varSampleAssessmentID}
);

ClearCollect(colStops,
  {StopId:"S1", TransectId:"T1", Name:"Stop 1", Status:"Complete", LastUpdate:DateAdd(Now(), -3, Days), Notes:"Typical heath vegetation", AssessmentID:varSampleAssessmentID},
  {StopId:"S2", TransectId:"T1", Name:"Stop 2", Status:"Complete", LastUpdate:DateAdd(Now(), -3, Days), Notes:"Good dwarf shrub cover", AssessmentID:varSampleAssessmentID},
  {StopId:"S3", TransectId:"T2", Name:"Stop 1", Status:"Complete", LastUpdate:DateAdd(Now(), -1, Days), Notes:"Some litter accumulation", AssessmentID:varSampleAssessmentID},
  {StopId:"S4", TransectId:"T2", Name:"Stop 2", Status:"InProgress", LastUpdate:DateAdd(Now(), -1, Days), Notes:"Partial data collection", AssessmentID:varSampleAssessmentID}
);

// Initialize demo event log for diagnostics
ClearCollect(colEventLog,
  {
    EventID: GUID(),
    EventType: "App Start",
    Timestamp: Now(),
    UserID: varCurrentUser.UserID,
    UserName: varCurrentUser.Name,
    CorrelationID: varGenerateCorrelationID(),
    Details: "Application initialized successfully",
    Screen: "App.OnStart"
  }
);

// Navigate to Home screen
Navigate(HomeScreen, ScreenTransition.Fade);