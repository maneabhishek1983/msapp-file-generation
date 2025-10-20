Set(varDataSeeded, true);
If(
    IsEmpty(colSites),
    ClearCollect(
        colSites,
        { SiteId: "SSSI-101", SiteName: "Breckland Heath SSSI", Region: "East of England" },
        { SiteId: "SSSI-205", SiteName: "North York Moors SSSI", Region: "Yorkshire & Humber" }
    )
);
