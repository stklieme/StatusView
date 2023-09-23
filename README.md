# CircularStatusView
An SwiftUI view to display (in)determinate progress and status icons

<br>

---

**Properties**
- **size**: `CGFloat` The size of the view
- **status** : `Status` *.none, .indeterminate, .progress(percentage)*, and *.icon(statusIcon)*
- **color** : `Color` The color of the progressbar
- **showPercentage** : `Bool` If `true` the percentage of the progress is also displayed


**Progress and Icon values**
- **percentage** `CGFloat` a value between 0.0 and 1.0 representing 0 and 100%
- **statusIcon** *.failed* (red), *.failedDisabled* (gray),   
                 *.caution* (orange), *.cautionDisabled* (gray),   
                 *.success* (green), *.successDisabled* (gray),   
                 *.completed* (specifed **color**) and *.completedDisabled* (gray)

All values of `statusIcon` can be displayed *.inverted*

<br>

---

System Requirements:

macOS 10.11 or higher<br>
iOS 15 and higher
