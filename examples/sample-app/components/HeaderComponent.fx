// Sample Header Component for testing
Component(
  // Custom properties
  CustomProperty(Title, Text, "Default Title"),
  CustomProperty(BackgroundColor, Color, RGBA(0, 120, 212, 1)),
  CustomProperty(ShowBackButton, Boolean, false),
  
  // Component layout
  Rectangle(
    Width: Parent.Width,
    Height: 80,
    Fill: BackgroundColor,
    
    Label(
      Text: Title,
      X: If(ShowBackButton, 80, 20),
      Y: 20,
      Width: Parent.Width - If(ShowBackButton, 100, 40),
      Height: 40,
      Color: Color.White,
      Font: Font.'Segoe UI',
      Size: 18,
      FontWeight: FontWeight.Semibold,
      Align: Align.Left
    ),
    
    If(ShowBackButton,
      Button(
        Text: "← Back",
        X: 10, Y: 20, Width: 60, Height: 40,
        Fill: Color.Transparent,
        Color: Color.White,
        BorderColor: Color.White,
        BorderThickness: 1,
        OnSelect: Back()
      )
    )
  )
);