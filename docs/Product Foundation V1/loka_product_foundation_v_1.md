# Loka — Product Foundation v1

## 1. Product Identity

### Brand Name
Loka

### Website
locavoice.in

### Positioning
Loka is a verified civic participation platform focused on structured local issues and accountable citizen participation.

Loka is not designed as a traditional social media platform.

---

# 2. Core Vision

## Mission
Create a structured platform where verified citizens can raise, discuss, support, and oppose local civic issues with accountability.

## Foundational Principles
1. One citizen. One account.
2. Participation requires verification.
3. Every issue belongs to a geographic community.
4. Participation should come from citizens connected to the affected area.
5. Support and opposition actions are permanent.
6. Real identities remain protected from public visibility.
7. Loka prioritizes civic participation over virality.
8. Moderation enforces platform rules, not political opinions.

---

# 3. Geographic Strategy

## Initial Launch Region
- Andhra Pradesh
- Telangana

## Launch Approach
Local-first rollout.

No national issues in V1.

## Geographic Structure
Country
→ State
→ District
→ City
→ Area/Ward

Every issue must belong to a geographic scope.

---

# 4. Participation Model

## Visitor
Visitors may:
- Browse public issues
- Search issues
- View participation counts
- Read issue discussions

Visitors may NOT:
- Create issues
- Support issues
- Oppose issues
- Comment
- Upload evidence

---

## Verified Citizen
Verified citizens may:
- Create issues
- Support issues
- Oppose issues
- Comment
- Upload evidence

---

# 5. Verification Model

## Verification Requirement
Participation requires verification.

Browsing does not require verification.

---

## Verification Method (V1)
Aadhaar Offline XML Verification.

The citizen uploads:
- Aadhaar Offline XML package
- Share Code

The system validates:
- UIDAI digital signature
- XML integrity
- Verification uniqueness

---

## Verification Philosophy
Loka verifies identity for participation integrity.

Loka does not publicly expose identity information.

---

## Publicly Hidden Information
The following information must never be publicly visible:
- Aadhaar number
- Phone number
- Email
- Legal name
- Address
- Uploaded verification documents

---

## Public Profile Information
Public profile may display:
- Display name
- District
- Joined date
- Participation history
- Verified Citizen badge

---

# 6. Geographic Participation Rules

Every verified citizen has:

## Home District
Permanent civic identity district.

Changes are:
- Rare
- Verification-based
- Restricted

---

## Living-In District
Current residence district.

Changes are:
- User initiated
- Frequency limited
- Subject to verification/confirmation

---

## Participation Eligibility
Citizens may participate in issues belonging to:
- Home District
- Living-In District

Citizens outside the scope may only read issues.

---

# 7. Issue Model

Loka uses structured civic issues instead of social-media-style posts.

Every issue must contain:
1. Problem
2. Location
3. Desired Outcome

---

## Required Fields
### Issue Title
Short, specific description.

### Location
Mandatory geographic tagging.

### Problem Description
Detailed issue explanation.

### Desired Outcome
Clear expected resolution.

### Category
Examples:
- Roads
- Water
- Electricity
- Health
- Education
- Environment
- Public Safety
- Governance

### Evidence (Optional)
- Photos
- Videos
- Documents

---

## Invalid Issues
Examples of invalid content:
- Personal attacks
- Hate speech
- Meaningless submissions
- Advertisements
- Doxxing
- Spam
- Illegal content

---

# 8. Issue Lifecycle

Draft
→ Submitted
→ Under Review
→ Published
→ Active
→ Resolved
→ Archived

Additional statuses:
- Rejected
- Merged

---

## Moderation Outcomes
Moderators may:
- Approve
- Reject
- Merge
- Request Clarification

Moderators may not rewrite citizen content.

---

# 9. Support & Oppose System

## Participation Philosophy
Support and opposition actions are treated as accountable civic participation.

---

## Support
- One-time action
- Permanent
- Confirmation required

---

## Oppose
- One-time action
- Permanent
- Mandatory explanation
- Minimum explanation requirement

---

## Restrictions
Citizens may not both support and oppose the same issue.

Actions cannot be modified after submission.

---

# 10. Feed Structure

## Feed Philosophy
The feed should answer:
"What issues need citizen attention?"

Not:
"What content increases engagement?"

---

## V1 Feed Sections
1. Nearby Issues
2. New Issues
3. Community Priority
4. Resolved Issues

---

## Excluded From V1
- Followers
- DMs
- Stories
- Reels
- Trending hashtags
- Recommendation algorithms
- Influencer systems
- Viral mechanics

---

# 11. Moderation Principles

Moderators enforce platform rules.

Moderators do not decide political correctness.

---

## Moderation Responsibilities
- Spam prevention
- Duplicate handling
- Abuse prevention
- Safety enforcement
- Issue quality review

---

## Moderator Accountability
Every moderation action must be logged with:
- Moderator identity
- Timestamp
- Action taken
- Reason

---

## Appeals
Citizens may appeal moderation decisions.

Appeals are logged and reviewable.

---

# 12. Trust & Safety

## Prohibited Content
- Threats
- Harassment
- Hate speech
- Doxxing
- Illegal content
- Coordinated abuse
- Fraudulent evidence

---

## One Citizen = One Account
Multiple verified identities are prohibited.

Identity fraud may result in permanent suspension.

---

## Transparency Principle
Loka avoids hidden moderation whenever possible.

Platform actions should remain explainable and auditable.

---

# 13. Launch Strategy

## Rollout Philosophy
Start small.

Focus on participation quality before scale.

---

## Initial Rollout
- One city or limited-region pilot
- Controlled onboarding
- Human moderation
- Invite-oriented growth

---

## Initial Success Metrics
- Issue quality
- Constructive participation
- Moderation scalability
- Weekly active participation
- Duplicate issue management

---

# 14. MVP Scope

## Included in V1
- OTP authentication
- Aadhaar Offline XML verification
- Citizen profiles
- Issue creation
- Support/Oppose participation
- Evidence upload
- Search
- Notifications
- Moderation dashboard
- Reporting and suspension systems

---

## Excluded from V1
- Direct messaging
- Followers
- Public reputation scores
- AI moderation
- Trending systems
- Monetization
- Livestreams
- National issue participation
- Large-scale recommendation systems

---

# 15. Product Tone

Loka should feel:
- Calm
- Serious
- Civic
- Structured
- Accountable

Loka should not feel:
- Addictive
- Chaotic
- Rage-driven
- Influencer-centric
- Entertainment-focused

---

# 16. Current Project Status

Phase 1 — Product Definition
Status: Completed

Phase 2 — Product Design & Technical Planning
Status: Ready to Begin

---

# 17. Core User Flows

## Visitor → Verified Citizen Flow

Open App
→ Browse Public Issues
→ Open Profile
→ Become a Citizen
→ Upload Aadhaar Offline XML + Share Code
→ Verification Validation
→ Select Home District
→ Select Living-In District
→ Citizen Verified
→ Participation Unlocked

---

## Create Issue Flow

Home Feed
→ Create Issue
→ Enter Title
→ Select Category
→ Select Location
→ Enter Problem Description
→ Enter Desired Outcome
→ Upload Evidence (Optional)
→ Duplicate Detection Check
→ Submit
→ Under Review
→ Moderator Decision

Possible outcomes:
- Published
- Rejected
- Merge Request
- Clarification Requested

---

## Support Issue Flow

Open Issue
→ Press Support
→ Confirmation Warning
→ Permanent Support Recorded

Restrictions:
- Cannot undo
- Cannot oppose later

---

## Oppose Issue Flow

Open Issue
→ Press Oppose
→ Enter Mandatory Explanation
→ Validation Check
→ Confirmation Warning
→ Permanent Opposition Recorded

Restrictions:
- Cannot undo
- Cannot support later

---

## Moderator Review Flow

Moderator Dashboard
→ Open Pending Issue
→ Review Content
→ Review Evidence
→ Review Duplicate Suggestions
→ Approve / Reject / Merge / Request Clarification
→ Audit Log Generated

---

## Clarification Flow

Moderator Requests Clarification
→ Citizen Receives Notification
→ Citizen Updates Submission
→ Resubmits Issue
→ Returns to Moderation Queue

---

## Appeal Flow

Citizen Opens Rejected Issue
→ Appeal Decision
→ Enter Appeal Explanation
→ Moderator Review
→ Final Decision

---

## Resolved Issue Flow

Issue Active
→ Resolution Evidence Added
→ Moderator Verification (if required)
→ Issue Marked Resolved
→ Visible in Resolved Feed

---

# 18. Information Architecture (V1)

## Bottom Navigation
1. Home
2. Search
3. Create Issue
4. Notifications
5. Profile

---

## Home Sections
- Nearby Issues
- New Issues
- Community Priority
- Resolved Issues

---

## Profile Sections
- Citizen Status
- Verification Status
- Participation Regions
- My Issues
- My Participation
- Settings

---

## Moderator Dashboard Sections
- Pending Review
- Published Issues
- Rejected Issues
- Merge Queue
- Appeals
- Audit Logs

---

# 19. Initial Technical Direction

## Client Platform
Primary focus:
- Native iOS app (SwiftUI)

Android may follow later.

---

## Backend Responsibilities
- Authentication
- Verification processing
- Issue management
- Participation tracking
- Moderation workflows
- Notification delivery
- Audit logging

---

## Core System Principles
- Secure identity handling
- Auditability
- Geographic participation enforcement
- Immutable participation records
- Moderation traceability

---

# 20. Development Philosophy

Loka should prioritize:
- Stability
- Clarity
- Accountability
- Operational simplicity

Loka should avoid premature complexity.

The MVP goal is to validate structured verified civic participation before expanding into broader platform capabilities.

---

# 21. Core Domain Model (V1)

## Citizen
Represents a verified or unverified platform user.

### Core Fields
- Citizen ID
- Display Name
- Phone Number
- Verification Status
- Home District
- Living-In District
- Account Status
- Created At
- Last Active At

---

## Verification Record
Represents identity verification metadata.

### Core Fields
- Verification ID
- Citizen ID
- Verification Type
- Verification Status
- UIDAI Verification Reference
- Verification Timestamp
- Verification Source Metadata

Sensitive raw documents should not be permanently retained unless operationally required.

---

## Issue
Represents a civic issue.

### Core Fields
- Issue ID
- Creator Citizen ID
- Title
- Description
- Desired Outcome
- Category
- Geographic Scope
- Status
- Support Count
- Oppose Count
- Evidence Count
- Created At
- Updated At

---

## Issue Evidence
Represents uploaded issue evidence.

### Core Fields
- Evidence ID
- Issue ID
- Uploaded By
- Evidence Type
- Storage Reference
- Moderation Status
- Uploaded At

---

## Participation Record
Represents support or opposition.

### Core Fields
- Participation ID
- Citizen ID
- Issue ID
- Participation Type
- Oppose Explanation
- Created At

Participation records are immutable.

---

## Comment
Represents citizen discussion.

### Core Fields
- Comment ID
- Citizen ID
- Issue ID
- Comment Text
- Moderation Status
- Created At

---

## Moderation Action
Represents moderation history.

### Core Fields
- Action ID
- Moderator ID
- Target Type
- Target ID
- Action Type
- Reason
- Notes
- Timestamp

Moderation history should never be silently deleted.

---

## Appeal
Represents moderation appeals.

### Core Fields
- Appeal ID
- Citizen ID
- Related Action ID
- Appeal Reason
- Appeal Status
- Resolution Notes
- Created At

---

## Notification
Represents citizen notifications.

### Core Fields
- Notification ID
- Citizen ID
- Notification Type
- Reference Target
- Read Status
- Created At

---

# 22. API Direction (V1)

## Authentication APIs
- Send OTP
- Verify OTP
- Refresh Session
- Logout

---

## Verification APIs
- Upload Aadhaar XML
- Validate Verification
- Citizen Status
- Update Participation Districts

---

## Issue APIs
- Create Issue
- Update Draft
- Submit Issue
- Get Issue Details
- Search Issues
- List Feed Issues
- Get Related Issues

---

## Participation APIs
- Support Issue
- Oppose Issue
- Get Participation Status

---

## Comment APIs
- Add Comment
- List Comments
- Report Comment

---

## Moderation APIs
- List Pending Issues
- Approve Issue
- Reject Issue
- Merge Issue
- Request Clarification
- Review Appeals

---

# 23. Initial Infrastructure Direction

## Recommended Architecture Style
Modular backend architecture.

Avoid premature microservices.

Start with a clean modular monolith.

---

## Initial Infrastructure Goals
- Fast iteration
- Operational simplicity
- Audit logging
- Secure identity handling
- Reliable media storage

---

## Core Infrastructure Components
- API Server
- Database
- Media Storage
- Notification Service
- Moderation Dashboard
- Logging & Monitoring

---

# 24. Recommended MVP Priorities

## Phase A
Foundation
- Authentication
- Verification
- Citizen Profiles
- Geographic Model

---

## Phase B
Core Participation
- Issue Creation
- Support/Oppose
- Feed
- Search

---

## Phase C
Moderation
- Moderator Dashboard
- Appeals
- Reporting
- Audit Logs

---

## Phase D
Stabilization
- Performance
- Abuse Handling
- Notifications
- Analytics
- Pilot Testing

---

# 25. Product Freeze Principle

After development begins:
- Foundational participation rules should remain stable.
- New features should be evaluated against the core civic participation mission.
- Features that increase virality without increasing civic value should be postponed.

The product should evolve deliberately, not reactively.

---

# 26. Screen Structure & Wireframe Direction (V1)

## App Entry

### Splash Screen
Purpose:
- Brand introduction
- Session validation

Elements:
- Loka logo
- Loading state

---

## Visitor Home Screen

### Top Area
- Location context
- Search shortcut

### Main Feed
Sections:
1. Nearby Issues
2. New Issues
3. Community Priority
4. Resolved Issues

### Bottom Navigation
- Home
- Search
- Create
- Notifications
- Profile

---

## Issue Card Structure

### Card Contents
- Issue title
- Location
- Category
- Status badge
- Support count
- Oppose count
- Evidence count
- Last activity timestamp

### Card Actions
- Open Issue
- Share (future)

No social reactions.

---

## Issue Detail Screen

### Section Order
1. Issue Summary
2. Status
3. Location
4. Desired Outcome
5. Evidence
6. Support/Oppose Summary
7. Citizen Discussion
8. Related Issues

---

## Support Interaction

Flow:
Support Button
→ Warning Popup
→ Confirmation
→ Permanent Action Recorded

Warning text should clearly state that participation cannot be reversed.

---

## Oppose Interaction

Flow:
Oppose Button
→ Mandatory Explanation Input
→ Validation
→ Warning Popup
→ Confirmation
→ Permanent Action Recorded

Opposition requires constructive participation.

---

## Create Issue Screen

### Required Sections
1. Title
2. Category
3. Location
4. Problem Description
5. Desired Outcome
6. Evidence Upload

### Submission Flow
Submit
→ Duplicate Detection
→ Final Confirmation
→ Moderation Queue

---

## Search Screen

### Search Types
- Keyword search
- District search
- Category filtering
- Status filtering

---

## Notifications Screen

### Notification Types
- Issue approved
- Issue rejected
- Clarification requested
- Participation on created issue
- Appeal updates

Notifications should remain utility-focused.

---

## Profile Screen

### Visitor Profile
- Become a Citizen
- About Loka
- Policies
- Settings

---

### Citizen Profile
- Verification Status
- Home District
- Living-In District
- My Issues
- My Participation
- Account Settings

---

## Become Citizen Flow

### Verification Steps
1. Upload Aadhaar Offline XML
2. Enter Share Code
3. Validation Processing
4. Select Home District
5. Select Living-In District
6. Verification Complete

---

## Moderator Dashboard

### Primary Sections
- Pending Queue
- Clarification Queue
- Published Issues
- Rejected Issues
- Appeals
- Audit Logs

---

## Pending Review Layout

Each moderation item displays:
- Citizen reference
- Issue title
- Category
- Location
- Evidence preview
- Similar issue suggestions
- Moderation history

---

## Moderation Actions
- Approve
- Reject
- Merge
- Request Clarification

Each action requires a reason.

---

# 27. UX Principles

## Design Philosophy
Loka should feel:
- Clean
- Calm
- Trustworthy
- Serious
- Structured

The interface should avoid entertainment-oriented patterns.

---

## Interaction Principles
- Minimize unnecessary animations
- Prioritize readability
- Reduce emotional amplification
- Encourage thoughtful participation
- Require confirmation for permanent actions

---

## Accessibility Direction
- Large readable typography
- Clear color contrast
- Simple navigation hierarchy
- Local-language readiness

---

# 28. Analytics Direction (Internal)

## Product Analytics Goals
Measure:
- Participation quality
- Issue resolution patterns
- Moderation load
- Citizen retention
- Duplicate issue frequency

Avoid engagement-maximization metrics as primary success indicators.

---

## Initial Metrics
- Daily active citizens
- Verified citizen conversion rate
- Issues created per district
- Average moderation response time
- Support vs Oppose participation ratio
- Appeal frequency

---

# 29. Immediate Next Execution Steps

## Step 1
Convert wireframe directions into actual UI wireframes.

---

## Step 2
Finalize technical stack.

---

## Step 3
Design backend schema and API contracts.

---

## Step 4
Setup repositories and infrastructure.

---

## Step 5
Begin phased MVP implementation.

---

# 30. Final Product Direction

Loka is designed as:
- A verified civic participation platform
- Focused on local accountability
- Built around structured citizen issues
- Governed through transparent moderation
- Resistant to anonymous manipulation and viral outrage mechanics

The long-term success of Loka depends on preserving trust, participation integrity, and operational transparency while scaling carefully.

