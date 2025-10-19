// Sample Home Screen for testing
Screen(
  Fill: Color.White,
  
  // Header
  Rectangle(
    X: 0, Y: 0, Width: Parent.Width, Height: 80,
    Fill: RGBA(0, 120, 212, 1),
    
    Label(
      Text: "Sample Power App",
      X: 20, Y: 20, Width: Parent.Width - 40, Height: 40,
      Color: Color.White,
      Font: Font.'Segoe UI',
      Size: 18,
      FontWeight: FontWeight.Semibold
    )
  ),
  
  // Welcome message
  Label(
    Text: "Welcome to the sample Power App!",
    X: 20, Y: 100, Width: Parent.Width - 40, Height: 50,
    Color: RGBA(50, 50, 50, 1),
    Font: Font.'Segoe UI',
    Size: 16
  ),
  
  // Navigation button
  Button(
    Text: "Go to Details",
    X: 20, Y: 170, Width: 200, Height: 40,
    Fill: RGBA(0, 120, 212, 1),
    Color: Color.White,
    OnSelect: Navigate(DetailScreen)
  )
);