// Demo Data Manager Component
// Handles demo data reset and initialization for the Natural England Condition Assessment app

// Component properties
Property ResetType As Text = "All"; // All, Assessments, Lookups, Users

// Demo data reset function
Set(varResetDemoData, Function(resetType As Text) As Record:
  With(
    {correlationID: varGenerateCorrelationID()},
    
    // Log the reset action
    Collect(colEventLog, {
      EventID: GUID(),
      EventType: "Demo Data Reset",
      Timestamp: Now(),
      UserID: varCurrentUser.UserID,
      UserName: varCurrentUser.Name,
      CorrelationID: correlationID,
      Details: "Demo data reset initiated: " & resetType,
      Screen: "DemoDataManager"
    });
    
    Switch(resetType,
      "All",
        // Reset all collections
        varResetAllCollections();
        varInitializeDemoData();
        {Success: true, Message: "All demo data has been reset", CorrelationID: correlationID},
        
      "Assessments",
        // Reset only assessment-related data
        ClearCollect(colAssessments, []);
        ClearCollect(colObservations, []);
        ClearCollect(colOutcomes, []);
        ClearCollect(colAudit, []);
        varInitializeAssessmentData();
        {Success: true, Message: "Assessment data has been reset", CorrelationID: correlationID},
        
      "Lookups",
        // Reset lookup collections
        varInitializeLookupData();
        {Success: true, Message: "Lookup data has been reset", CorrelationID: correlationID},
        
      "Users",
        // Reset user data
        varInitializeUserData();
        {Success: true, Message: "User data has been reset", CorrelationID: correlationID},
        
      // Default case
      {Success: false, Message: "Invalid reset type: " & resetType, CorrelationID: correlationID}
    )
  )
);

// Reset all collections function
Set(varResetAllCollections, Function() As Boolean:
  ClearCollect(colSites, []);
  ClearCollect(colFeatures, []);
  ClearCollect(colCategories, []);
  ClearCollect(colAttributes, []);
  ClearCollect(colPressures, []);
  ClearCollect(colUsers, []);
  ClearCollect(colAssessments, []);
  ClearCollect(colObservations, []);
  ClearCollect(colOutcomes, []);
  ClearCollect(colAudit, []);
  ClearCollect(colReportData, []);
  ClearCollect(colPressureStats, []);
  ClearCollect(colEventLog, []);
  true
);

// Initialize complete demo data
Set(varInitializeDemoData, Function() As Boolean:
  varInitializeLookupData();
  varInitializeUserData();
  varInitializeAssessmentData();
  varInitializeReportData();
  true
);

// Initialize lookup data
Set(varInitializeLookupData, Function() As Boolean:
  // Sites Collection
  ClearCollect(colSites,
    {SiteID:"SSSI-101", SiteName:"Breckland Heath SSSI", Region:"East of England", SiteType:"SSSI", IsActive:true},
    {SiteID:"SSSI-205", SiteName:"North York Moors SSSI", Region:"Yorkshire & Humber", SiteType:"SSSI", IsActive:true},
    {SiteID:"SSSI-156", SiteName:"Wicken Fen NNR", Region:"East of England", SiteType:"NNR", IsActive:true},
    {SiteID:"SAC-089", SiteName:"Cotswold Beechwoods SAC", Region:"South West", SiteType:"SAC", IsActive:true},
    {SiteID:"SSSI-312", SiteName:"Dorset Heathlands SSSI", Region:"South West", SiteType:"SSSI", IsActive:true},
    {SiteID:"SSSI-445", SiteName:"Peak District Moors SSSI", Region:"North West", SiteType:"SSSI", IsActive:true}
  );
  
  // Features Collection
  ClearCollect(colFeatures,
    {FeatureID:"H4030", FeatureName:"European dry heaths", FeatureCode:"H4030", Category:"Heathland", Description:"Lowland heathland dominated by dwarf shrubs", IsActive:true},
    {FeatureID:"H6210", FeatureName:"Semi-natural dry grasslands", FeatureCode:"H6210", Category:"Grassland", Description:"Calcareous grasslands on limestone substrates", IsActive:true},
    {FeatureID:"H7210", FeatureName:"Calcareous fens", FeatureCode:"H7210", Category:"Wetland", Description:"Calcareous fens with Cladium mariscus and species of the Caricion davallianae", IsActive:true},
    {FeatureID:"H9130", FeatureName:"Asperulo-Fagetum beech forests", FeatureCode:"H9130", Category:"Woodland", Description:"Beech forests on neutral to rich soils", IsActive:true},
    {FeatureID:"H4010", FeatureName:"Northern Atlantic wet heaths", FeatureCode:"H4010", Category:"Heathland", Description:"Wet heathland with Erica tetralix", IsActive:true},
    {FeatureID:"H8220", FeatureName:"Siliceous rocky slopes", FeatureCode:"H8220", Category:"Rocky", Description:"Siliceous rocky slopes with chasmophytic vegetation", IsActive:true}
  );
  
  // Categories Collection
  ClearCollect(colCategories,
    {CategoryID:"CAT-SF", CategoryName:"Structure & Function", Description:"Physical structure and functional attributes", SortOrder:1, IsActive:true},
    {CategoryID:"CAT-VC", CategoryName:"Vegetation Composition", Description:"Species composition and vegetation characteristics", SortOrder:2, IsActive:true},
    {CategoryID:"CAT-ID", CategoryName:"Indicators of Damage", Description:"Signs of damage or negative pressures", SortOrder:3, IsActive:true},
    {CategoryID:"CAT-WQ", CategoryName:"Water Quality", Description:"Water quality parameters for aquatic features", SortOrder:4, IsActive:true}
  );
  
  // Attributes Collection
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
  
  // Pressures Collection
  ClearCollect(colPressures,
    {PressureID:"PRESS-GRAZ", PressureName:"Inappropriate grazing", BroadCategory:"Management", DetailedCategory:"Grazing pressure", RiskLevel:"High", IsUrgent:true, Description:"Over or under-grazing affecting vegetation structure"},
    {PressureID:"PRESS-TRAM", PressureName:"Trampling", BroadCategory:"Recreation", DetailedCategory:"Physical damage", RiskLevel:"Medium", IsUrgent:false, Description:"Damage from foot traffic and informal recreation"},
    {PressureID:"PRESS-INVA", PressureName:"Invasive species", BroadCategory:"Species", DetailedCategory:"Non-native species", RiskLevel:"High", IsUrgent:true, Description:"Spread of invasive non-native plant species"},
    {PressureID:"PRESS-POLL", PressureName:"Air pollution", BroadCategory:"Pollution", DetailedCategory:"Atmospheric deposition", RiskLevel:"Medium", IsUrgent:false, Description:"Nitrogen deposition and other air pollutants"},
    {PressureID:"PRESS-WATR", PressureName:"Water level changes", BroadCategory:"Hydrology", DetailedCategory:"Water abstraction", RiskLevel:"High", IsUrgent:true, Description:"Changes to natural water levels"},
    {PressureID:"PRESS-FIRE", PressureName:"Inappropriate burning", BroadCategory:"Management", DetailedCategory:"Fire management", RiskLevel:"Medium", IsUrgent:false, Description:"Uncontrolled or inappropriate burning regime"}
  );
  
  true
);

// Initialize user data
Set(varInitializeUserData, Function() As Boolean:
  ClearCollect(colUsers,
    {UserID:"alice.evans@naturalengland.org.uk", Name:"Alice Evans", Role:"Planner", Team:"Norfolk & Suffolk", Region:"East of England"},
    {UserID:"ben.hughes@naturalengland.org.uk", Name:"Ben Hughes", Role:"Reviewer", Team:"East of England", Region:"East of England"},
    {UserID:"chloe.patel@naturalengland.org.uk", Name:"Chloe Patel", Role:"Manager", Team:"East of England", Region:"East of England"},
    {UserID:"david.smith@naturalengland.org.uk", Name:"David Smith", Role:"Admin", Team:"IT Support", Region:"National"},
    {UserID:"emma.jones@naturalengland.org.uk", Name:"Emma Jones", Role:"Planner", Team:"Yorkshire Dales", Region:"Yorkshire & Humber"},
    {UserID:"frank.wilson@naturalengland.org.uk", Name:"Frank Wilson", Role:"Reviewer", Team:"South West", Region:"South West"}
  );
  true
);

// Initialize assessment data
Set(varInitializeAssessmentData, Function() As Boolean:
  Set(varSampleAssessmentID, GUID());
  
  // Create sample assessments
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
      Status: "Submitted",
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
    }
  );
  
  // Create sample observations
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
    }
  );
  
  // Create sample outcomes and audit records
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
    }
  );
  
  true
);

// Initialize report data
Set(varInitializeReportData, Function() As Boolean:
  ClearCollect(colReportData,
    {Year:2019, Outcome:"Favourable", Count:45, Region:"East of England"},
    {Year:2019, Outcome:"Unfavourable – Recovering", Count:23, Region:"East of England"},
    {Year:2019, Outcome:"Unfavourable – No Change", Count:18, Region:"East of England"},
    {Year:2019, Outcome:"Unfavourable – Declining", Count:12, Region:"East of England"},
    {Year:2020, Outcome:"Favourable", Count:42, Region:"East of England"},
    {Year:2020, Outcome:"Unfavourable – Recovering", Count:28, Region:"East of England"},
    {Year:2020, Outcome:"Unfavourable – No Change", Count:15, Region:"East of England"},
    {Year:2020, Outcome:"Unfavourable – Declining", Count:10, Region:"East of England"}
  );
  
  ClearCollect(colPressureStats,
    {PressureType:"Inappropriate grazing", Count:15, Percentage:33, RiskLevel:"High"},
    {PressureType:"Trampling", Count:12, Percentage:27, RiskLevel:"Medium"},
    {PressureType:"Invasive species", Count:8, Percentage:18, RiskLevel:"High"},
    {PressureType:"Air pollution", Count:6, Percentage:13, RiskLevel:"Medium"},
    {PressureType:"Water level changes", Count:4, Percentage:9, RiskLevel:"High"}
  );
  
  true
);

// Component visual representation (reset button)
Button(
  Text: "Reset Demo Data",
  OnSelect: 
    With(
      {result: varResetDemoData(ResetType)},
      If(result.Success,
        Notify("✅ " & result.Message, NotificationType.Success, 3000),
        Notify("❌ " & result.Message, NotificationType.Error, 4000)
      )
    ),
  Fill: varTheme.Warning,
  Color: varTheme.Background,
  BorderRadius: 4,
  Width: 150,
  Height: 40,
  AccessibleLabel: "Reset demo data for " & ResetType
);