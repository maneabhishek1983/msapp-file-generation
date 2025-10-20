// Natural England Condition Assessment - Error Handling Framework
// Comprehensive error management and user feedback system

// Global Error Handler - Main entry point for all error handling
Function GlobalErrorHandler(errorType As Text, errorMessage As Text, context As Record, showToUser As Boolean) As Boolean:
  
  // Generate unique error ID for tracking
  Set(varErrorId, GUID());
  
  // Log error with full context
  Collect(colErrorLog, {
    ErrorId: varErrorId,
    Timestamp: Now(),
    Type: errorType,
    Message: errorMessage,
    Context: JSON(context),
    UserId: varCurrentUser.UserId,
    UserName: varCurrentUser.DisplayName,
    Screen: App.ActiveScreen.Name,
    AppVersion: "1.0.0",
    Severity: DetermineErrorSeverity(errorType),
    Status: "New"
  });
  
  // Show user-friendly notification if requested
  If(showToUser,
    ShowUserNotification(errorType, errorMessage, varErrorId)
  );
  
  // Return success status
  true

// User Notification System
Function ShowUserNotification(errorType As Text, errorMessage As Text, errorId As Text) As Boolean:
  
  Set(varNotificationConfig, Switch(errorType,
    "DataSync", {
      Title: "Sync Issue",
      Message: "Unable to sync data with server. Your work is saved locally and will sync when connection is restored.",
      Type: NotificationType.Warning,
      Duration: 5000,
      ShowRetry: true,
      Icon: "🔄"
    },
    "Validation", {
      Title: "Input Error", 
      Message: errorMessage,
      Type: NotificationType.Error,
      Duration: 4000,
      ShowRetry: false,
      Icon: "⚠️"
    },
    // Default error
    {
      Title: "Unexpected Error",
      Message: "An unexpected error occurred. The issue has been logged and will be investigated.",
      Type: NotificationType.Error,
      Duration: 4000,
      ShowRetry: false,
      Icon: "❌"
    }
  ));
  
  // Show the notification
  Notify(
    varNotificationConfig.Icon & " " & varNotificationConfig.Title & ": " & varNotificationConfig.Message,
    varNotificationConfig.Type,
    varNotificationConfig.Duration
  );
  
  true

// Export main functions
{
  GlobalErrorHandler: GlobalErrorHandler,
  ShowUserNotification: ShowUserNotification
}