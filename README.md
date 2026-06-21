# Loka — iOS

Native iOS client for **Loka**, a verified civic participation platform that lets citizens
report local issues, discuss improvements, and vote on community proposals. Citizen identity is
secured through Aadhaar verification and civic actions are geographically gated to the user's
home/residency district.

## Tech Stack
- **Language**: Swift
- **UI**: SwiftUI
- **Architecture**: Feature-oriented modular (MVVM + Service + Repository layers)
- **Project generation**: [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`project.yml`)
- **Backend**: Talks to the [Loka REST API](https://github.com/RaghavaNaidu46/loka-restApi)

## Project Structure
```text
Loka/
├── App/            # App entry point, root + tab views, splash
├── Core/           # API client, session, config, secure storage, routing
├── DesignSystem/   # Reusable SwiftUI components
├── Features/       # Feature modules (auth, feed, issue, profile, search, verification, ...)
├── Models/         # Domain models
├── Networking/     # DTOs and networking helpers
├── Repositories/   # Repository layer
├── Services/       # Service layer (auth, issue, verification)
├── Resources/      # Assets and resources
└── Utilities/      # Shared helpers
```

## Getting Started
```bash
# Generate the Xcode project (Loka.xcodeproj is gitignored / regenerable)
xcodegen generate

# Then open the workspace/project in Xcode and run.
open Loka.xcodeproj
```

Point the app at your running backend instance via `Core/AppConfig.swift`.

## Documentation
See [`docs/`](docs/) for the iOS architecture plan, the cross-platform architecture & component
plan, product foundation, and wireframe specs.

## Contributing
Please review the [Code of Conduct](CODE_OF_CONDUCT.md) before contributing.

## License
Apache License 2.0.
