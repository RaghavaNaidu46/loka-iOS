# Loka — V1 Wireframe Structure

# 1. Design Direction

## Product Feel
Loka should feel:
- Calm
- Civic
- Trustworthy
- Structured
- Minimal

Avoid:
- Bright entertainment-style UI
- Infinite-scroll addiction patterns
- Viral engagement styling
- Overloaded screens

---

# 2. Design System Foundation

## Typography
### Headings
Bold, clean, highly readable.

### Body Text
Simple readable sans-serif.

### Participation Actions
Clear visual distinction between:
- Support
- Oppose

Avoid emotional colors.

---

## Spacing
Use generous spacing.

Loka should feel deliberate, not crowded.

---

## Card Philosophy
Issue cards should prioritize:
1. Clarity
2. Context
3. Participation visibility
4. Status visibility

Not entertainment.

---

# 3. App Navigation

## Bottom Navigation

| Tab | Purpose |
|---|---|
| Home | Main civic feed |
| Search | Discover issues |
| Create | Create issue |
| Notifications | Participation updates |
| Profile | Citizen identity & participation |

---

# 4. Splash Screen

## Layout
Centered:
- Loka logo
- Tagline

Bottom:
- Loading indicator

---

## Suggested Tagline
"One Citizen. One Voice."

---

# 5. Visitor Home Screen

## Header
- Current region
- Search shortcut

---

## Feed Sections
### Nearby Issues
Primary local feed.

---

### New Issues
Chronological issues.

---

### Community Priority
High participation issues.

---

### Resolved Issues
Completed civic outcomes.

---

# 6. Issue Card Wireframe

┌─────────────────────────┐
| Water Supply Disruption |
| MVP Colony, Vizag       |
| Water • Active          |
|                         |
| Support: 214            |
| Oppose: 18              |
| Evidence: 12            |
|                         |
| Last Activity: 2h ago   |
└─────────────────────────┘

---

## Card Rules
- No profile popularity
- No follower counts
- No reaction emojis
- No engagement bait

---

# 7. Issue Detail Screen

## Layout Order

### Header
- Title
- Status
- Location
- Category

---

### Problem Description
Structured readable content.

---

### Desired Outcome
Clearly separated section.

---

### Evidence Gallery
Photos/videos/documents.

---

### Participation Summary
- Support count
- Oppose count
- Participation ratio

---

### Participation Actions
Buttons:
- Support
- Oppose

Both require confirmation.

---

### Citizen Discussion
Structured comments.

---

### Related Issues
Geographically or categorically related.

---

# 8. Support Interaction

## Flow
Support Button
→ Warning Popup
→ Confirm
→ Participation Recorded

---

## Popup Example
"Support actions are permanent and cannot be reversed."

---

# 9. Oppose Interaction

## Flow
Oppose Button
→ Explanation Input
→ Validation
→ Warning Popup
→ Confirm
→ Participation Recorded

---

## Oppose Requirements
- Minimum character length
- Constructive explanation

---

# 10. Create Issue Screen

## Sections

### Title
Single-line input.

---

### Category
Dropdown selector.

---

### Location
Geographic selector.

---

### Problem Description
Large structured text area.

---

### Desired Outcome
Separate focused text area.

---

### Evidence Upload
- Photos
- Videos
- Documents

---

### Submission Area
Submit Button
→ Duplicate Detection
→ Final Confirmation

---

# 11. Search Screen

## Search Inputs
- Keyword
- District
- Category
- Status

---

## Search Results
Use same issue-card structure.

---

# 12. Notifications Screen

## Notification Examples
- Issue approved
- Clarification requested
- Issue resolved
- Participation received
- Appeal reviewed

Notifications should remain informational.

---

# 13. Profile Screen

## Visitor State
- Become a Citizen
- About Loka
- Policies
- Settings

---

## Verified Citizen State
- Verification badge
- Home District
- Living-In District
- My Issues
- My Participation
- Account Settings

---

# 14. Become Citizen Flow

## Step 1
Introduction & privacy explanation.

---

## Step 2
Upload Aadhaar Offline XML.

---

## Step 3
Enter Share Code.

---

## Step 4
Verification processing.

---

## Step 5
Select districts.

---

## Step 6
Verification completed.

---

# 15. Moderator Dashboard

## Dashboard Sections
- Pending Review
- Clarification Queue
- Published Issues
- Rejected Issues
- Appeals
- Audit Logs

---

# 16. Moderation Review Layout

┌─────────────────────────┐
| Issue Title             |
| Citizen Ref             |
| Category                |
| Location                |
| Evidence Preview        |
| Similar Issues          |
|                         |
| [Approve] [Reject]      |
| [Merge] [Clarify]       |
└─────────────────────────┘

---

# 17. Empty States

Examples:
- No issues nearby
- No notifications
- No participation yet

Empty states should encourage constructive participation.

---

# 18. Error Handling Philosophy

Messages should:
- Remain calm
- Be understandable
- Avoid technical jargon

Examples:
"Verification unsuccessful. Please review your uploaded file and try again."

---

# 19. Accessibility Direction

- High readability
- Large tap areas
- Screen-reader compatibility
- Local language readiness
- Reduced visual clutter

---

# 20. UI Development Principle

The interface should reinforce:
- accountability
- clarity
- thoughtful participation
- civic seriousness

The interface should never encourage impulsive outrage behavior.

