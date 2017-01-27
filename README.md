# Goal
The goal of this mobile application is to provide a single place for the user to see where they’re at in their mortgage in a way that compels them to make extra payments in order to save money on interest. 
# Git Tree
/master
/develop
/release/x.x.x
/defect/<123-issue-name>
/feature/feature-name
# Git Process
All development occurs on the **develop** branch.
**develop** > **defect/<name>** (branch defects from develop).
**develop** > **feature/<name>** (branch features from develop).
Upon code review completion development branches are merged into the **develop** branch.
Upon feature freeze a **release/x.x.x** branch is created from **develop**.
Before publishing to the App Store tag build as **x.x.x-rc#**.
After publishing to the App Store merge **release** into both **develop** and **master** branches.
Tag build as **x.x.x**.
# Tools
Google Documents
Sketch
Xcode
Slack
Trello
GitHub
waffle.io
CocoaPods
Firebase

