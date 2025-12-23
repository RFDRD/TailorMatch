"""
TailorMatch - Diploma Thesis Generator (Part 3: Chapter 2 - System Design)
Continue from Part 2
"""

# ==================== CHAPTER 2: SYSTEM DESIGN ====================
doc.add_heading("2. System Design and Architecture", 1)

# 2.1 Requirements Analysis
doc.add_heading("2.1. Requirements Analysis", 2)

req_text = """The requirements analysis phase is critical for ensuring that the developed application meets stakeholder needs. Requirements are categorized into functional (what the system does) and non-functional (how the system performs) categories.

Functional Requirements

Client (Customer) Requirements:

FR-C01: User Registration and Authentication
    - Users can register with email and password
    - Users can log in and maintain persistent sessions
    - Users can log out with confirmation dialog

FR-C02: Tailor Discovery
    - Users can browse list of available tailors
    - Users can view tailor profiles with services
    - Users can see tailor ratings and reviews

FR-C03: Service Information
    - Users can view detailed service descriptions
    - Users can see price ranges for each service
    - Users can view estimated completion times
    - Users can see tailor's busy days calendar

FR-C04: Communication
    - Users can initiate chat conversations with tailors
    - Users can send and receive real-time messages
    - Users can view conversation history

FR-C05: Order Management
    - Users can place orders for services
    - Users can track order status
    - Users can view order history

FR-C06: Rating and Review
    - Users can rate tailors on multiple aspects (quality, size, speed, service, price)
    - Users can provide written reviews
    - Users can update their ratings

FR-C07: Profile Management
    - Users can edit their name and region
    - Users can update contact information
    - Users can change language settings


Tailor Requirements:

FR-T01: Registration and Authentication
    - Tailors can register with email and password
    - Tailors can specify their role during registration
    - Tailors can maintain persistent sessions

FR-T02: Service Management
    - Tailors can add new services
    - Tailors can specify service type, price range, and time
    - Tailors can edit or delete existing services

FR-T03: Order Management
    - Tailors can view incoming orders
    - Tailors can categorize orders by status (New, In Progress, Ready, Completed)
    - Tailors can update order status
    - Tailors can view order history

FR-T04: Calendar Management
    - Tailors can mark days as busy
    - Tailors can remove busy day markings
    - Busy days are visible to clients

FR-T05: Communication
    - Tailors can receive and respond to client messages
    - Tailors can view all active conversations
    - Tailors can access conversation history

FR-T06: Profile Management
    - Tailors can edit their name and region
    - Tailors can view their ratings
    - Tailors can change language settings


Non-Functional Requirements:

NFR-01: Performance
    - Application launch time < 3 seconds
    - Screen transition time < 300ms
    - Message delivery latency < 500ms
    - Smooth scrolling at 60fps

NFR-02: Reliability
    - 99.9% uptime for backend services
    - Graceful handling of network failures
    - Data persistence during connectivity issues

NFR-03: Usability
    - Intuitive navigation requiring no training
    - Consistent UI patterns throughout application
    - Support for Uzbek, Russian, and English languages
    - Accessible color contrast ratios

NFR-04: Security
    - Encrypted data transmission (HTTPS/TLS)
    - Secure authentication token management
    - Role-based access control
    - Input validation and sanitization

NFR-05: Scalability
    - Support for 10,000+ registered users
    - Handle 1,000+ concurrent connections
    - Efficient database queries with proper indexing

NFR-06: Maintainability
    - Modular code architecture
    - Clear separation of concerns
    - Comprehensive code documentation
    - Version control with Git"""

add_paragraph_justified(doc, req_text)

# 2.2 System Architecture
doc.add_heading("2.2. System Architecture Design", 2)

arch_text = """The TailorMatch application follows a layered architecture pattern, separating concerns into distinct layers that communicate through well-defined interfaces. This approach promotes maintainability, testability, and scalability.

Architecture Overview

The system comprises three primary tiers:

Presentation Layer (Client Application)
    - Flutter mobile application
    - Handles user interface rendering
    - Manages user interactions
    - Implements client-side state management

Business Logic Layer (Services)
    - Authentication services
    - User management services
    - Order processing services
    - Chat messaging services
    - Rating and review services

Data Layer (Firebase Backend)
    - Cloud Firestore (database)
    - Firebase Authentication
    - Firebase Storage (file storage)


Application Layer Structure

The Flutter application is organized into the following package structure:

lib/
├── main.dart                 # Application entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── user_model.dart
│   ├── order_model.dart
│   ├── service_model.dart
│   ├── message_model.dart
│   └── portfolio_model.dart
├── services/                 # Business logic services
│   ├── auth_service.dart
│   ├── user_service.dart
│   ├── order_service.dart
│   ├── chat_service.dart
│   └── storage_service.dart
├── screens/                  # UI screens
│   ├── auth/
│   │   └── auth_screens.dart
│   ├── client/
│   │   └── client_home.dart
│   ├── tailor/
│   │   └── tailor_home.dart
│   └── chat/
│       └── chat_screen.dart
├── l10n/                     # Localization
│   └── app_localizations.dart
└── providers/                # State management
    └── locale_provider.dart


Service Layer Design

Each service encapsulates specific business logic:

AuthService:
    - getCurrentUser(): Returns currently authenticated user
    - getCurrentUserData(): Retrieves user profile from Firestore
    - signInWithEmail(): Authenticates with email/password
    - createAccount(): Creates new user account
    - signOut(): Ends user session

UserService:
    - getTailors(): Streams list of tailor profiles
    - getTailorServices(): Streams services for specific tailor
    - addService(): Creates new service entry
    - getBusyDays(): Streams busy day calendar
    - addBusyDay()/removeBusyDay(): Manages calendar

OrderService:
    - createOrder(): Creates new order
    - getClientOrders(): Streams client's orders
    - getTailorOrders(): Streams tailor's orders
    - updateOrderStatus(): Changes order status
    - addRating(): Adds multi-aspect rating

ChatService:
    - getOrCreateChat(): Initiates or retrieves conversation
    - sendMessage(): Sends chat message
    - getMessages(): Streams conversation messages
    - getUserChats(): Streams user's conversations


State Management Architecture

The application employs a combination of state management approaches:

1. Widget-Level State: StatefulWidget for local UI state (tab selection, form inputs)

2. Provider Pattern: For cross-cutting concerns:
    - LocaleProvider: Manages application language preference
    - Shared across all screens via inherited widget

3. StreamBuilder Pattern: For real-time data:
    - Orders list updates
    - Chat messages
    - Busy day calendar

This hybrid approach balances simplicity with the requirements of real-time updates and global state sharing."""

add_paragraph_justified(doc, arch_text)

# Architecture Diagram
doc.add_paragraph()
p = doc.add_paragraph()
p.add_run("Figure 2: TailorMatch System Architecture").bold = True
p.alignment = WD_ALIGN_PARAGRAPH.CENTER

doc.add_paragraph("[System Architecture Diagram: Shows three-tier architecture with Client App, Services Layer, and Firebase Backend]")

# 2.3 Database Schema
doc.add_heading("2.3. Database Schema Design", 2)

db_text = """Cloud Firestore, as a NoSQL document database, provides flexibility in schema design. The TailorMatch database schema is designed to optimize for common access patterns while maintaining data integrity.

Collection Design Principles

1. Denormalization for Read Performance: Frequently accessed data is duplicated to minimize document reads.

2. Subcollection Usage: Related data that grows unboundedly (messages, services) is stored in subcollections.

3. Document Reference Strategy: References between documents use string IDs rather than Firestore references for flexibility.

Users Collection

The central entity storing both client and tailor profiles:

Collection: users
Document ID: Firebase Auth UID

Schema:
{
    "id": string,              // Same as document ID
    "name": string,            // Display name
    "email": string,           // Email address
    "role": string,            // "client" or "tailor"
    "address": string,         // Region/Viloyat
    "phone": string,           // Contact number (optional)
    "avatar": string,          // Profile image URL (optional)
    "experienceYears": number, // For tailors
    "createdAt": timestamp
}

Subcollection: users/{userId}/services (tailors only)
{
    "id": string,
    "type": string,           // Service name
    "priceRange": string,     // e.g., "50,000 - 100,000 so'm"
    "avgTime": string         // e.g., "3-5 kun"
}

Subcollection: users/{userId}/busy_days (tailors only)
{
    "date": timestamp         // Busy date
}


Orders Collection

Represents service orders between clients and tailors:

Collection: orders
Document ID: Auto-generated

Schema:
{
    "id": string,
    "clientId": string,        // Reference to client
    "tailorId": string,        // Reference to tailor
    "serviceId": string,       // Reference to service
    "serviceName": string,     // Denormalized service name
    "status": string,          // Order status (see below)
    "createdAt": timestamp,
    "updatedAt": timestamp,
    "rating": {                // Optional, added after completion
        "quality": number,     // 1-5 stars
        "size": number,
        "speed": number,
        "service": number,
        "price": number,
        "average": number,
        "comment": string
    }
}

Status Values:
    - "pending": New order, awaiting tailor response
    - "meetingScheduled": Initial meeting scheduled
    - "inProgress": Work has begun
    - "fittingScheduled": Fitting appointment set
    - "ready": Work complete, awaiting pickup
    - "completed": Order finalized
    - "cancelled": Order cancelled


Chats Collection

Manages conversations between clients and tailors:

Collection: chats
Document ID: Composite of clientId and tailorId

Schema:
{
    "id": string,
    "clientId": string,
    "tailorId": string,
    "clientName": string,      // Denormalized for display
    "tailorName": string,      // Denormalized for display
    "lastMessage": string,     // Preview text
    "lastMessageAt": timestamp
}

Subcollection: chats/{chatId}/messages
{
    "id": string,
    "senderId": string,
    "text": string,
    "createdAt": timestamp
}


Indexing Strategy

Firestore automatically indexes single fields. Composite indexes are created for complex queries:

1. Orders by Client: (clientId, createdAt DESC) - For client order history
2. Orders by Tailor: (tailorId, createdAt DESC) - For tailor dashboard
3. Chats by User: (clientId, lastMessageAt DESC) and (tailorId, lastMessageAt DESC)"""

add_paragraph_justified(doc, db_text)

# 2.4 UI Design
doc.add_heading("2.4. User Interface Design Principles", 2)

ui_text = """The TailorMatch user interface is designed following established principles of mobile UX design, with particular attention to the target user demographic in Uzbekistan.

Design System Foundation

Color Palette:
    - Primary: #E91E63 (Pink) - Main accent color, buttons, highlights
    - Background Light: #FFFFFF
    - Background Dark: #121212
    - Text Primary: #212121
    - Text Secondary: #757575
    - Success: #4CAF50
    - Warning: #FF9800
    - Error: #F44336

Typography:
    - Font Family: Google Fonts (Lato)
    - Headings: 24-28pt, Bold
    - Body: 14-16pt, Regular
    - Captions: 12pt, Regular

Spacing System:
    - Base unit: 8px
    - Padding: 16px, 24px
    - Margins: 8px, 16px, 32px

Navigation Architecture

The application employs a bottom navigation pattern with role-specific tabs:

Client Navigation:
    1. Home (Chevarlar) - Tailor discovery
    2. Orders (Buyurtmalar) - Order management
    3. Messages (Xabarlar) - Chat conversations
    4. Profile (Profil) - Settings and account

Tailor Navigation:
    1. Dashboard (Buyurtmalar) - Order management with status tabs
    2. Services (Xizmatlar) - Service management
    3. Messages (Xabarlar) - Client conversations
    4. Calendar (Kalendar) - Busy day management
    5. Profile (Profil) - Settings and account

Component Design

Cards: Used extensively for list items (tailors, orders, services)
    - Rounded corners (12px radius)
    - Subtle shadow for elevation
    - Consistent padding (16px)
    - Clear visual hierarchy

Buttons:
    - Primary: Filled with primary color
    - Secondary: Outlined with primary color
    - Text: No background, primary color text
    - Consistent height (48px) for touch targets

Forms:
    - Floating labels for text fields
    - Clear validation feedback
    - Accessible error messages
    - Consistent field heights

Dialogs:
    - Centered modal presentation
    - Clear action buttons
    - Confirmation dialogs for destructive actions

Multilingual Considerations

The interface supports three languages with specific considerations:

1. Text Expansion: Russian text is typically 20-30% longer than English. UI layouts accommodate this variance.

2. Right-to-Left Support: While current languages are LTR, architecture supports future RTL locales.

3. Cultural Localization: Date formats, number formatting adapted to locale.

4. Font Support: Selected fonts support Cyrillic and Latin character sets.

Accessibility Features

    - Minimum touch target size: 48x48dp
    - Color contrast ratios meeting WCAG 2.1 AA standards
    - Semantic widget labels for screen readers
    - Scalable text respecting system font size preferences"""

add_paragraph_justified(doc, ui_text)

# 2.5 Security Architecture
doc.add_heading("2.5. Security Architecture", 2)

security_text = """Security is a critical concern for any application handling user data and facilitating commercial transactions. TailorMatch implements multiple security layers.

Authentication Security

Firebase Authentication provides the foundation:

    - Secure token-based authentication (JWT)
    - Tokens automatically refreshed
    - Session persistence with secure storage
    - Password complexity requirements enforced

Implementation in TailorMatch:
    - Email/password authentication
    - Logout confirmation to prevent accidental session termination
    - Auth state persistence across app restarts

Data Security

Transport Layer:
    - All communication over HTTPS/TLS
    - Certificate pinning for additional protection (production)
    - No sensitive data transmitted in query parameters

Storage Layer (Firestore):
    - Data at rest encryption (managed by Google)
    - Security rules enforce authenticated access
    - Row-level security through document ownership checks

Client-Side:
    - No sensitive data stored in plain text
    - Secure storage for authentication tokens
    - No hardcoded credentials in source code

Access Control

Role-Based Access:
    - User role (client/tailor) stored in Firestore
    - UI adapts based on role
    - Backend operations validate role permissions

Firestore Security Rules:
    - Rules enforce authenticated access
    - Document-level authorization checks
    - Validation rules for data integrity

Privacy Considerations

Data Minimization:
    - Only essential user data collected
    - Optional fields clearly marked
    - No tracking beyond essential analytics

User Control:
    - Profile editing capabilities
    - Account settings accessible
    - Clear data retention policies (for production)

GDPR Compliance Considerations (for production):
    - Consent mechanisms
    - Data export capability
    - Account deletion functionality"""

add_paragraph_justified(doc, security_text)

# 2.6 Summary
doc.add_heading("2.6. Summary", 2)

summary2 = """Chapter 2 has detailed the design and architecture decisions for the TailorMatch application:

Requirements Analysis identified 13 functional requirements for clients and 6 for tailors, along with 6 non-functional requirements covering performance, reliability, usability, security, scalability, and maintainability.

The System Architecture follows a three-tier pattern with clear separation between presentation, business logic, and data layers. The Flutter application is organized into models, services, screens, and providers packages.

Database Schema Design leverages Firestore's document model with three main collections (users, orders, chats) and appropriate subcollections for services, busy days, and messages. The schema is optimized for common access patterns.

User Interface Design follows Material Design 3 principles with a consistent design system including color palette, typography, and spacing. Navigation employs bottom navigation with role-specific tabs.

Security Architecture implements multiple layers including Firebase Authentication, transport encryption, Firestore security rules, and role-based access control.

The next chapter will detail the implementation of these design decisions in the TailorMatch application."""

add_paragraph_justified(doc, summary2)

add_page_break(doc)

# Save Part 3
doc.save('/content/TailorMatch_Thesis_Part3.docx')
print("✅ Part 3 (Chapter 2) saved successfully!")
print("Now run Part 4 code...")
