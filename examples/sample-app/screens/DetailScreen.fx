// Sample Detail Screen for testing
Screen(
  Fill: Color.White,
  
  // Header
  Rectangle(
    X: 0, Y: 0, Width: Parent.Width, Height: 80,
    Fill: RGBA(0, 120, 212, 1),
    
    Label(
      Text: "Detail Screen",
      X: 20, Y: 20, Width: Parent.Width - 80, Height: 40,
      Color: Color.White,
      Font: Font.'Segoe UI',
      Size: 18,
      FontWeight: FontWeight.Semibold
    ),
    
    Button(
      Text: "← Back",
      X: Parent.Width - 80, Y: 20, Width: 60, Height: 40,
      Fill: Color.Transparent,
      Color: Color.White,
      BorderColor: Color.White,
      BorderThickness: 1,
      OnSelect: Back()
    )
  ),
  
  // Content
  Label(
    Text: "This is the detail screen with more information.",
    X: 20, Y: 100, Width: Parent.Width - 40, Height: 100,
    Color: RGBA(50, 50, 50, 1),
    Font: Font.'Segoe UI',
    Size: 14,
    Wrap: true
  ),
  
  // Sample data gallery
  Gallery(
    Items: [
      {Title: "Item 1", Description: "First sample item"},
      {Title: "Item 2", Description: "Second sample item"},
      {Title: "Item 3", Description: "Third sample item"}
    ],
    X: 20, Y: 220, Width: Parent.Width - 40, Height: 200,
    Layout: Layout.Vertical,
    TemplateSize: 60,
    
    Rectangle(
      Fill: RGBA(245, 245, 245, 1),
      BorderColor: RGBA(200, 200, 200, 1),
      BorderThickness: 1,
      
      Label(
        Text: ThisItem.Title,
        X: 10, Y: 5, Width: Parent.TemplateWidth - 20, Height: 25,
        Color: RGBA(50, 50, 50, 1),
        Font: Font.'Segoe UI',
        Size: 14,
        FontWeight: FontWeight.Semibold
      ),
      
      Label(
        Text: ThisItem.Description,
        X: 10, Y: 30, Width: Parent.TemplateWidth - 20, Height: 25,
        Color: RGBA(100, 100, 100, 1),
        Font: Font.'Segoe UI',
        Size: 12
      )
    )
  )
);