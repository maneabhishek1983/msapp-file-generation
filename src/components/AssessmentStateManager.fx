// Assessment State Manager Component
// Handles assessment lifecycle state machine: Draft → InField → Submitted → UnderReview → Approved | Rejected

// Component properties
Property AssessmentID As Text = "";
Property CurrentState As Text = "Draft";
Property TargetState As Text = "";
Property UserID As Text = "";
Property UserName As Text = "";
Property Reason As Text = "";

// Assessment lifecycle states
Set(varAssessmentStates, {
  Draft: "Draft",
  InField: "InField", 
  Submitted: "Submitted",
  UnderReview: "UnderReview",
  Approved: "Approved",
  Rejected: "Rejected"
});

// State transition rules
Set(varStateTransitions, [
  {From: "Draft", To: "InField", RequiredRole: "Planner", Action: "Publish"},
  {From: "InField", To: "Submitted", RequiredRole: "Planner", Action: "Submit"},
  {From: "InField", To: "Rejected", RequiredRole: "Reviewer", Action: "Reject"},
  {From: "Submitted", To: "UnderReview", RequiredRole: "Reviewer", Action: "Review"},
  {From: "Submitted", To: "Rejected", RequiredRole: "Reviewer", Action: "Reject"},
  {From: "UnderReview", To: "Approved", RequiredRole: "Manager", Action: "Approve"},
  {From: "UnderReview", To: "Rejected", RequiredRole: "Manager", Action: "Reject"},
  {From: "Rejected", To: "Draft", RequiredRole: "Planner", Action: "Restart"}
]);

// Validate state transition
Set(varValidateTransition, Function(fromState As Text, toState As Text, userRole As Text) As Record:
  With(
    {transition: LookUp(varStateTransitions, From = fromState And To = toState)},
    {
      IsValid: !IsBlank(transition) And (transition.RequiredRole = userRole Or userRole = "Admin"),
      RequiredRole: If(IsBlank(transition), "", transition.RequiredRole),
      Action: If(IsBlank(transition), "", transition.Action),
      Message: If(
        IsBlank(transition),
        "Invalid state transition from " & fromState & " to " & toState,
        If(
          transition.RequiredRole = userRole Or userRole = "Admin",
          "Valid transition",
          "Insufficient permissions. Required role: " & transition.RequiredRole
        )
      )
    }
  )
);

// Execute state transition
Set(varExecuteTransition, Function(assessmentID As Text, fromState As Text, toState As Text, userID As Text, userName As Text, reason As Text) As Record:
  With(
    {
      validation: varValidateTransition(fromState, toState, LookUp(colUsers, UserID = userID).Role),
      correlationID: varGenerateCorrelationID()
    },
    If(
      validation.IsValid,
      // Valid transition - update assessment and create audit record
      UpdateIf(colAssessments, AssessmentID = assessmentID, {
        Status: toState,
        ModifiedBy: userID,
        ModifiedDate: Now()
      });
      
      // Create audit trail entry
      Collect(colAudit, {
        AuditID: GUID(),
        AssessmentID: assessmentID,
        Action: validation.Action,
        UserID: userID,
        UserName: userName,
        Timestamp: Now(),
        Details: "Assessment status changed from " & fromState & " to " & toState,
        Reason: reason
      });
      
      // Log event for diagnostics
      Collect(colEventLog, {
        EventID: GUID(),
        EventType: "State Transition",
        Timestamp: Now(),
        UserID: userID,
        UserName: userName,
        CorrelationID: correlationID,
        Details: "Assessment " & assessmentID & " transitioned from " & fromState & " to " & toState,
        Screen: "StateManager"
      });
      
      {
        Success: true,
        Message: "Assessment status updated to " & toState,
        CorrelationID: correlationID,
        NewState: toState
      },
      
      // Invalid transition
      {
        Success: false,
        Message: validation.Message,
        CorrelationID: correlationID,
        NewState: fromState
      }
    )
  )
);

// Get available transitions for current state and user role
Set(varGetAvailableTransitions, Function(currentState As Text, userRole As Text) As Table:
  Filter(varStateTransitions, 
    From = currentState And 
    (RequiredRole = userRole Or userRole = "Admin")
  )
);

// Get state display information
Set(varGetStateInfo, Function(state As Text) As Record:
  Switch(state,
    "Draft", {
      DisplayName: "Draft",
      Description: "Assessment is being prepared",
      Color: varTheme.TextSecondary,
      Icon: "Edit",
      CanEdit: true
    },
    "InField", {
      DisplayName: "In Field",
      Description: "Assessment published for field collection",
      Color: varTheme.Info,
      Icon: "Location",
      CanEdit: false
    },
    "Submitted", {
      DisplayName: "Submitted",
      Description: "Field work completed, awaiting review",
      Color: varTheme.Warning,
      Icon: "Upload",
      CanEdit: false
    },
    "UnderReview", {
      DisplayName: "Under Review",
      Description: "Assessment being reviewed for quality",
      Color: varTheme.Info,
      Icon: "View",
      CanEdit: false
    },
    "Approved", {
      DisplayName: "Approved",
      Description: "Assessment approved and finalized",
      Color: varTheme.Success,
      Icon: "CheckMark",
      CanEdit: false
    },
    "Rejected", {
      DisplayName: "Rejected",
      Description: "Assessment rejected, requires rework",
      Color: varTheme.Error,
      Icon: "Cancel",
      CanEdit: true
    },
    {
      DisplayName: "Unknown",
      Description: "Unknown state",
      Color: varTheme.TextSecondary,
      Icon: "Unknown",
      CanEdit: false
    }
  )
);

// Component visual representation (state indicator)
Container(
  Width: 200,
  Height: 40,
  Fill: varGetStateInfo(CurrentState).Color,
  BorderRadius: 4,
  
  // State label
  Label(
    Text: varGetStateInfo(CurrentState).DisplayName,
    Color: varTheme.Background,
    Font: varNETypography.BodyFont,
    Size: varNETypography.BodySize,
    FontWeight: FontWeight.Semibold,
    Align: Align.Center,
    AccessibleLabel: "Assessment status: " & varGetStateInfo(CurrentState).DisplayName & ". " & varGetStateInfo(CurrentState).Description
  )
);

// Accessibility and keyboard support
TabIndex: 0;
AccessibleLabel: "Assessment status: " & varGetStateInfo(CurrentState).DisplayName;

// Component functions exposed for use by screens
OnSelect:
  // Show available transitions or state information
  Set(varSelectedAssessmentState, CurrentState);
  Set(varAvailableTransitions, varGetAvailableTransitions(CurrentState, varCurrentUser.Role));