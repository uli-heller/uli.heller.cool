const config = {
    additionalElements: [
        { filename: "header.md", elementId: "headermd", insertBeforeElementId: "topid" },
        { filename: "navbar.md", elementId: "navbarmd", insertBeforeElementId: "topid",    isNavbar: true },
        { filename: "footer.md", elementId: "footermd", insertBeforeElementId: "bottomid", isNavbar: true },
    ],
    javascripts: [
//        "prism-1.26.0.js",
    ],
    stylesheets: [
        "kornwestheim.css",
//        "prism-1.26.0.css",
    ],
    multiLanguage: false,
    navbarClass:   'navbar',
    indexHtml:     'index.html',
    indexMd:       'index.md',
    markdown:      [ '.md',   '.markdown' ],
    html:          [ '.html', '.htm' ],
    text:          [ '.txt' ],
    timestamp:     '2023-03-25 17:00:01',
}
