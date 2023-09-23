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

Sample Icon Images

**Normal**


<font size=32><span style="color:lightgreen">􀁢</span><span style="color:orange">􀁞</span><span style="color:red">􀁠</span><span style="color:blue">􀁢</span></font>


**Inverted**

<font size=32><span style="color:lightgreen">􀁣</span><span style="color:orange">􀁟</span><span style="color:red">􀁡</span><span style="color:blue">􀁣</span></font>



<br>

---

System Requirements:

macOS 10.15 Catalina or higher<br>
iOS 14 and higher
