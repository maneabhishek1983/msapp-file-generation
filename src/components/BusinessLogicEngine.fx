// Natural England Condition Assessment - Business Logic Engine
// CSM methodology implementation aligned with exact data schema from design

// Main Condition Calculation Function - Updated for new schema
Function CalculateCondition(assessmentID As Text) As Record:
  
  // Get assessment and related data
  Set(varAssessment, LookUp(colAssessments, AssessmentID = assessmentID));
  Set(varObservations, Filter(colObservations, AssessmentID = assessmentID));
  Set(varFeature, LookUp(colFeatures, FeatureID = varAssessment.FeatureID));
  
  // Get feature-specific thresholds and requirements
  Set(varFeatureConfig, Switch(varFeature.FeatureCode,
    "H4030", { // Lowland Heathland
      Name: "Lowland Heathland",
      Thresholds: {
        BareGroundMin: 1, BareGroundMax: 10,
        DwarfShrubMin: 25, DwarfShrubMax: 90,
        LitterMax: 10,
        GrassMax: 25,
        TreeCoverMax: 5
      },
      RequiredSpecies: ["Calluna vulgaris", "Erica tetralix", "Ulex minor"],
      CriticalAttributes: ["BG01", "DS01", "LI01"],
      Weights: {
        StructureFunction: 0.35,
        VegetationComposition: 0.30,
        SpeciesPresence: 0.20,
        Pressures: 0.15
      }
    },
    "H6210", { // Calcareous Grassland
      Name: "Calcareous Grassland",
      Thresholds: {
        GrassHeightMin: 2, GrassHeightMax: 15,
        ForbCoverMin: 30, ForbCoverMax: 90,
        BareGroundMax: 5,
        LitterMax: 5
      },
      RequiredSpecies: ["Festuca ovina", "Helianthemum nummularium", "Thymus praecox"],
      CriticalAttributes: ["GH01", "FC01", "BG01"],
      Weights: {
        StructureFunction: 0.40,
        VegetationComposition: 0.35,
        SpeciesPresence: 0.15,
        Pressures: 0.10
      }
    },
    // Default configuration
    {
      Name: "Unknown Feature",
      Thresholds: {
        BareGroundMin: 1, BareGroundMax: 10,
        DwarfShrubMin: 25, DwarfShrubMax: 90,
        LitterMax: 10,
        GrassMax: 25,
        TreeCoverMax: 5
      },
      RequiredSpecies: [],
      CriticalAttributes: ["BG01", "DS01"],
      Weights: {
        StructureFunction: 0.35,
        VegetationComposition: 0.30,
        SpeciesPresence: 0.20,
        Pressures: 0.15
      }
    }
  ));
  
  // Calculate individual criterion scores using observations
  Set(varStructureScore, CalculateStructureFunction(varObservations, varFeatureConfig));
  Set(varVegetationScore, CalculateVegetationComposition(varObservations, varFeatureConfig));
  Set(varSpeciesScore, CalculateSpeciesPresence(varObservations, varFeatureConfig));
  Set(varPressureScore, CalculatePressureImpact(assessmentID, varFeatureConfig));
  
  // Calculate weighted overall score
  Set(varOverallScore, 
    varStructureScore.Score * varFeatureConfig.Weights.StructureFunction +
    varVegetationScore.Score * varFeatureConfig.Weights.VegetationComposition +
    varSpeciesScore.Score * varFeatureConfig.Weights.SpeciesPresence +
    varPressureScore.Score * varFeatureConfig.Weights.Pressures
  );
  
  // Determine condition based on score using exact CSM vocabulary
  Set(varCondition, If(
    varOverallScore >= 0.8, "Favourable",
    varOverallScore >= 0.6, "Unfavourable – Recovering",
    varOverallScore >= 0.4, "Unfavourable – No Change",
    varOverallScore >= 0.2, "Unfavourable – Declining",
    "Not Recorded"
  ));
  
  // Calculate confidence based on data completeness
  Set(varConfidenceScore, CalculateConfidence(varObservations, varFeatureConfig));
  Set(varConfidence, If(
    varConfidenceScore >= 0.8, "High",
    varConfidenceScore >= 0.6, "Medium",
    "Low"
  ));
  
  // Return comprehensive result
  {
    OverallScore: varOverallScore,
    Condition: varCondition,
    Confidence: varConfidence,
    ConfidenceScore: varConfidenceScore,
    Timestamp: Now(),
    CalculationVersion: "CSM_2024_v4.2",
    StructureScore: varStructureScore,
    VegetationScore: varVegetationScore,
    SpeciesScore: varSpeciesScore,
    PressureScore: varPressureScore
  }

// Calculate Structure & Function Score using new observation schema
Function CalculateStructureFunction(observations As Table, featureConfig As Record) As Record:
  Set(varScore, 0);
  Set(varMaxScore, 0);
  
  // Bare Ground Assessment (ATTR-BG01)
  Set(varBareGroundObs, LookUp(observations, AttributeID = "ATTR-BG01"));
  If(IsBlank(varBareGroundObs), 
    Set(varScore, varScore + 0.5); Set(varMaxScore, varMaxScore + 1),
    If(Value(varBareGroundObs.RecordedValue) >= featureConfig.Thresholds.BareGroundMin And 
       Value(varBareGroundObs.RecordedValue) <= featureConfig.Thresholds.BareGroundMax,
      Set(varScore, varScore + 1); Set(varMaxScore, varMaxScore + 1),
      Set(varScore, varScore + 0.2); Set(varMaxScore, varMaxScore + 1)
    )
  );
  
  // Litter Assessment (ATTR-LI01)
  Set(varLitterObs, LookUp(observations, AttributeID = "ATTR-LI01"));
  If(IsBlank(varLitterObs),
    Set(varScore, varScore + 0.5); Set(varMaxScore, varMaxScore + 1),
    If(Value(varLitterObs.RecordedValue) <= featureConfig.Thresholds.LitterMax,
      Set(varScore, varScore + 1); Set(varMaxScore, varMaxScore + 1),
      Set(varScore, varScore + 0.3); Set(varMaxScore, varMaxScore + 1)
    )
  );
  
  // Grass Height Assessment (ATTR-GH01) for grassland features
  Set(varGrassHeightObs, LookUp(observations, AttributeID = "ATTR-GH01"));
  If(featureConfig.Name = "Calcareous Grassland" And !IsBlank(varGrassHeightObs),
    If(Value(varGrassHeightObs.RecordedValue) >= featureConfig.Thresholds.GrassHeightMin And 
       Value(varGrassHeightObs.RecordedValue) <= featureConfig.Thresholds.GrassHeightMax,
      Set(varScore, varScore + 1); Set(varMaxScore, varMaxScore + 1),
      Set(varScore, varScore + 0.4); Set(varMaxScore, varMaxScore + 1)
    )
  );
  
  {
    Score: If(varMaxScore > 0, varScore / varMaxScore, 0.5),
    MaxScore: varMaxScore,
    ActualScore: varScore
  }

// Calculate Vegetation Composition Score using new observation schema
Function CalculateVegetationComposition(observations As Table, featureConfig As Record) As Record:
  Set(varScore, 0);
  Set(varMaxScore, 0);
  
  // Dwarf Shrub Cover Assessment (ATTR-DS01)
  Set(varDwarfShrubObs, LookUp(observations, AttributeID = "ATTR-DS01"));
  If(IsBlank(varDwarfShrubObs),
    Set(varScore, varScore + 0.5); Set(varMaxScore, varMaxScore + 1),
    If(Value(varDwarfShrubObs.RecordedValue) >= featureConfig.Thresholds.DwarfShrubMin And 
       Value(varDwarfShrubObs.RecordedValue) <= featureConfig.Thresholds.DwarfShrubMax,
      Set(varScore, varScore + 1); Set(varMaxScore, varMaxScore + 1),
      Set(varScore, varScore + 0.3); Set(varMaxScore, varMaxScore + 1)
    )
  );
  
  // Forb Cover Assessment (ATTR-FC01) for grassland features
  Set(varForbCoverObs, LookUp(observations, AttributeID = "ATTR-FC01"));
  If(featureConfig.Name = "Calcareous Grassland" And !IsBlank(varForbCoverObs),
    If(Value(varForbCoverObs.RecordedValue) >= featureConfig.Thresholds.ForbCoverMin And 
       Value(varForbCoverObs.RecordedValue) <= featureConfig.Thresholds.ForbCoverMax,
      Set(varScore, varScore + 1); Set(varMaxScore, varMaxScore + 1),
      Set(varScore, varScore + 0.4); Set(varMaxScore, varMaxScore + 1)
    )
  );
  
  {
    Score: If(varMaxScore > 0, varScore / varMaxScore, 0.5),
    MaxScore: varMaxScore,
    ActualScore: varScore
  }

// Calculate Species Presence Score using observation notes
Function CalculateSpeciesPresence(observations As Table, featureConfig As Record) As Record:
  Set(varSpeciesFound, 0);
  Set(varTotalSpecies, CountRows(featureConfig.RequiredSpecies));
  
  // Combine all observation notes to check for species mentions
  Set(varAllNotes, Concat(observations, Notes & " ", ""));
  
  // Check for each required species in observation notes
  ForAll(featureConfig.RequiredSpecies, 
    If(IsBlank(varAllNotes),
      Set(varSpeciesFound, varSpeciesFound + 0.3),
      If(Lower(varAllNotes) Contains Lower(ThisRecord.Value),
        Set(varSpeciesFound, varSpeciesFound + 1)
      )
    )
  );
  
  {
    Score: If(varTotalSpecies > 0, varSpeciesFound / varTotalSpecies, 0.5),
    SpeciesFound: varSpeciesFound,
    TotalSpecies: varTotalSpecies
  }

// Calculate Pressure Impact Score using pressure records
Function CalculatePressureImpact(assessmentID As Text, featureConfig As Record) As Record:
  Set(varPressureScore, 1.0); // Start with perfect score
  Set(varAssessmentPressures, Filter(colPressures, AssessmentID = assessmentID));
  
  // Invasive Species Impact (ATTR-INV01)
  Set(varInvasiveObs, LookUp(colObservations, AssessmentID = assessmentID And AttributeID = "ATTR-INV01"));
  If(!IsBlank(varInvasiveObs) And varInvasiveObs.RecordedValue = "Present",
    Set(varPressureScore, varPressureScore - 0.3)
  );
  
  // Check for high-risk pressures
  ForAll(varAssessmentPressures,
    If(ThisRecord.RiskLevel = "High",
      Set(varPressureScore, varPressureScore - 0.2),
      If(ThisRecord.RiskLevel = "Medium",
        Set(varPressureScore, varPressureScore - 0.1)
      )
    )
  );
  
  // Ensure score doesn't go below 0
  Set(varPressureScore, Max(varPressureScore, 0));
  
  {
    Score: varPressureScore,
    MaxScore: 1.0,
    ActualScore: varPressureScore
  }

// Calculate Confidence Score based on observation completeness
Function CalculateConfidence(observations As Table, featureConfig As Record) As Record:
  Set(varConfidenceScore, 0);
  Set(varMaxConfidence, 0);
  
  // Data completeness for critical attributes
  ForAll(featureConfig.CriticalAttributes,
    Set(varMaxConfidence, varMaxConfidence + 1);
    If(!IsBlank(LookUp(observations, AttributeID = ThisRecord.Value)),
      Set(varConfidenceScore, varConfidenceScore + 1)
    )
  );
  
  // Additional confidence factors - observations with photos
  Set(varObsWithPhotos, CountRows(Filter(observations, !IsBlank(PhotoURL))));
  Set(varTotalObs, CountRows(observations));
  If(varTotalObs > 0,
    Set(varConfidenceScore, varConfidenceScore + (varObsWithPhotos / varTotalObs) * 0.2);
    Set(varMaxConfidence, varMaxConfidence + 0.2)
  );
  
  // Observations with detailed notes
  Set(varObsWithNotes, CountRows(Filter(observations, Len(Notes) > 10)));
  If(varTotalObs > 0,
    Set(varConfidenceScore, varConfidenceScore + (varObsWithNotes / varTotalObs) * 0.1);
    Set(varMaxConfidence, varMaxConfidence + 0.1)
  );
  
  {
    Score: If(varMaxConfidence > 0, varConfidenceScore / varMaxConfidence, 0.5),
    MaxScore: varMaxConfidence,
    ActualScore: varConfidenceScore
  }

// Export the main calculation function
CalculateCondition